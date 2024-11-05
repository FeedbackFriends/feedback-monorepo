package dk.example.feedback.model


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