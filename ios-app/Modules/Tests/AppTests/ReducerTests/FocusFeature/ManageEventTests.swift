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
    func `Edit event succeeds and returns updated event`() async {
        let activity = Activity.mock()
        let event = Event.mock()
        let updatedEvent = Event.mock()

        let store = TestStore(
            initialState: ManageEvent.State.edit(
                activity: activity,
                event: event
            )
        ) {
            ManageEvent()
        } withDependencies: {
            $0.apiClient.updateEvent = { _, _ in updatedEvent }
            $0.continuousClock = ImmediateClock()
        }

        await store.send(.actionButtonTap) {
            $0.manageEventInFlight = true
        }

        await store.receive(\.manageEventResponse) {
            $0.manageEventInFlight = false
            $0.showSuccessOverlay = true
        }
        await store.receive(\.delegate, .dismissAndUpdateEvent(updatedEvent))
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

    @Test
    func `Edit activity button delegates to parent`() async {
        let store = TestStore(
            initialState: ManageEvent.State.create(activity: Activity.mock())
        ) {
            ManageEvent()
        }

        await store.send(.editActivityButtonTap)
        await store.receive(\.delegate, .editActivity)
    }
}
