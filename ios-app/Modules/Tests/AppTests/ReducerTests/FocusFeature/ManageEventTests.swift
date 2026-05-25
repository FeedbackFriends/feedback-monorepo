@testable import FocusFeature
import Testing
import ComposableArchitecture
import Foundation
import Domain

@MainActor
struct ManageEventTests {
    @Test
    func `Create event succeeds and navigates to detail`() async {
        let activity = Activity.mock()
        let mockEvent = Event.mock()

        let store = TestStore(
            initialState: ManageEvent.State.create(activity: activity)
        ) {
            ManageEvent()
        } withDependencies: {
            $0.apiClient.createEvent = { _ in mockEvent }
            $0.continuousClock = ImmediateClock()
        }

        await store.send(.actionButtonTap) {
            $0.manageEventInFlight = true
        }

        await store.receive(\.manageEventResponse) {
            $0.manageEventInFlight = false
            $0.showSuccessOverlay = true
        }
        await store.receive(\.delegate, .dismissAndNavigateToEvent(mockEvent))
    }

    @Test
    func `Create event failure shows error alert`() async {
        struct Failure: Error, Equatable {}

        let store = TestStore(
            initialState: ManageEvent.State.create(activity: Activity.mock())
        ) {
            ManageEvent()
        } withDependencies: {
            $0.apiClient.createEvent = { _ in throw Failure() }
        }

        await store.send(.actionButtonTap) {
            $0.manageEventInFlight = true
        }

        await store.receive(\.presentError) {
            $0.manageEventInFlight = false
            $0.alert = .init(error: Failure())
        }
    }

    @Test
    func `Edit event succeeds and dismisses`() async {
        let activity = Activity.mock()
        let event = Event.mock()

        let store = TestStore(
            initialState: ManageEvent.State.edit(
                activity: activity,
                event: event
            )
        ) {
            ManageEvent()
        } withDependencies: {
            $0.apiClient.updateEvent = { _, _ in .mock() }
            $0.continuousClock = ImmediateClock()
        }

        await store.send(.actionButtonTap) {
            $0.manageEventInFlight = true
        }

        await store.receive(\.manageEventResponse) {
            $0.manageEventInFlight = false
            $0.showSuccessOverlay = true
        }
        await store.receive(\.delegate, .dismiss)
    }

    @Test
    func `Edit event failure shows error alert`() async {
        struct Failure: Error, Equatable {}

        let store = TestStore(
            initialState: ManageEvent.State.edit(
                activity: Activity.mock(),
                event: Event.mock()
            )
        ) {
            ManageEvent()
        } withDependencies: {
            $0.apiClient.updateEvent = { _, _ in throw Failure() }
        }

        await store.send(.actionButtonTap) {
            $0.manageEventInFlight = true
        }

        await store.receive(\.presentError) {
            $0.manageEventInFlight = false
            $0.alert = .init(error: Failure())
        }
    }
}
