@testable import FocusFeature
@testable import FocusFeature
import Testing
import ComposableArchitecture
import Foundation
import Domain

@MainActor
struct ManagerEventsTests {
    
    @Test
    func `Manager event detail view is shown and event is marked as seen when dismissed`() async {
        let session: Shared<Bootstrap> = .init(value: .mock(numberOfManagerEvents: 2))
        let mockEvent = session.wrappedValue.managerData!.managerEvents[0]
        let eventMarkedAsSeen = LockIsolated<UUID?>(nil)
        let store = TestStore(initialState: ActivityList.State(session: session)) {
            ActivityList()
        } withDependencies: {
            $0.apiClient.markEventAsSeen = { @MainActor in
                eventMarkedAsSeen.setValue($0)
            }
        }
        await store.send(.activityTap(mockEvent)) {
            $0.destination = .activityDetail(
                ActivityDetail.State.init(
                    eventId: mockEvent.id,
                    detail: mockEvent,
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

    @Test
    func `Create activity success navigates to new activity detail`() async {
        let session: Shared<Bootstrap> = .init(value: .mock(numberOfManagerEvents: 1))
        let createdActivity = Activity.mock()
        let store = TestStore(initialState: ActivityList.State(session: session)) {
            ActivityList()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
        }

        await store.send(.createActivityButtonTap) {
            $0.destination = .manageActivity(.init())
        }

        await store.send(.destination(.presented(.manageActivity(.delegate(.dismissAndNavigateToDetail(createdActivity)))))) {
            $0.destination = nil
        }

        await store.receive(\.navigateToCreatedActivity, createdActivity) {
            $0.destination = .activityDetail(
                ActivityDetail.State(
                    eventId: createdActivity.id,
                    detail: createdActivity.event,
                    session: session
                )
            )
        }
    }
}
