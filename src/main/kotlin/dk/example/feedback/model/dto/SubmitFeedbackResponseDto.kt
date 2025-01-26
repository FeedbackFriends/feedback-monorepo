package dk.example.feedback.model.dto

data class SubmitFeedbackResponseDto(
    val shouldPresentRatingPrompt: Boolean,
    val event: ParticipantEventDto,
)
