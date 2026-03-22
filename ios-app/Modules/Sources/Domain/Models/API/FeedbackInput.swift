import Foundation

public struct FeedbackInput: Equatable, Sendable {
    public let type: FeedbackTypeWithData
    public let questionId: UUID
    public init(type: FeedbackTypeWithData, questionId: UUID) {
        self.type = type
        self.questionId = questionId
    }
}
