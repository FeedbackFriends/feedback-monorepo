package dk.example.feedback.model.payloads

import dk.example.feedback.model.Emoji
import dk.example.feedback.model.Feedback
import dk.example.feedback.model.FeedbackType
import dk.example.feedback.model.Opinion
import dk.example.feedback.model.ThumbsUpThumpsDown
import java.util.*

data class FeedbackInput(
    override val comment: String?,
    override val emoji: Emoji?,
    override val thumbsUpThumpsDown: ThumbsUpThumpsDown?,
    override val opinion: Opinion?,
    override val oneToTen: Int?,
    override val questionId: UUID,
    override val feedbackType: FeedbackType,
): Feedback
