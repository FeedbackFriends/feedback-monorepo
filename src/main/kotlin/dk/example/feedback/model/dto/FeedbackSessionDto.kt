package dk.example.feedback.model.dto

import dk.example.feedback.model.*
import dk.example.feedback.model.db_models.EventEntity
import dk.example.feedback.model.db_models.FeedbackEntity
import java.time.OffsetDateTime
import java.util.*

data class FeedbackSessionDto(
    val title: String,
    val agenda: String?,
    val questions: List<ParticipantQuestion>,
    val managerInfo: ManagerInfoDto
)

data class ManagerInfoDto(
    val name: String?,
    val email: String?,
    val phoneNumber: String?
)

data class ManagerEventDto(
    val id: UUID,
    val title: String,
    val agenda: String?,
    val date: OffsetDateTime,
    val durationInMinutes: Int,
    val pinCode: String,
    val location : String?,
    val feedbackSummary: FeedbackSummaryDto?,
    val questions: List<ManagerQuestion>,
    val newFeedback: Int,
    val managerName: String,
)
data class ParticipantEventDto (
    var id: UUID,
    val title: String,
    val agenda: String?,
    val pinCode: String,
    val date: OffsetDateTime,
    val durationInMinutes: Int,
    val location: String?,
//    val teamName: String?,
    val questions: List<ParticipantQuestion>,
    val feedbackProvided: Boolean,
)

