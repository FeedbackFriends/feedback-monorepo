package dk.example.feedback.tests

import com.sun.net.httpserver.HttpServer
import dk.example.feedback.config.FeedbackConfig
import dk.example.feedback.config.SupabaseJwtConfig
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.helpers.role
import dk.example.feedback.model.enumerations.Role
import dk.example.feedback.model.exceptions.ForbiddenResourceAccessException
import dk.example.feedback.service.SupabaseIdentityService
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.jwt.JwtValidators
import java.net.InetSocketAddress
import java.util.UUID

class SupabaseIdentityTest {
    private val subject = UUID.randomUUID().toString()
    private fun jwt(audience: String = "authenticated", anonymous: Boolean = false) = Jwt.withTokenValue("access")
        .header("alg", "ES256").subject(subject).issuer("https://project.supabase.co/auth/v1")
        .issuedAt(java.time.Instant.now()).expiresAt(java.time.Instant.now().plusSeconds(3600))
        .audience(listOf(audience)).claim("is_anonymous", anonymous).claim("role", "authenticated").build()

    @Test
    fun `new identities are isolated from legacy IDs and provider roles do not grant team access`() {
        assertEquals("supabase:$subject", jwt().getAccountId())
        assertEquals(Role.Manager, jwt().role()) // Existing personal meeting features; team authority stays in TeamRepo.
        assertNull(jwt(anonymous = true).role())
        assertFalse(SupabaseJwtConfig.audienceValidator().validate(jwt()).hasErrors())
        assertTrue(SupabaseJwtConfig.audienceValidator().validate(jwt(audience = "other")).hasErrors())
        assertTrue(JwtValidators.createDefaultWithIssuer("https://project.supabase.co/auth/v1")
            .validate(Jwt.withTokenValue("old").header("alg", "RS256").subject(subject)
                .issuer("https://securetoken.google.com/old").build()).hasErrors())
    }

    @Test
    fun `verified email comes from Auth user endpoint and never editable metadata`() {
        val server = HttpServer.create(InetSocketAddress("127.0.0.1", 0), 0)
        var response = """{"id":"$subject","email":"ada@example.com","is_anonymous":false,"user_metadata":{"email_verified":true}}"""
        server.createContext("/auth/v1/user") { exchange ->
            assertEquals("Bearer access", exchange.requestHeaders.getFirst("Authorization"))
            assertEquals("public-key", exchange.requestHeaders.getFirst("apikey"))
            val bytes = response.toByteArray()
            exchange.responseHeaders.add("Content-Type", "application/json")
            exchange.sendResponseHeaders(200, bytes.size.toLong())
            exchange.responseBody.use { it.write(bytes) }
        }
        server.start()
        try {
            val service = SupabaseIdentityService(FeedbackConfig(supabaseUrl = "http://127.0.0.1:${server.address.port}",
                supabasePublishableKey = "public-key", adminEmails = listOf("admin@example.com")))
            assertThrows(ForbiddenResourceAccessException::class.java) { service.verifiedEmail(jwt()) }
            response = """{"id":"$subject","email":"ADA@example.com","is_anonymous":false,"email_confirmed_at":"2026-11-08T00:00:00Z"}"""
            assertEquals("ada@example.com", service.verifiedEmail(jwt()))
            response = """{"id":"different","email":"ada@example.com","is_anonymous":false,"email_confirmed_at":"2026-11-08T00:00:00Z"}"""
            assertThrows(ForbiddenResourceAccessException::class.java) { service.verifiedEmail(jwt()) }
        } finally { server.stop(0) }
    }
}
