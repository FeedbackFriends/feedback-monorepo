package dk.example.feedback.model.database


import dk.example.feedback.model.enumerations.Emoji
import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.model.enumerations.Opinion
import dk.example.feedback.model.enumerations.ThumbsUpThumpsDown
import dk.example.feedback.model.interfaces.Feedback
import java.time.OffsetDateTime
import java.util.*

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
    val seenByManager: Boolean,
    val createdAt: OffsetDateTime,
): Feedback
