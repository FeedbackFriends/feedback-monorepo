import Foundation

public typealias ActivityDto = Activity
public typealias BootstrapDto = Bootstrap
public typealias EventDto = Event
public typealias ParticipantEventDto = ParticipantEvent

public struct SubmitFeedbackResponseDto: Equatable, Sendable {
    public let shouldPresentRatingPrompt: Bool
    public let event: ParticipantEventDto

    public init(
        shouldPresentRatingPrompt: Bool,
        event: ParticipantEventDto
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
