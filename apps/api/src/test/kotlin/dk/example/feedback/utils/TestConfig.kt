package dk.example.feedback.utils

import dk.example.feedback.firebase.FirebaseService
import java.time.Instant
import org.springframework.boot.test.context.TestConfiguration
import org.springframework.context.annotation.Bean
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.jwt.JwtDecoder

@TestConfiguration
class TestConfig {
    @Bean
    fun firebaseService(): FirebaseService {
        return FirebaseMockEngine(
            userId = "mock_id_unit_tests"
        )
    }

    @Bean
    fun jwtDecoder(): JwtDecoder {
        return JwtDecoder { token ->
            val parts = token.split('.', limit = 2)
            val userId = parts.firstOrNull()?.ifBlank { "unknown" } ?: "unknown"
            val role = parts.getOrNull(1)?.ifBlank { null }
            val roles = role?.let { listOf(it) } ?: emptyList()
            val now = Instant.now()

            Jwt.withTokenValue(token)
                .header("alg", "none")
                .subject(userId)
                .claim("sub", userId)
                .claim("role", roles)
                .issuedAt(now)
                .expiresAt(now.plusSeconds(3600))
                .build()
        }
    }
}
