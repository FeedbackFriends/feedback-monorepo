import SwiftUI
import Foundation
import ComposableArchitecture
import Domain
import DesignSystem
import Logger

@Reducer
public struct TabbarLifecycle: Sendable {

    public enum SyncTrigger: Sendable, Equatable {
        case visible
        case backgroundPoll
    }
    
    @Reducer
    public enum Destination {
        case alert(AlertState<Never>)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @Shared var session: Session
        @Shared var syncStatus: SyncStatus
        var bannerState: BannerState?
        var appLoaded = false
        var visibleSyncGeneration = 0
        var isVisibleSyncInFlight = false
        public init(
            session: Shared<Session>,
            syncStatus: Shared<SyncStatus>
        ) {
            self._session = session
            self._syncStatus = syncStatus
        }
    }
    
    public enum Action {
        case onTask
        case sessionUpdated(Session)
        case removeBanner
        case enterForeground
        case enterBackground
        case triggerSync(SyncTrigger)
        case visibleSyncCompleted(syncGeneration: Int, didSucceed: Bool)
        case hideVisibleSync(syncGeneration: Int)
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.continuousClock) var clock
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .removeBanner:
                state.bannerState = nil
                return .none
                
            case .sessionUpdated(let session):
                state.$session.withLock {
                    $0 = session
                }
                state.$syncStatus.withLock {
                    $0.lastUpdatedAt = Date()
                }
                return .none
                
            case .onTask:
                if state.appLoaded {
                    return .none
                }
                state.appLoaded = true
                return .merge(
                    .run { send in
                        let sessionChangedListener = await apiClient.sessionChangedListener()
                        for await session in sessionChangedListener {
                            await send(.sessionUpdated(session))
                        }
                    },
                    .run { send in
                        for await _ in self.clock.timer(interval: .seconds(10)) {
                            await send(.triggerSync(.backgroundPoll))
                        }
                    },
                    .send(.triggerSync(.visible))
                )
                
            case .enterForeground:
                guard state.appLoaded else {
                    return .none
                }
                return .send(.triggerSync(.visible))
                
            case .enterBackground:
                state.visibleSyncGeneration += 1
                state.isVisibleSyncInFlight = false
                state.$syncStatus.withLock {
                    $0.visibleSyncState = .hidden
                    $0.isSyncing = false
                }
                return .none

            case .triggerSync(let trigger):
                let syncStatus = state.$syncStatus
                switch trigger {
                case .visible:
                    guard !state.isVisibleSyncInFlight else {
                        return .none
                    }
                    state.visibleSyncGeneration += 1
                    let generation = state.visibleSyncGeneration
                    state.isVisibleSyncInFlight = true
                    syncStatus.withLock {
                        $0.visibleSyncState = .syncing
                        $0.isSyncing = true
                    }
                    return .run { send in
                        do {
                            _ = try await apiClient.getUpdatedSession()
                            await send(.visibleSyncCompleted(syncGeneration: generation, didSucceed: true))
                        } catch {
                            Logger.debug("Failed to send updated session response: \(error)")
                            await send(.visibleSyncCompleted(syncGeneration: generation, didSucceed: false))
                        }
                    }

                case .backgroundPoll:
                    guard !state.syncStatus.isSyncing else {
                        return .none
                    }
                    syncStatus.withLock {
                        $0.isSyncing = true
                    }
                    return .run { _ in
                        defer {
                            syncStatus.withLock {
                                $0.isSyncing = false
                            }
                        }
                        do {
                            _ = try await apiClient.getUpdatedSession()
                        } catch {
                            Logger.debug("Failed to send updated session response: \(error)")
                        }
                    }
                }

            case let .visibleSyncCompleted(syncGeneration, didSucceed):
                guard syncGeneration == state.visibleSyncGeneration else {
                    return .none
                }
                state.isVisibleSyncInFlight = false
                if didSucceed {
                    state.$syncStatus.withLock {
                        $0.isSyncing = false
                        $0.lastUpdatedAt = Date()
                        $0.visibleSyncState = .synced
                    }
                    return .run { send in
                        try? await self.clock.sleep(for: .seconds(2))
                        await send(.hideVisibleSync(syncGeneration: syncGeneration))
                    }
                } else {
                    state.$syncStatus.withLock {
                        $0.isSyncing = false
                        $0.visibleSyncState = .hidden
                    }
                    return .none
                }

            case .hideVisibleSync(let syncGeneration):
                guard syncGeneration == state.visibleSyncGeneration else {
                    return .none
                }
                state.$syncStatus.withLock {
                    if $0.visibleSyncState == .synced {
                        $0.visibleSyncState = .hidden
                    }
                }
                return .none
            }
        }
    }
}

extension TabbarLifecycle.Destination.State: Sendable, Equatable {}
