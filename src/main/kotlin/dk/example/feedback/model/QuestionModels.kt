package dk.example.feedback.model

import dk.example.feedback.model.db_models.FeedbackEntity
import java.util.*

data class ManagerQuestion(
    val id: UUID,
    val questionText: String,
    val feedbackType: FeedbackType,
    val feedback: List<FeedbackEntity>?,
    val feedbackSummary: QuestionFeedbackSummary?,
    val newFeedbackForQuestion: Int,
)

data class QuestionFeedbackSummary(
    val totalFeedback: Int,
    val verySadCount: Int,
    val sadCount: Int,
    val happyCount: Int,
    val veryHappyCount: Int,
)

data class ParticipantQuestion(
    val id: UUID,
    val questionText: String,
    val feedbackType: FeedbackType,
)
