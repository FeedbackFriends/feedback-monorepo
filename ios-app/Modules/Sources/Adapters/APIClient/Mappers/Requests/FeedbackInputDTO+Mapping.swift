import Domain
import OpenAPI
import Utility

public extension Components.Schemas.FeedbackInput.ThumbsUpThumpsDownPayload {
    init(input: ThumbsUpThumpsDown) {
        self.init(rawValue: input.rawValue.uppercasingFirst())!
    }
}

public extension Components.Schemas.FeedbackInput.EmojiPayload {
    init(input: Emoji) {
        self.init(rawValue: input.rawValue.uppercasingFirst())!
    }
}

public extension Components.Schemas.FeedbackInput.OpinionPayload {
    init(input: Opinion) {
        self.init(rawValue: input.rawValue.uppercasingFirst())!
    }
}

public extension Components.Schemas.FeedbackInput {
    init(_ feedback: FeedbackInput) {
        switch feedback.type {
        case .emoji(emoji: let emoji, comment: let optionalComment):
            self.init(
                comment: optionalComment,
                emoji: .init(input: emoji),
                questionId: feedback.questionId.uuidString,
                feedbackType: .emoji
            )
        case .comment(comment: let comment):
            self.init(
                comment: comment,
                questionId: feedback.questionId.uuidString,
                feedbackType: .comment
            )
        case .thumpsUpThumpsDown(thumbsUpThumpsDown: let thumbsUpThumpsDown, comment: let optionalComment):
            self.init(
                comment: optionalComment,
                thumbsUpThumpsDown: .init(input: thumbsUpThumpsDown),
                questionId: feedback.questionId.uuidString,
                feedbackType: .thumpsUpThumpsDown
            )
        case .opinion(opinion: let opinion, comment: let optionalComment):
            self.init(
                comment: optionalComment,
                opinion: .init(input: opinion),
                questionId: feedback.questionId.uuidString,
                feedbackType: .opinion
            )
        case .zeroToTen(zeroToTen: let zeroToTen, comment: let optionalComment):
            self.init(
                comment: optionalComment,
                zeroToTen: Int32(zeroToTen),
                questionId: feedback.questionId.uuidString,
                feedbackType: .zeroToTen
            )
        }
    }
}
