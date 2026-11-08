package dk.example.feedback.service

import com.fasterxml.jackson.annotation.JsonIgnoreProperties
import com.fasterxml.jackson.annotation.JsonProperty
import dk.example.feedback.config.FeedbackConfig
import dk.example.feedback.model.exceptions.ForbiddenResourceAccessException
import org.springframework.http.HttpStatus
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service
import org.springframework.web.client.RestClient
import org.springframework.web.client.RestClientResponseException
import org.springframework.web.server.ResponseStatusException
import org.springframework.http.client.JdkClientHttpRequestFactory
import java.net.http.HttpClient
import java.time.Duration

@JsonIgnoreProperties(ignoreUnknown = true)
data class SupabaseUser(
    val id: String,
    val email: String? = null,
    @JsonProperty("email_confirmed_at") val emailConfirmedAt: String? = null,
    @JsonProperty("is_anonymous") val anonymous: Boolean = true,
    @JsonProperty("user_metadata") val metadata: Map<String, Any?> = emptyMap(),
)

@Service
class SupabaseIdentityService(private val config: FeedbackConfig) {
    private val http = RestClient.builder().requestFactory(JdkClientHttpRequestFactory(
        HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build()
    ).apply { setReadTimeout(Duration.ofSeconds(5)) }).build()

    fun user(jwt: Jwt): SupabaseUser {
        if (config.supabaseUrl.isBlank() || config.supabasePublishableKey.isBlank())
            throw ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "Authentication unavailable")
        try {
            val user = http.get().uri("${config.supabaseUrl.trimEnd('/')}/auth/v1/user")
                .header("apikey", config.supabasePublishableKey)
                .header("Authorization", "Bearer ${jwt.tokenValue}")
                .retrieve().body(SupabaseUser::class.java)
            if (user == null || user.id != jwt.subject) throw ForbiddenResourceAccessException("Identity mismatch")
            return user
        } catch (exception: RestClientResponseException) {
            if (exception.statusCode.value() in listOf(401, 403)) throw ForbiddenResourceAccessException("Invalid session")
            throw ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "Authentication unavailable")
        } catch (exception: org.springframework.web.client.RestClientException) {
            throw ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "Authentication unavailable")
        }
    }

    fun verifiedEmail(jwt: Jwt): String {
        val user = user(jwt)
        if (user.anonymous || user.emailConfirmedAt.isNullOrBlank() || user.email.isNullOrBlank())
            throw ForbiddenResourceAccessException("Verified email required")
        return user.email.trim().lowercase(java.util.Locale.ROOT)
    }

    fun deleteUser(jwt: Jwt) {
        if (config.supabaseSecretKey.isBlank()) throw ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE)
        // This is a server-only Supabase secret, never a publishable client key.
        http.delete().uri("${config.supabaseUrl.trimEnd('/')}/auth/v1/admin/users/${java.util.UUID.fromString(jwt.subject)}")
            .header("apikey", config.supabaseSecretKey).header("Authorization", "Bearer ${config.supabaseSecretKey}")
            .retrieve().toBodilessEntity()
    }
}
