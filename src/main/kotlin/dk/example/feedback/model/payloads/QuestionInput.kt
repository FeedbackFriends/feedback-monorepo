package dk.example.feedback.model.payloads

import dk.example.feedback.model.enumerations.FeedbackType

data class QuestionInput(
    val questionText: String,
    val feedbackType: FeedbackType,
)

