package dk.example.feedback.model.payloads

import java.time.OffsetDateTime

data class EventInput(
    val title: String,
    val agenda: String?,
    val date: OffsetDateTime,
    val durationInMinutes: Int,
    val location: String?,
    val questions: List<QuestionInput>
)
