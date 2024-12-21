package dk.example.feedback.model.db_models

import dk.example.feedback.model.*
import java.time.OffsetDateTime
import java.util.*

data class AccountEntity(
    val id: String, //  Provided by firebase uid in idToken
    val fcmToken: String?,
    val name: String?,
    val email: String?,
    val phoneNumber: String?,
//    val role: Role?,
    val ratingPrompted: Boolean,
)

data class EventEntity(
    val id: UUID,
    val title: String,
    val agenda: String?,
    val date: OffsetDateTime,
    val durationInMinutes: Int,
    val pinCode: String,
    val location : String?,
    val createdAt: OffsetDateTime,
    val updatedAt: OffsetDateTime,
    val questions: List<QuestionEntity>,
    val feedback: List<FeedbackEntity>,
    val newFeedback: Int,
    val manager: AccountEntity,
) {
    fun isActive(): Boolean {
        return date.isAfter(OffsetDateTime.now().minusDays(1)) || !feedback.isEmpty()
    }
}

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


data class FeedbackEntity(
    var id: UUID,
    val feedbackType: FeedbackType,
    val comment: String? = null,
    val emoji: Emoji? = null,
    val thumbsUpThumpsDown: ThumbsUpThumpsDown? = null,
    val opinion: Opinion? = null,
    val oneToTen: Int? = null,
    val questionId: UUID,
    val participantId: String?,
)

data class EventParticipantEntity(val event: EventEntity, val participant: AccountEntity, val feedback: FeedbackEntity?)

//data class TeamEntity(
//    val id: UUID,
//    val teamName: String,
//    val teamMembers: List<TeamMember>,
//    val manager: AccountEntity,
//) {
//    data class TeamMember(
//        val account: AccountEntity,
//        val memberStatus: TeamMemberStatus,
//    )
//}
//
