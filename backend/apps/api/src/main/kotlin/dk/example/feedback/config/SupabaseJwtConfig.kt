package dk.example.feedback.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Profile
import org.springframework.security.oauth2.core.DelegatingOAuth2TokenValidator
import org.springframework.security.oauth2.core.OAuth2Error
import org.springframework.security.oauth2.core.OAuth2TokenValidator
import org.springframework.security.oauth2.core.OAuth2TokenValidatorResult
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.security.oauth2.jwt.JwtValidators
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder
import org.springframework.security.oauth2.jose.jws.SignatureAlgorithm

@Configuration
@Profile("!openapi & !test")
class SupabaseJwtConfig(private val config: FeedbackConfig) {
    @Bean
    fun jwtDecoder(): JwtDecoder {
        require(config.supabaseUrl.startsWith("https://")) { "SUPABASE_URL must be an HTTPS managed project URL" }
        val issuer = "${config.supabaseUrl.trimEnd('/')}/auth/v1"
        return NimbusJwtDecoder.withJwkSetUri("$issuer/.well-known/jwks.json")
            .jwsAlgorithms { it.add(SignatureAlgorithm.ES256); it.add(SignatureAlgorithm.RS256) }.build().apply {
                setJwtValidator(DelegatingOAuth2TokenValidator(JwtValidators.createDefaultWithIssuer(issuer), audienceValidator()))
            }
    }

    companion object {
        fun audienceValidator() = OAuth2TokenValidator<Jwt> { jwt ->
            val valid = jwt.expiresAt != null && jwt.audience.contains("authenticated") &&
                runCatching { java.util.UUID.fromString(jwt.subject).toString() == jwt.subject }.getOrDefault(false)
            if (valid) OAuth2TokenValidatorResult.success()
            else OAuth2TokenValidatorResult.failure(OAuth2Error("invalid_token", "Invalid audience or subject", null))
        }
    }
}
