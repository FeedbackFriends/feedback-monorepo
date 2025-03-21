package dk.example.feedback

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "feedback")
data class FeedbackConfig(
    val firebaseApiKey: String,
    val firebaseConfigPath: String,
    val version: String,
)
