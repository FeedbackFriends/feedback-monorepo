import ComposableArchitecture
import UserNotifications

@DependencyClient
public struct NotificationClient: Sendable {
    @DependencyEndpoint
    public var shouldPromptForAuthorization: @Sendable (_ role: Role?) async -> Bool = { _ in false }
    public var requestAuthorization: @Sendable () async throws -> Bool
    @DependencyEndpoint
    public var scheduleLocalNotification: @Sendable (
        _ title: String,
        _ body: String,
        _ userInfo: [AnyHashable: Any],
        _ presentAfterDelayInSeconds: Int,
        _ id: String
    ) -> Void
    @DependencyEndpoint
    public var removeLocalPendingNotificationRequests: @Sendable (_ ids: [String]) async -> Void
}
