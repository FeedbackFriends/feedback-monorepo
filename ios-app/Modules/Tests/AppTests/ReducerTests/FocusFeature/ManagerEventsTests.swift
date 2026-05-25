@testable import FocusFeature
import Testing
import ComposableArchitecture
import Foundation
import Domain

@MainActor
struct ManagerEventsTests {
    
    @Test
    func `Activity tap pushes activity detail`() async {
        let bootstrap: Shared<Bootstrap> = .init(value: .mock(numberOfManagerEvents: 2))
        let activity = bootstrap.wrappedValue.managerData!.activities[0]
        let store = TestStore(initialState: ActivityList.State(bootstrap: bootstrap)) {
            ActivityList()
        }

        await store.send(.activityTap(activity)) {
            $0.destination = .activityDetail(
                ActivityDetail.State(
                    activityId: activity.id,
                    bootstrap: bootstrap
                )
            )
        }
    }

    @Test
    func `Create activity success navigates to new activity detail`() async {
        let bootstrap: Shared<Bootstrap> = .init(value: .mock(numberOfManagerEvents: 1))
        let createdActivity = Activity.mock()
        let store = TestStore(initialState: ActivityList.State(bootstrap: bootstrap)) {
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
                    activityId: createdActivity.id,
                    bootstrap: bootstrap
                )
            )
        }
    }
}
