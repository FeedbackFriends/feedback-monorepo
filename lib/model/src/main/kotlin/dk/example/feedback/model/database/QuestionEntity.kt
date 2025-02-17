package dk.example.feedback.model.database

import dk.example.feedback.model.enumerations.FeedbackType
import java.time.OffsetDateTime
import java.util.*

data class QuestionEntity(
    val id: UUID,
    val questionText: String,
    val feedbackType: FeedbackType,
    val createdAt: OffsetDateTime,
    val updatedAt: OffsetDateTime,
    val index: Int,
    val feedback: List<FeedbackEntity>,
    val managerId: String,
)
