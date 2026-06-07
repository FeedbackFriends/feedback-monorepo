import ComposableArchitecture
import Foundation

@DependencyClient
public struct APIClient: Sendable {
    public var deleteAccount: @Sendable () async throws -> Void
    @DependencyEndpoint
    public var modifyAccount: @Sendable (
        _ name: String,
        _ email: String,
        _ phoneNumber: String
    ) async throws -> Void
    public var linkFCMTokenToAccount: @Sendable (String) async throws -> Void
    public var logout: @Sendable () async throws -> Void
    public var getBootstrap: @Sendable () async throws -> Bootstrap
    @DependencyEndpoint
    public var startFeedbackEvent: @Sendable (_ pinCode: PinCode) async throws -> FeedbackEventDto
    @DependencyEndpoint
    public var submitFeedback: @Sendable (_ feedback: [FeedbackInput], _ pinCode: PinCode) async throws -> Bool
    @DependencyEndpoint
    public var createActivity: @Sendable (_ activityInput: ActivityInput) async throws -> Activity
    @DependencyEndpoint
    public var updateActivity: @Sendable (_ activityInput: ActivityInput, _ id: UUID) async throws -> Activity
    @DependencyEndpoint
    public var deleteActivity: @Sendable (_ id: UUID) async throws -> Void
    @DependencyEndpoint
    public var createEvent: @Sendable (_ sessionInput: SessionInput) async throws -> Event
    @DependencyEndpoint
    public var updateEvent: @Sendable (_ sessionInput: SessionInput, _ id: UUID) async throws -> Event
    @DependencyEndpoint
    public var deleteEvent: @Sendable (_ id: UUID) async throws -> Void
    @DependencyEndpoint
    public var createAccount: @Sendable (_ role: Role?) async throws -> Bootstrap
    public var sessionChangedListener: @Sendable () async -> AsyncStream<Bootstrap> = { .never }
    @DependencyEndpoint
    public var joinEvent: @Sendable (_ pinCode: PinCode) async throws -> ParticipantEvent
    @DependencyEndpoint
    public var markEventAsSeen: @Sendable (_ sessionId: UUID) async throws -> Void
    @DependencyEndpoint
    public var sendNotification: @Sendable (_ input: SendNotificationInput) async throws -> Void
    @DependencyEndpoint
    public var updateRole: @Sendable (_ role: Role) async throws -> Void
    public var getBootstrapUpdate: @Sendable () async throws -> Bootstrap?
    public var markNotificationHistoryAsSeen: @Sendable () async throws -> Void
}
