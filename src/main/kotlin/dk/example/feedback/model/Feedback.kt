package dk.example.feedback.model

import java.util.*

enum class Opinion {
    StronglyDisagree, Disagree, Neutral, Agree, StronglyAgree, NoOpinion
}

enum class FeedbackType {
    Emoji, Comment, ThumpsUpThumpsDown, Opinion, OneToTen
}

enum class ThumbsUpThumpsDown {
    Up, Down
}

enum class Emoji {
    VerySad, Sad, Happy, VeryHappy
}

interface Feedback {
    val feedbackType: FeedbackType
    val comment: String?
    val emoji: Emoji?
    val thumbsUpThumpsDown: ThumbsUpThumpsDown?
    val opinion: Opinion?
    val oneToTen: Int?
    val questionId: UUID
}
