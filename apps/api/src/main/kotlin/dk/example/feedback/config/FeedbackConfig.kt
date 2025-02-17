package dk.example.feedback.config

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "feedback")
data class FeedbackConfig (
    val firebaseApiKey: String,
    val firebaseConfigPath: String,
    val version: String,
)
