package dk.example.feedback.payloads

import java.time.OffsetDateTime

data class EventInput(
    val title: String,
    val agenda: String?,
    val date: OffsetDateTime,
    val durationInMinutes: Int,
    val location: String?,
    val questions: List<QuestionInput>
)
