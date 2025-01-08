package dk.example.feedback.model.dto

import dk.example.feedback.model.*
import java.time.OffsetDateTime
import java.util.*

data class FeedbackSessionDto(
    val title: String,
    val agenda: String?,
    val questions: List<ParticipantQuestion>,
    val ownerInfo: OwnerInfoDto,
    val date: OffsetDateTime,
)

data class ManagerEventDto(
    val id: UUID,
    val title: String,
    val agenda: String?,
    val date: OffsetDateTime,
    val pinCode: String,
    val durationInMinutes: Int,
    val location : String?,
    val ownerInfo: OwnerInfoDto,
    val feedbackSummary: FeedbackSummaryDto?,
    val questions: List<ManagerQuestion>,
    val newFeedbackForEvent: Int,
)

data class OwnerInfoDto(
    val name: String?,
    val email: String?,
    val phoneNumber: String?,
)

data class ParticipantEventDto (
    var id: UUID,
    val title: String,
    val agenda: String?,
    val date: OffsetDateTime,
    val pinCode: String,
    val durationInMinutes: Int,
    val location: String?,
    val ownerInfo: OwnerInfoDto,
    val questions: List<ParticipantQuestion>,
    val feedbackSubmited: Boolean,
)

data class FeedbackSummaryDto(
    val totalFeedback: Int,
    val verySadPercentage: Double,
    val sadPercentage: Double,
    val happyPercentage: Double,
    val veryHappyPercentage: Double,
)
