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
                session: session
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
                session: session,
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
                session: session
            )
        ) {
            EventDetailFeature()
        }

        await store.send(.editButtonTapped) {
            $0.destination = .manageEvent(.edit(activity: activity, event: event))
        }
    }

    @Test
    func `Edit delegate updates event and closes manage event`() async {
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
                session: session
            )
        ) {
            EventDetailFeature()
        }

        await store.send(.destination(.presented(.manageEvent(.delegate(.dismissAndUpdateEvent(updatedEvent)))))) {
            var updatedActivity = activity
            updatedActivity.events = [updatedEvent]
            $0.$session.withLock {
                $0.managerData!.activities[id: activity.id] = updatedActivity
            }
            $0.destination = nil
        }
    }

    @Test
    func `Delete confirmation button deletes event and dismisses detail`() async {
        let (session, activity, event) = makeSession()
        let deletedEventId = LockIsolated<UUID?>(nil)
        let didDismiss = LockIsolated(false)

        let store = TestStore(
            initialState: EventDetailFeature.State(
                activityId: activity.id,
                eventId: event.id,
                session: session
            )
        ) {
            EventDetailFeature()
        } withDependencies: {
            $0.apiClient.deleteEvent = { eventId in
                deletedEventId.setValue(eventId)
            }
            $0.dismiss = .init {
                didDismiss.setValue(true)
            }
        }

        await store.send(.deleteEventButtonTapped) {
            $0.showDeleteConfirmation = true
        }

        await store.send(.deleteEventConfirmButtonTapped) {
            $0.deleteEventInFlight = true
        }

        await store.receive(\.deleteEventSuccess) {
            var updatedActivity = activity
            updatedActivity.events = []
            $0.$session.withLock {
                $0.managerData!.activities[id: activity.id] = updatedActivity
            }
            $0.deleteEventInFlight = false
            $0.showDeleteConfirmation = false
        }

        #expect(deletedEventId.value == event.id)
        #expect(didDismiss.value)
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
    bootstrap.managerData!.activities[id: activity.id] = activity

    return (.init(value: bootstrap), activity, event)
}
