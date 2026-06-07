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
