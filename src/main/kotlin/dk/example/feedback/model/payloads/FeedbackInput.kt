package dk.example.feedback.model.payloads

import dk.example.feedback.model.enumerations.Emoji
import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.model.enumerations.Opinion
import dk.example.feedback.model.enumerations.ThumbsUpThumpsDown
import dk.example.feedback.model.interfaces.Feedback
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
