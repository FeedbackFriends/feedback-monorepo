import ComposableArchitecture
import Foundation

@DependencyClient
public struct APIClient: Sendable {
    public var deleteAccount: @Sendable () async throws -> Void
    @DependencyEndpoint
    public var updateAccount: @Sendable (
        _ name: String,
        _ email: String,
        _ phoneNumber: String
    ) async throws -> Void
    public var linkFCMTokenToAccount: @Sendable (String) async throws -> Void
    public var logout: @Sendable () async throws -> Void
    public var getSession: @Sendable () async throws -> Session
    @DependencyEndpoint
    public var startFeedbackSession: @Sendable (_ pinCode: PinCode) async throws -> FeedbackSession
    @DependencyEndpoint
    public var submitFeedback: @Sendable (_ feedback: [FeedbackInput], _ pinCode: PinCode) async throws -> Bool
    @DependencyEndpoint
    public var createEvent: @Sendable (_ eventInput: EventInput) async throws -> ManagerEvent
    @DependencyEndpoint
    public var updateEvent: @Sendable (_ eventInput: EventInput, _ id: UUID) async throws -> ManagerEvent
    @DependencyEndpoint
    public var deleteEvent: @Sendable (_ id: UUID) async throws -> Void
    @DependencyEndpoint
    public var createAccount: @Sendable (_ role: Role?) async throws -> Session
    public var sessionChangedListener: @Sendable () async -> AsyncStream<Session> = { .never }
    @DependencyEndpoint
    public var joinEvent: @Sendable (_ pinCode: PinCode) async throws -> Void
    @DependencyEndpoint
    public var markEventAsSeen: @Sendable (_ eventId: UUID) async throws -> Void
    @DependencyEndpoint
    public var updateAccountRole: @Sendable (_ role: Role) async throws -> Void
    public var getMockToken: @Sendable () async throws -> (String)
    public var getUpdatedSession: @Sendable () async throws -> Session?
    public var markActivityAsSeen: @Sendable () async throws -> Void
}
