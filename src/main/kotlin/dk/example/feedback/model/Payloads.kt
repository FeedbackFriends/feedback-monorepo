package dk.example.feedback.model

import java.time.OffsetDateTime

data class EventInput(
    val title: String,
    val agenda: String?,
    val date: OffsetDateTime,
    val durationInMinutes: Int,
    val location: String?,
    val questions: List<QuestionInput>
)

data class FeedbackSummaryDto(
    val totalFeedback: Int,
    val verySadPercentage: Double,
    val sadPercentage: Double,
    val happyPercentage: Double,
    val veryHappyPercentage: Double,
)

data class QuestionInput(
    val questionText: String,
    val feedbackType: FeedbackType,
)



