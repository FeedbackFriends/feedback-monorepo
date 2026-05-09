package dk.example.feedback.payloads

import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Input payload for account logout and device token unlink.")
data class LogoutInput(
    @field:Schema(description = "Firebase Cloud Messaging token to remove from the account.")
    val fcmToken: String
)
