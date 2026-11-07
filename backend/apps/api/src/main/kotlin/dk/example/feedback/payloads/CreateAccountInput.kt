package dk.example.feedback.payloads

import dk.example.feedback.model.enumerations.Role
import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Input payload for account creation during first authentication.")
data class CreateAccountInput(
    @field:Schema(description = "Legacy field; ignored. Roles are controlled by the server.")
    val requestedRole: Role? = null,
    val fcmToken: String? = null
)
