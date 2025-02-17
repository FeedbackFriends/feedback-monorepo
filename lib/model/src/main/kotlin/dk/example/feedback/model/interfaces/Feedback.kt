package dk.example.feedback.model.interfaces

import dk.example.feedback.model.enumerations.Emoji
import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.model.enumerations.Opinion
import dk.example.feedback.model.enumerations.ThumbsUpThumpsDown
import java.util.*

interface Feedback {
    val feedbackType: FeedbackType
    val comment: String?
    val emoji: Emoji?
    val thumbsUpThumpsDown: ThumbsUpThumpsDown?
    val opinion: Opinion?
    val oneToTen: Int?
    val questionId: UUID
}
