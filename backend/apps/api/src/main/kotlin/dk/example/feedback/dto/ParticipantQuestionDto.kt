package dk.example.feedback.dto

import dk.example.feedback.model.enumerations.FeedbackType
import java.util.*

data class ParticipantQuestionDto(
    val id: UUID,
    val questionText: String,
    val feedbackType: FeedbackType,
)
