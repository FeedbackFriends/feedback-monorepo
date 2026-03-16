@testable import TabbarFeature
import ComposableArchitecture
import Foundation
import Testing
@testable import Domain

@MainActor
struct TabbarLifecycleTests {

    @Test
    func `onTask triggers visible sync and auto-hides success state`() async {
        let clock = TestClock()
        let store = TestStore(
            initialState: .init(
                session: .init(value: .mock()),
                syncStatus: .init(value: .init())
            )
        ) {
            TabbarLifecycle()
        } withDependencies: {
            $0.continuousClock = clock
            $0.apiClient.getUpdatedSession = { .mock() }
            $0.apiClient.sessionChangedListener = { .never }
        }
        store.exhaustivity = .off

        await store.send(.onTask) {
            $0.appLoaded = true
        }
        await store.receive(\.triggerSync, .visible) {
            $0.visibleSyncGeneration = 1
            $0.isVisibleSyncInFlight = true
            $0.$syncStatus.withLock {
                $0.visibleSyncState = .syncing
                $0.isSyncing = true
            }
        }
        await store.receive(\.visibleSyncCompleted)
        #expect(store.state.syncStatus.visibleSyncState == .synced)
        #expect(store.state.syncStatus.lastUpdatedAt != nil)
        #expect(store.state.syncStatus.isSyncing == false)
        #expect(store.state.isVisibleSyncInFlight == false)

        await clock.advance(by: .seconds(2))
        await store.receive(\.hideVisibleSync) {
            $0.$syncStatus.withLock {
                $0.visibleSyncState = .hidden
            }
        }
    }

    @Test
    func `background poll sync does not show visible sync chip`() async {
        let pollCalls = LockIsolated(0)
        let store = TestStore(
            initialState: .init(
                session: .init(value: .mock()),
                syncStatus: .init(value: .init())
            )
        ) {
            TabbarLifecycle()
        } withDependencies: {
            $0.apiClient.getUpdatedSession = {
                pollCalls.withValue { $0 += 1 }
                return .mock()
            }
        }

        await store.send(.triggerSync(.backgroundPoll)) {
            $0.$syncStatus.withLock {
                $0.isSyncing = true
            }
        }
        #expect(store.state.syncStatus.visibleSyncState == .hidden)
        #expect(pollCalls.value == 1)
    }

    @Test
    func `enterForeground triggers visible sync when app already loaded`() async {
        let clock = TestClock()
        var initialState = TabbarLifecycle.State(
            session: .init(value: .mock()),
            syncStatus: .init(value: .init())
        )
        initialState.appLoaded = true
        let store = TestStore(initialState: initialState) {
            TabbarLifecycle()
        } withDependencies: {
            $0.continuousClock = clock
            $0.apiClient.getUpdatedSession = { .mock() }
        }

        await store.send(.enterForeground)
        await store.receive(\.triggerSync, .visible) {
            $0.visibleSyncGeneration = 1
            $0.isVisibleSyncInFlight = true
            $0.$syncStatus.withLock {
                $0.visibleSyncState = .syncing
                $0.isSyncing = true
            }
        }
        await store.receive(\.visibleSyncCompleted)
        #expect(store.state.syncStatus.visibleSyncState == .synced)
    }

    @Test
    func `enterBackground clears visible sync state`() async {
        var initialState = TabbarLifecycle.State(
            session: .init(value: .mock()),
            syncStatus: .init(value: .init(isSyncing: true, visibleSyncState: .synced))
        )
        initialState.visibleSyncGeneration = 2
        initialState.isVisibleSyncInFlight = true

        let store = TestStore(initialState: initialState) {
            TabbarLifecycle()
        }

        await store.send(.enterBackground) {
            $0.visibleSyncGeneration = 3
            $0.isVisibleSyncInFlight = false
            $0.$syncStatus.withLock {
                $0.visibleSyncState = .hidden
                $0.isSyncing = false
            }
        }
    }

    @Test
    func `failed visible sync hides chip and never shows success`() async {
        let store = TestStore(
            initialState: .init(
                session: .init(value: .mock()),
                syncStatus: .init(value: .init())
            )
        ) {
            TabbarLifecycle()
        } withDependencies: {
            $0.apiClient.getUpdatedSession = { throw URLError(.badServerResponse) }
        }

        await store.send(.triggerSync(.visible)) {
            $0.visibleSyncGeneration = 1
            $0.isVisibleSyncInFlight = true
            $0.$syncStatus.withLock {
                $0.visibleSyncState = .syncing
                $0.isSyncing = true
            }
        }
        await store.receive(\.visibleSyncCompleted)
        #expect(store.state.syncStatus.visibleSyncState == .hidden)
        #expect(store.state.syncStatus.isSyncing == false)
    }
}
