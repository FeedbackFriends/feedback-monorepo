package dk.example.feedback.model.database

import dk.example.feedback.model.enumerations.CalendarProvider
import java.time.OffsetDateTime
import java.util.UUID

data class SessionEntity(
    val id: UUID,
    val activity: ActivityEntity,
    val title: String,
    val agenda: String?,
    val date: OffsetDateTime,
    val durationInMinutes: Int,
    val location: String?,
    val calendarProvider: CalendarProvider?,
    val calendarEventId: String?,
    val createdFromMailListener: Boolean,
    val createdAt: OffsetDateTime,
    val updatedAt: OffsetDateTime,
    val questions: List<QuestionEntity>,
    val feedback: List<FeedbackEntity>,
    val manager: AccountEntity,
)

typealias EventEntity = SessionEntity
