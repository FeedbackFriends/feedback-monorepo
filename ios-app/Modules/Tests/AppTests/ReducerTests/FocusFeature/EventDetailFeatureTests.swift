@testable import ActivityFeature
import ComposableArchitecture
import Domain
import Foundation
import Testing

@MainActor
struct EventDetailFeatureTests {
    @Test
    func `On task marks session as seen once`() async {
        let (session, activity, event) = makeSession()
        let markedEventIds = LockIsolated<[UUID]>([])

        let store = TestStore(
            initialState: EventDetailFeature.State(
                activityId: activity.id,
                eventId: event.id,
                bootstrap: session
            )
        ) {
            EventDetailFeature()
        } withDependencies: {
            $0.apiClient.markEventAsSeen = { eventId in
                markedEventIds.withValue { $0.append(eventId) }
            }
            $0.systemClient.webBaseUrl = { URL(string: "https://example.com")! }
        }

        await store.send(.onTask) {
            $0.webBaseUrl = URL(string: "https://example.com")!
            $0.hasMarkedAsSeen = true
        }

        await store.send(.onTask)

        #expect(markedEventIds.value == [event.id])
    }

    @Test
    func `Invite button presents invite state`() async {
        let (session, activity, event) = makeSession()

        let store = TestStore(
            initialState: EventDetailFeature.State(
                activityId: activity.id,
                eventId: event.id,
                bootstrap: session,
                webBaseUrl: URL(string: "https://example.com")
            )
        ) {
            EventDetailFeature()
        }

        await store.send(.inviteButtonTapped) {
            $0.destination = .invite(event)
        }
    }

    @Test
    func `Edit button presents manage event`() async {
        let (session, activity, event) = makeSession()

        let store = TestStore(
            initialState: EventDetailFeature.State(
                activityId: activity.id,
                eventId: event.id,
                bootstrap: session
            )
        ) {
            EventDetailFeature()
        }

        await store.send(.editButtonTapped) {
            $0.destination = .manageEvent(.edit(activity: activity, event: event))
        }
    }

    @Test
    func `Edit delegate closes manage event`() async {
        let (session, activity, event) = makeSession()
        let updatedEvent = Event(
            id: event.id,
            date: Date(timeIntervalSince1970: 2_000),
            pinCode: PinCode(value: "5678"),
            durationInMinutes: 60,
            location: "Copenhagen",
            overallFeedbackSummary: nil,
            questionsSnapshot: [],
            calendarProvider: nil
        )

        let store = TestStore(
            initialState: EventDetailFeature.State(
                activityId: activity.id,
                eventId: event.id,
                destination: .manageEvent(.edit(activity: activity, event: event)),
                bootstrap: session
            )
        ) {
            EventDetailFeature()
        }

        await store.send(.destination(.presented(.manageEvent(.delegate(.dismissAndUpdateEvent(updatedEvent)))))) {
            $0.destination = nil
            $0.confirmation.queue("Session gemt")
        }
    }

    @Test
    func `Delete confirmation button deletes event and tells parent to close detail`() async {
        let (session, activity, event) = makeSession()
        let deletedEventId = LockIsolated<UUID?>(nil)

        let store = TestStore(
            initialState: EventDetailFeature.State(
                activityId: activity.id,
                eventId: event.id,
                bootstrap: session
            )
        ) {
            EventDetailFeature()
        } withDependencies: {
            $0.apiClient.deleteEvent = { eventId in
                deletedEventId.setValue(eventId)
            }
        }

        await store.send(.deleteEventButtonTapped) {
            $0.showDeleteConfirmation = true
        }

        await store.send(.deleteEventConfirmButtonTapped) {
            $0.deleteEventInFlight = true
        }

        await store.receive(\.deleteEventSuccess) {
            $0.deleteEventInFlight = false
            $0.showDeleteConfirmation = false
            $0.wasDeleted = true
        }
        await store.send(.deleteConfirmationDismissed)
        await store.receive(\.delegate, .eventDeleted)

        #expect(deletedEventId.value == event.id)
    }

    @Test
    func `Delete failure keeps the session open and presents an error`() async {
        let (bootstrap, activity, event) = makeSession()
        let error = URLError(.cannotConnectToHost)
        let store = TestStore(initialState: EventDetailFeature.State(
            activityId: activity.id, eventId: event.id, bootstrap: bootstrap
        )) {
            EventDetailFeature()
        } withDependencies: {
            $0.apiClient.deleteEvent = { _ in throw error }
        }

        await store.send(.deleteEventConfirmButtonTapped) {
            $0.deleteEventInFlight = true
        }
        await store.receive(\.presentError) {
            $0.deleteEventInFlight = false
            $0.alert = .init(error: error)
        }
        #expect(bootstrap.wrappedValue.managerData?.activities[id: activity.id]?.events == [event])
    }

    @Test
    func `Cancel closes the delete confirmation without deleting the session`() async {
        let (bootstrap, activity, event) = makeSession()
        let store = TestStore(initialState: EventDetailFeature.State(
            activityId: activity.id, eventId: event.id, bootstrap: bootstrap
        )) {
            EventDetailFeature()
        }

        await store.send(.deleteEventButtonTapped) {
            $0.showDeleteConfirmation = true
        }
        await store.send(.deleteEventCancelButtonTapped) {
            $0.showDeleteConfirmation = false
        }
        #expect(bootstrap.wrappedValue.managerData?.activities[id: activity.id]?.events == [event])
    }
}

private func makeSession() -> (Shared<Bootstrap>, Activity, Event) {
    let event = Event(
        id: UUID(),
        date: Date(timeIntervalSince1970: 1_000),
        pinCode: PinCode(value: "1234"),
        durationInMinutes: 30,
        overallFeedbackSummary: nil,
        questionsSnapshot: [],
        calendarProvider: nil
    )
    var bootstrap = Bootstrap.mock(numberOfManagerEvents: 1)
    var activity = bootstrap.managerData!.activities[0]
    activity.events = [event]
    activity.questions = []
    bootstrap.managerData!.activities[id: activity.id] = activity

    return (.init(value: bootstrap), activity, event)
}
