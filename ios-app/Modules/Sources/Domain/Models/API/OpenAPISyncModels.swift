import Foundation

public typealias ActivityDto = Activity
public typealias BootstrapDto = Bootstrap
public typealias ParticipantSessionDto = ParticipantEvent
public typealias FeedbackSessionDto = FeedbackSession

public struct SubmitFeedbackResponseDto: Equatable, Sendable {
    public let shouldPresentRatingPrompt: Bool
    public let session: ParticipantSessionDto
    public let event: ParticipantSessionDto

    public init(
        shouldPresentRatingPrompt: Bool,
        session: ParticipantSessionDto,
        event: ParticipantSessionDto
    ) {
        self.shouldPresentRatingPrompt = shouldPresentRatingPrompt
        self.session = session
        self.event = event
    }
}

public struct MockTokenDto: Equatable, Sendable {
    public let token: String

    public init(token: String) {
        self.token = token
    }
}
