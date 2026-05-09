package dk.example.feedback.payloads

import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Input payload to link an FCM token to the authenticated account.")
data class LinkFCMTokenToAccountInput(
    @field:Schema(description = "Firebase Cloud Messaging token for push notifications.")
    val fcmToken: String
)
