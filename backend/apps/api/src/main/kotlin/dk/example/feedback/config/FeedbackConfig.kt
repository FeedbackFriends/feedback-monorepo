package dk.example.feedback.config

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "feedback")
data class FeedbackConfig(
    val firebaseApiKey: String,
    val firebaseServiceAccountJsonB64: String = "",
    val enableTestAdminEndpoints: Boolean = false,
    val enableTestAdminDatabaseReset: Boolean = false,
    val adminEmails: List<String> = emptyList(),
) {
    val normalizedAdminEmails: Set<String> = adminEmails
        .asSequence()
        .map { it.trim().lowercase() }
        .filter { it.isNotBlank() }
        .toSet()

    init {
        if (!enableTestAdminEndpoints && normalizedAdminEmails.isEmpty()) {
            error("feedback.admin-emails must be configured when feedback.enable-test-admin-endpoints=false")
        }
    }
}
