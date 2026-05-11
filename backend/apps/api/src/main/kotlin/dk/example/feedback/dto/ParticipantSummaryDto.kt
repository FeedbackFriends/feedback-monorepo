package dk.example.feedback.dto

import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Participant identity summary attached to event details.")
data class ParticipantSummaryDto(
    val name: String?,
    val email: String?,
    val phoneNumber: String?,
)
