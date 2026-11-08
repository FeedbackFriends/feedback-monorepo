package dk.example.feedback.utils

import dk.example.feedback.service.SupabaseIdentityService
import dk.example.feedback.service.SupabaseUser
import dk.example.feedback.service.LeaderInvitationMail
import dk.example.feedback.config.FeedbackConfig
import org.mockito.Mockito
import org.springframework.context.annotation.Primary
import dk.example.feedback.firebase.FirebaseService
import java.time.Instant
import org.springframework.boot.test.context.TestConfiguration
import org.springframework.context.annotation.Bean
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.jwt.JwtDecoder

@TestConfiguration
class TestConfig {
    @Bean
    fun firebaseService(): FirebaseMockEngine {
        return FirebaseMockEngine(
            userId = "mock_id_unit_tests"
        )
    }

    @Bean
    @Primary
    fun identities(firebaseService: FirebaseMockEngine): SupabaseIdentityService {
        return object : SupabaseIdentityService(FeedbackConfig(adminEmails = listOf("test@example.com"))) {
            override fun user(jwt: Jwt): SupabaseUser {
                val legacy = firebaseService.getUser(jwt.subject)
                val email = jwt.getClaim<String>("email") ?: legacy.email
                val anonymous = jwt.getClaim<Boolean>("is_anonymous") ?: (jwt.getClaim<String>("role") == null && email == null)
                return SupabaseUser(jwt.subject, email,
                    if (jwt.getClaim<Boolean>("email_verified") == false || anonymous) null else "2026-11-08T00:00:00Z",
                    anonymous, mapOf("full_name" to legacy.displayName))
            }
            override fun deleteUser(jwt: Jwt) {}
        }
    }

    @Bean
    @Primary
    fun invitationMail(): LeaderInvitationMail = Mockito.mock(LeaderInvitationMail::class.java)

    @Bean
    fun jwtDecoder(): JwtDecoder {
        return JwtDecoder { token ->
            val parts = token.split('.', limit = 2)
            val userId = parts.firstOrNull()?.ifBlank { "unknown" } ?: "unknown"
            val role = parts.getOrNull(1)?.ifBlank { null }
            val now = Instant.now()

            Jwt.withTokenValue(token)
                .header("alg", "none")
                .subject(userId)
                .claim("sub", userId)
                .claim("role", role)
                .issuedAt(now)
                .expiresAt(now.plusSeconds(3600))
                .build()
        }
    }
}
