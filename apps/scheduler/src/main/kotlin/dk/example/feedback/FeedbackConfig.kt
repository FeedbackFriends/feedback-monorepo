package dk.example.feedback

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "feedback")
data class FeedbackConfig(
    val firebaseApiKey: String,
    val firebaseConfigPath: String,
    val version: String,
    val mail: MailSettings,
) {
    data class MailSettings(
        val host: String,
        val port: Int = 993,
        val username: String,
        val password: String,
        val folder: String = "INBOX",
    )
}
