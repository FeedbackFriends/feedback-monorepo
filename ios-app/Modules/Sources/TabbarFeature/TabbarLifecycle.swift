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
        @Shared var bootstrap: Bootstrap
        var bannerState: BannerState?
        var syncPhase: SyncIndicatorPhase = .idle
        var isForeground = true
        var hasConfirmedSync = false
        var activeSyncID: UUID?
		var appLoaded = false
        public init(bootstrap: Shared<Bootstrap>) {
            self._bootstrap = bootstrap
        }
    }
    
    public enum Action {
        case onTask
        case sessionUpdated(Bootstrap)
        case removeBanner
        case presentNotificationPermissionPrompt
        case delegate(Delegate)
        case enterForeground
        case enterBackground
        case syncStarted(UUID)
        case syncFinished(UUID, succeeded: Bool)
        case hideSyncSuccess
        public enum Delegate: Equatable {
            case presentNotificationPermissionPrompt
        }
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.continuousClock) var clock
    @Dependency(\.notificationClient) var notificationClient
    @Dependency(\.uuid) var uuid

    private enum CancelID { case syncSuccess }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .removeBanner:
                state.bannerState = nil
                return .none
                
            case .presentNotificationPermissionPrompt:
                return .send(.delegate(.presentNotificationPermissionPrompt))
                
            case .sessionUpdated(let session):
                state.$bootstrap.withLock {
                    $0 = session
                }
                return .none
                
            case .onTask:
				if state.appLoaded {
					return .none
				}
                state.appLoaded = true
                return .merge(
                    .run { [role = state.bootstrap.role] send in
                        if await notificationClient
                            .shouldPromptForAuthorization(role: role) {
                            await send(.presentNotificationPermissionPrompt)
                        }
                        let sessionChangedListener = await apiClient.sessionChangedListener()
                        for await session in sessionChangedListener {
                            await send(.sessionUpdated(session))
                        }
                    },
                    .run { [uuid, role = state.bootstrap.role] send in
                        guard role == .manager else { return }
                        for await _ in self.clock.timer(interval: .seconds(10)) {
                            let requestID = uuid()
                            await send(.syncStarted(requestID))
                            do {
                                _ = try await apiClient.getBootstrapUpdate()
                                await send(.syncFinished(requestID, succeeded: true))
                            } catch {
                                await send(.syncFinished(requestID, succeeded: false))
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
                state.isForeground = true
                return .none
                
            case .enterBackground:
                state.isForeground = false
                state.activeSyncID = nil
                state.hasConfirmedSync = false
                state.syncPhase = .idle
                return .cancel(id: CancelID.syncSuccess)

            case .syncStarted(let id):
                guard state.isForeground, state.bootstrap.role == .manager else { return .none }
                state.activeSyncID = id
                state.syncPhase = .syncing
                return .cancel(id: CancelID.syncSuccess)

            case .syncFinished(let id, let succeeded):
                guard state.isForeground, state.activeSyncID == id else { return .none }
                state.activeSyncID = nil
                guard succeeded, !state.hasConfirmedSync else {
                    state.syncPhase = .idle
                    return .none
                }
                state.hasConfirmedSync = true
                state.syncPhase = .success
                return .run { send in
                    try await clock.sleep(for: .milliseconds(800))
                    await send(.hideSyncSuccess)
                }
                .cancellable(id: CancelID.syncSuccess, cancelInFlight: true)

            case .hideSyncSuccess:
                state.syncPhase = .idle
                return .none
            }
        }
    }
}

extension TabbarLifecycle.Destination.State: Sendable, Equatable {}
