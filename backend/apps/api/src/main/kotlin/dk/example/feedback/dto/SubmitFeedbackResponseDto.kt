package dk.example.feedback.dto

import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Response returned after participant feedback submission.")
data class SubmitFeedbackResponseDto(
    @field:Schema(description = "Signals whether the client should show an app-rating prompt.")
    val shouldPresentRatingPrompt: Boolean,
    val session: ParticipantSessionDto,
) {
    val event: ParticipantSessionDto
        get() = session
}
