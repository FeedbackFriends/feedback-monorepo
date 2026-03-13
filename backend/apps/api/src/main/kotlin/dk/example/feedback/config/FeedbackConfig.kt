package dk.example.feedback.config

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "feedback")
data class FeedbackConfig(
    val firebaseApiKey: String,
    val firebaseServiceAccountJsonB64: String = "",
)
