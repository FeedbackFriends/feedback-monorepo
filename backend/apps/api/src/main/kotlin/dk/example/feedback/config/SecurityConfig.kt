package dk.example.feedback.config

import com.fasterxml.jackson.databind.ObjectMapper
import dk.example.feedback.helpers.role
import dk.example.feedback.service.SupabaseIdentityService
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.http.HttpStatus
import org.slf4j.LoggerFactory
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Profile
import org.springframework.security.authorization.AuthorizationDecision
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.core.Authentication
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.AuthenticationEntryPoint
import org.springframework.security.web.access.AccessDeniedHandler
import org.springframework.security.oauth2.server.resource.web.BearerTokenAuthenticationEntryPoint
import org.springframework.security.oauth2.server.resource.web.access.BearerTokenAccessDeniedHandler
import org.springframework.web.cors.CorsConfiguration
import org.springframework.web.cors.CorsConfigurationSource
import org.springframework.web.cors.UrlBasedCorsConfigurationSource
import java.util.function.Supplier


@Configuration
@EnableMethodSecurity
@Profile("!openapi")
class SecurityConfig(
    private val feedbackConfig: FeedbackConfig,
    private val objectMapper: ObjectMapper,
    private val identities: SupabaseIdentityService,
) {

    private val logger = LoggerFactory.getLogger(SecurityConfig::class.java)

    @Bean
    fun corsConfigurationSource(): CorsConfigurationSource {
        val configuration = CorsConfiguration()
        configuration.allowedOrigins = listOf("*")
        configuration.allowedMethods = listOf("GET", "POST", "PUT", "DELETE")
        configuration.allowedHeaders = listOf("*")
        val source = UrlBasedCorsConfigurationSource()
        source.registerCorsConfiguration("/**", configuration)
        return source
    }

    @Bean
    fun filterChain(http: HttpSecurity): SecurityFilterChain {
        val authenticationEntryPoint = AuthenticationEntryPoint { request, response, exception ->
            BearerTokenAuthenticationEntryPoint().commence(request, response, exception)
            writeError(request, response, exception, HttpStatus.UNAUTHORIZED)
        }
        val accessDeniedHandler = AccessDeniedHandler { request, response, exception ->
            BearerTokenAccessDeniedHandler().handle(request, response, exception)
            writeError(request, response, exception, HttpStatus.FORBIDDEN)
        }
        http
            .cors { it.configurationSource(corsConfigurationSource()) }
            .csrf { it.disable() }
            .exceptionHandling {
                it.authenticationEntryPoint(authenticationEntryPoint)
                it.accessDeniedHandler(accessDeniedHandler)
            }
            .authorizeHttpRequests {
                it
                    .requestMatchers("/actuator/health").permitAll()
                    .requestMatchers("/").permitAll()
                    .requestMatchers("/v3/api-docs", "/v3/api-docs.yaml", "/v3/api-docs/**").permitAll()
                    .requestMatchers("/swagger-ui/**").permitAll()
                    .requestMatchers("/webjars/**").permitAll()
                    .requestMatchers("/admin/**").access { authentication, _ ->
                        AuthorizationDecision(isAdminEndpointAllowed(authentication = authentication))
                    }
                    // everything else requires auth
                    .anyRequest().authenticated()
            }
            .oauth2ResourceServer { resourceServer ->
                resourceServer.authenticationEntryPoint(authenticationEntryPoint)
                resourceServer.accessDeniedHandler(accessDeniedHandler)
                resourceServer.jwt { jwt ->
                    jwt.jwtAuthenticationConverter(jwtAuthenticationConverter())
                }
            }

        return http.build()
    }

    private fun writeError(request: HttpServletRequest, response: HttpServletResponse, exception: Exception, status: HttpStatus) {
        val localized = LocalizedApiErrors.response(exception, request, status)
        response.status = status.value()
        response.contentType = "application/json"
        response.characterEncoding = "UTF-8"
        localized.headers.forEach { name, values -> values.forEach { response.addHeader(name, it) } }
        objectMapper.writeValue(response.outputStream, localized.body)
    }

    fun jwtAuthenticationConverter(): JwtAuthenticationConverter {
        val converter = JwtAuthenticationConverter()
        converter.setJwtGrantedAuthoritiesConverter { jwt ->
            val role = jwt.role()?.value
            val roles = role?.let { listOf(it) } ?: emptyList()
            logger.debug("Extracted roles: {}", roles)
            roles.map { SimpleGrantedAuthority(it) }
        }
        return converter
    }

    private fun isAdminEndpointAllowed(authentication: Supplier<Authentication>): Boolean {
        if (feedbackConfig.enableTestAdminEndpoints) {
            return true
        }

        val principal = authentication.get().principal as? Jwt
            ?: return false
        val email = try { identities.verifiedEmail(principal) } catch (_: Exception) { return false }
        return feedbackConfig.normalizedAdminEmails.contains(email.trim().lowercase())
    }
}
