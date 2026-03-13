package dk.example.feedback

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "feedback")
data class FeedbackConfig(
    val firebaseApiKey: String,
    val firebaseServiceAccountJsonB64: String = "",
    val mail: MailSettings,
) {
    data class MailSettings(
        val enabled: Boolean = true,
        val pollIntervalMs: Long = 10_000,
        val apiBaseUrl: String = "https://mail.zoho.eu/api",
        val accountId: String = "",
        val folderId: String = "",
        val pageSize: Int = 50,
        val maxPagesPerPoll: Int = 20,
        val mailboxAddress: String? = null,
        val oauth: OAuthSettings = OAuthSettings(),
    )

    data class OAuthSettings(
        val refreshToken: String? = null,
        val clientId: String? = null,
        val clientSecret: String? = null,
        val tokenUrl: String = "https://accounts.zoho.eu/oauth/v2/token",
    )
}
