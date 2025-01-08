package dk.example.feedback.model.database

import java.time.OffsetDateTime
import java.util.*

data class EventEntity(
    val id: UUID,
    val title: String,
    val agenda: String?,
    val date: OffsetDateTime,
    val durationInMinutes: Int,
    val location : String?,
    val createdAt: OffsetDateTime,
    val updatedAt: OffsetDateTime,
    val questions: List<QuestionEntity>,
    val feedback: List<FeedbackEntity>,
    val manager: AccountEntity,
)



