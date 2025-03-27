package dk.example.feedback.dto

import dk.example.feedback.model.database.FeedbackEntity
import dk.example.feedback.model.enumerations.FeedbackType
import java.time.OffsetDateTime
import java.util.*

data class ManagerEventDto(
    val id: UUID,
    val title: String,
    val agenda: String?,
    val date: OffsetDateTime,
    val pinCode: String?,
    val durationInMinutes: Int,
    val location : String?,
    val ownerInfo: OwnerInfoDto,
    val feedbackBar: FeedbackBarDto?,
    val questions: List<ManagerQuestion>,
    val newFeedbackForEvent: Int,
)

data class ManagerQuestion(
    val id: UUID,
    val questionText: String,
    val feedbackType: FeedbackType,
    val feedback: List<FeedbackEntity>,
    val feedbackSummary: QuestionFeedbackSummary?,
)

data class QuestionFeedbackSummary(
    val feedbackBar: FeedbackBarDto,
    val verySadCount: Int,
    val sadCount: Int,
    val happyCount: Int,
    val veryHappyCount: Int,
    val commentsCount: Int,
)
