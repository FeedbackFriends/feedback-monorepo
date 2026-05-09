package dk.example.feedback.payloads

import dk.example.feedback.model.enumerations.Role
import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Input payload for changing the authenticated account role.")
data class UpdateRoleInput(
    @field:Schema(description = "Target role for the account.")
    val role: Role
)
