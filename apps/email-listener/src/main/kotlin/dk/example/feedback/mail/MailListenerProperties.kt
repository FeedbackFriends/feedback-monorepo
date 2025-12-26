package dk.example.feedback.mail

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "feedback.mail")
data class MailListenerProperties(
    val host: String,
    val port: Int = 993,
    val username: String,
    val password: String,
    val folder: String = "INBOX",
)
