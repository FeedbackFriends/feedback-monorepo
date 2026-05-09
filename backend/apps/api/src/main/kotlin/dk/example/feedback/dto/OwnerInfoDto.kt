package dk.example.feedback.dto

import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Owner profile metadata shown to participants.")
data class OwnerInfoDto(
    val name: String?,
    val email: String?,
    val phoneNumber: String?,
)
