import SwiftUI
import ComposableArchitecture
import Domain
import DesignSystem
import Logger

@Reducer
public struct TabbarLifecycle: Sendable {
    
    @Reducer
    public enum Destination {
        case alert(AlertState<Never>)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @Shared var session: Session
        var bannerState: BannerState?
		var appLoaded = false
        public init(session: Shared<Session>) {
            self._session = session
        }
    }
    
    public enum Action {
        case onTask
        case sessionUpdated(Session)
        case removeBanner
        case presentNotificationPermissionPrompt
        case delegate(Delegate)
        case enterForeground
        case enterBackground
        public enum Delegate: Equatable {
            case presentNotificationPermissionPrompt
        }
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.continuousClock) var clock
    @Dependency(\.notificationClient) var notificationClient
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .removeBanner:
                state.bannerState = nil
                return .none
                
            case .presentNotificationPermissionPrompt:
                return .send(.delegate(.presentNotificationPermissionPrompt))
                
            case .sessionUpdated(let session):
                state.$session.withLock {
                    $0 = session
                }
                return .none
                
            case .onTask:
				if state.appLoaded {
					return .none
				}
				state.appLoaded = true
                return .merge(
                    .run { [role = state.session.role] send in
                        if await notificationClient
                            .shouldPromptForAuthorization(role: role) {
                            await send(.presentNotificationPermissionPrompt)
                        }
                        let sessionChangedListener = await apiClient.sessionChangedListener()
                        for await session in sessionChangedListener {
                            await send(.sessionUpdated(session))
                        }
                    },
                    .run { _ in
                        for await _ in self.clock.timer(interval: .seconds(10)) {
                            do {
                                _ = try await apiClient.getUpdatedSession()
                            } catch {
                                Logger
                                    .debug(
                                        "Failed to send updated session response: \(error)"
                                    )
                            }
                        }
                    }
                )
                
            case .delegate:
                return .none
                
            case .enterForeground:
                return .none
                
            case .enterBackground:
                return .none
            }
        }
    }
}

extension TabbarLifecycle.Destination.State: Sendable, Equatable {}
