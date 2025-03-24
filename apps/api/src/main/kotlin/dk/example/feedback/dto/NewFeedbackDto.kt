package dk.example.feedback.dto

data class NewFeedbackDto(
    val event: ManagerEventDto,
    val newFeedback: Int
)
