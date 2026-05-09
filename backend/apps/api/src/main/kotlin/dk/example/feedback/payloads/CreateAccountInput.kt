package dk.example.feedback.payloads

import dk.example.feedback.model.enumerations.Role
import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Input payload for account creation during first authentication.")
data class CreateAccountInput(
    @field:Schema(description = "Requested role for the new account.")
    val requestedRole: Role?,
    val fcmToken: String?
)
