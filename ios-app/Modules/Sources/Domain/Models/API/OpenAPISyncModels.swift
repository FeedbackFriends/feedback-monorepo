import Foundation

public struct SubmitFeedbackResponseDto: Equatable, Sendable {
    public let shouldPresentRatingPrompt: Bool
    public let event: ParticipantEvent

    public init(
        shouldPresentRatingPrompt: Bool,
        event: ParticipantEvent
    ) {
        self.shouldPresentRatingPrompt = shouldPresentRatingPrompt
        self.event = event
    }
}

public struct MockTokenDto: Equatable, Sendable {
    public let token: String

    public init(token: String) {
        self.token = token
    }
}
