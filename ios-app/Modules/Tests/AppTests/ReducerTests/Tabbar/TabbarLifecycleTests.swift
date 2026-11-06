@testable import TabbarFeature
import ComposableArchitecture
import Domain
import Foundation
import Testing

@MainActor
struct TabbarLifecycleTests {
    @Test
    func successAppearsOncePerForegroundAndDoesNotFollowFailures() async {
        let clock = TestClock()
        let store = TestStore(initialState: TabbarLifecycle.State(bootstrap: .init(value: .mock()))) {
            TabbarLifecycle()
        } withDependencies: {
            $0.continuousClock = clock
        }
        let first = UUID()
        await store.send(.syncStarted(first)) {
            $0.activeSyncID = first
            $0.syncPhase = .syncing
        }
        await store.send(.syncFinished(first, succeeded: false)) {
            $0.activeSyncID = nil
            $0.syncPhase = .idle
        }
        let second = UUID()
        await store.send(.syncStarted(second)) {
            $0.activeSyncID = second
            $0.syncPhase = .syncing
        }
        await store.send(.syncFinished(second, succeeded: true)) {
            $0.activeSyncID = nil
            $0.hasConfirmedSync = true
            $0.syncPhase = .success
        }
        await clock.advance(by: .milliseconds(800))
        await store.receive(\.hideSyncSuccess) { $0.syncPhase = .idle }
        let third = UUID()
        await store.send(.syncStarted(third)) {
            $0.activeSyncID = third
            $0.syncPhase = .syncing
        }
        await store.send(.syncFinished(third, succeeded: true)) {
            $0.activeSyncID = nil
            $0.syncPhase = .idle
        }
        await store.send(.enterBackground) {
            $0.isForeground = false
            $0.hasConfirmedSync = false
        }
        await store.send(.enterForeground) { $0.isForeground = true }
        await store.send(.syncStarted(first)) {
            $0.activeSyncID = first
            $0.syncPhase = .syncing
        }
        await store.send(.syncFinished(first, succeeded: true)) {
            $0.activeSyncID = nil
            $0.hasConfirmedSync = true
            $0.syncPhase = .success
        }
        await store.send(.enterBackground) {
            $0.isForeground = false
            $0.hasConfirmedSync = false
            $0.syncPhase = .idle
        }
        await clock.advance(by: .seconds(1))
    }

    @Test
    func backgroundClearsPresentationAndRejectsLateResponses() async {
        let store = TestStore(initialState: TabbarLifecycle.State(bootstrap: .init(value: .mock()))) {
            TabbarLifecycle()
        }
        let id = UUID()
        await store.send(.syncStarted(id)) {
            $0.activeSyncID = id
            $0.syncPhase = .syncing
        }
        await store.send(.enterBackground) {
            $0.isForeground = false
            $0.activeSyncID = nil
            $0.syncPhase = .idle
        }
        await store.send(.enterForeground) { $0.isForeground = true }
        await store.send(.syncFinished(id, succeeded: true))
    }

    @Test
    func anonymousUsersDoNotShowManagerSyncPresentation() async {
        let store = TestStore(initialState: TabbarLifecycle.State(bootstrap: .init(value: .mockAnonymous()))) {
            TabbarLifecycle()
        }
        let id = UUID()
        await store.send(.syncStarted(id))
        await store.send(.syncFinished(id, succeeded: true))
    }
}
