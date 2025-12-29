package dk.example.feedback.dto

data class SubmitFeedbackResponseDto(
    val shouldPresentRatingPrompt: Boolean,
    val event: ParticipantEventDto,
)
