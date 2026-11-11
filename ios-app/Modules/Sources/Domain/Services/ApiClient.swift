import ComposableArchitecture
import Foundation

@DependencyClient
public struct APIClient: Sendable {
    public var answerSuggestionEvaluation: @Sendable (_ teamID: String, _ suggestionID: String, _ evaluationID: String, _ answer: EvaluationAnswer) async throws -> [Suggestion]
    public var listSuggestions: @Sendable (_ teamID: String) async throws -> [Suggestion]
    public var createSuggestion: @Sendable (_ teamID: String, _ id: UUID, _ problem: String, _ impact: String, _ solution: String?) async throws -> [Suggestion]
    public var setSuggestionSupport: @Sendable (_ teamID: String, _ suggestionID: String, _ supported: Bool) async throws -> [Suggestion]
    public var reportSuggestion: @Sendable (_ teamID: String, _ suggestionID: String) async throws -> [Suggestion]
    public var withdrawSuggestion: @Sendable (_ teamID: String, _ suggestionID: String) async throws -> [Suggestion]
    public var getTeamContext: @Sendable () async throws -> EmployeeTeamContext
    @DependencyEndpoint
    public var requestTeamMembership: @Sendable (_ id: UUID, _ code: String, _ name: String) async throws -> EmployeeTeamContext
    @DependencyEndpoint
    public var cancelTeamRequest: @Sendable (_ id: String) async throws -> EmployeeTeamContext
    @DependencyEndpoint
    public var leaveTeam: @Sendable (_ id: String) async throws -> EmployeeTeamContext
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
    public var getBootstrapUpdate: @Sendable () async throws -> Bootstrap?
    public var markNotificationHistoryAsSeen: @Sendable () async throws -> Void
    public var submitProductContact: @Sendable (ProductContactInput) async throws -> ProductContactReceipt
}
