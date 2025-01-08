package dk.example.feedback.model.database

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
    val location : String?,
    val createdAt: OffsetDateTime,
    val updatedAt: OffsetDateTime,
    val questions: List<QuestionEntity>,
    val feedback: List<FeedbackEntity>,
    val manager: AccountEntity,
)

data class PinCodeEntity(
    val id: UUID,
    val pinCode: String,
    val createdAt: OffsetDateTime,
    val updatedAt: OffsetDateTime,
)

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
    val id: UUID,
    override val feedbackType: FeedbackType,
    override val comment: String? = null,
    override val emoji: Emoji? = null,
    override val thumbsUpThumpsDown: ThumbsUpThumpsDown? = null,
    override val opinion: Opinion? = null,
    override val oneToTen: Int? = null,
    override val questionId: UUID,
    val participantId: String?,
    val isNew: Boolean,
): Feedback

data class EventParticipantEntity(
    val event: EventEntity,
    val participant: AccountEntity,
    val feedback: FeedbackEntity?
)
