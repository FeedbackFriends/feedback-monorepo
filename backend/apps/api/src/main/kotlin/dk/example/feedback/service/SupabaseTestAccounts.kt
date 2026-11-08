package dk.example.feedback.service

import com.fasterxml.jackson.databind.JsonNode
import dk.example.feedback.config.FeedbackConfig
import org.springframework.stereotype.Service
import org.springframework.http.HttpStatus
import org.springframework.http.client.JdkClientHttpRequestFactory
import org.springframework.web.client.RestClient
import org.springframework.web.server.ResponseStatusException
import java.net.http.HttpClient
import java.time.Duration

@Service
class SupabaseTestAccounts(private val config: FeedbackConfig) {
    private val http = RestClient.builder().requestFactory(JdkClientHttpRequestFactory(
        HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build()
    ).apply { setReadTimeout(Duration.ofSeconds(10)) }).build()

    fun session(label: String?, anonymous: Boolean = false): JsonNode {
        if (!config.enableTestAdminEndpoints) throw ResponseStatusException(HttpStatus.NOT_FOUND)
        if (config.supabaseUrl.isBlank() || config.supabasePublishableKey.isBlank())
            throw ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE)
        fun post(path: String, key: String, body: Map<String, String>): JsonNode = http.post()
            .uri("${config.supabaseUrl.trimEnd('/')}/auth/v1/$path")
            .header("apikey", key).header("Authorization", "Bearer $key")
            .body(body).retrieve().body(JsonNode::class.java) ?: error("Missing test session")
        if (anonymous) return post("signup", config.supabasePublishableKey, emptyMap())
        if (label !in setOf("mock-manager-empty", "mock-manager-with-data", "mock-firebase-only-empty"))
            throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Unknown test account")
        if (config.supabaseSecretKey.isBlank()) throw ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE)
        val link = post("admin/generate_link", config.supabaseSecretKey,
            mapOf("type" to "magiclink", "email" to "$label@example.test"))
        return post("verify", config.supabasePublishableKey,
            mapOf("type" to "magiclink", "token_hash" to link.required("hashed_token").asText()))
    }
}
