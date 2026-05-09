package dk.example.feedback.payloads

import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Input payload for updating account profile information.")
data class ModifyAccountInput(
    val name: String?,
    val email: String?,
    val phoneNumber: String?,
)
