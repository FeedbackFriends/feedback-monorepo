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
    val location: String?,
    val isDraft: Boolean,
    val ownerInfo: OwnerInfoDto,
    val overallFeedbackSummary: OverallFeedbackSummaryDto?,
    val invitedEmails: List<String>,
    val questions: List<ManagerQuestion>,
)

data class ManagerQuestion(
    val id: UUID,
    val questionText: String,
    val feedbackType: FeedbackType,
    val feedback: List<FeedbackEntity>,
    val questionFeedbackSummary: QuestionFeedbackSummaryDto?,
)
