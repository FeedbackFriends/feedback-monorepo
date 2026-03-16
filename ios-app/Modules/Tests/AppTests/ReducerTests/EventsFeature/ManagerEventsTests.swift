@testable import EventsFeature
import Testing
import ComposableArchitecture
import Foundation
import Domain

@MainActor
struct ManagerEventsTests {
    
    @Test
    func `Manager event detail view is shown and event is marked as seen when dismissed`() async {
        let session: Shared<Session> = .init(value: .mock(numberOfManagerEvents: 2))
        let mockEvent = session.wrappedValue.managerData!.managerEvents[0]
        let eventMarkedAsSeen = LockIsolated<UUID?>(nil)
        let store = TestStore(initialState: ManagerEvents.State(session: session)) {
            ManagerEvents()
        } withDependencies: {
            $0.apiClient.markEventAsSeen = { @MainActor in
                eventMarkedAsSeen.setValue($0)
            }
        }
        await store.send(.managerEventTap(mockEvent)) {
            $0.destination = .eventDetail(
                EventDetailFeature.State.init(
                    event: mockEvent,
                    session: session
                )
            )
        }
        #expect(eventMarkedAsSeen.value == nil, "Event not marked as seen when tapped")
        await store.send(.destination(.dismiss)) {
            $0.destination = nil
        }
        #expect(eventMarkedAsSeen.value == mockEvent.id, "Event should be marked as seen when navigating back from detail")
    }
}
