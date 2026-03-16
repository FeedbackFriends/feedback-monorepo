import ComposableArchitecture
import Domain
import Logger

@Reducer
public struct NotificationPermissionPrompt: Sendable {

    @ObservableState
    public struct State: Equatable, Sendable {
        var isSubmitting = false

        public init() {}
    }

    public enum Action: Equatable {
        case enablePushNotificationsButtonTap
        case enableEmailsButtonTap
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case completed
        }
    }

    public init() {}
    
    @Dependency(\.notificationClient) var notificationClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .enablePushNotificationsButtonTap:
                guard !state.isSubmitting else { return .none }
                state.isSubmitting = true
                return .run { [notificationClient] send in
                    do {
                        _ = try await notificationClient.requestAuthorization()
                    } catch {
                        Logger.debug("Failed to request notification authorization: \(error.localizedDescription)")
                    }
                    await send(.delegate(.completed))
                }

            case .enableEmailsButtonTap:
                guard !state.isSubmitting else { return .none }
                state.isSubmitting = true
                return .send(.delegate(.completed))

            case .delegate:
                return .none
            }
        }
    }
}
