import Domain
import Foundation
import OpenAPI
import Utility

extension Feedback {
    init(_ dto: Components.Schemas.QuestionResponseDto) {
        let type: FeedbackTypeWithData
        switch dto.feedbackType {
        case .emoji:
            let value = required(dto.emoji, field: "emoji").rawValue.lowercasingFirst()
            type = .emoji(emoji: required(Emoji(rawValue: value), field: "emoji"), comment: dto.comment)
        case .comment:
            type = .comment(comment: required(dto.comment, field: "comment"))
        case .thumpsUpThumpsDown:
            let value = required(dto.thumbsUpThumpsDown, field: "thumbsUpThumpsDown").rawValue.lowercasingFirst()
            type = .thumpsUpThumpsDown(
                thumbsUpThumpsDown: required(ThumbsUpThumpsDown(rawValue: value), field: "thumbsUpThumpsDown"),
                comment: dto.comment
            )
        case .opinion:
            let value = required(dto.opinion, field: "opinion").rawValue.lowercasingFirst()
            type = .opinion(opinion: required(Opinion(rawValue: value), field: "opinion"), comment: dto.comment)
        case .zeroToTen:
            type = .zeroToTen(zeroToTen: Int(required(dto.zeroToTen, field: "zeroToTen")), comment: dto.comment)
        }
        self.init(
            id: required(UUID(uuidString: dto.id), field: "id"),
            type: type,
            questionId: required(UUID(uuidString: dto.questionId), field: "questionId"),
            seenByManager: dto.seenByManager,
            createdAt: dto.createdAt
        )
    }
}

private func required<Value>(_ value: Value?, field: String) -> Value {
    guard let value else { preconditionFailure("Invalid question response: missing or invalid \(field)") }
    return value
}
