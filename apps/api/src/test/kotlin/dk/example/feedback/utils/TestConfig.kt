package dk.example.feedback.utils

import dk.example.feedback.service.firebase.FirebaseService
import org.springframework.boot.test.context.TestConfiguration
import org.springframework.context.annotation.Bean

@TestConfiguration
class TestConfig {
    @Bean
    fun firebaseService(): FirebaseService {
        return FirebaseMockEngine(
            userId = "mock_id_unit_tests"
        )
    }
}

