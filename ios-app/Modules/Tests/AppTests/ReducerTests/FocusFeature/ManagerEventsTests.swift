@testable import ActivityFeature
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
            $0.path.append(.activityDetail(
                ActivityDetail.State(
                    activityId: activity.id,
                    bootstrap: bootstrap
                )
            ))
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
            $0.destination = .manageActivity(.create())
        }

        await store.send(.destination(.presented(.manageActivity(.delegate(.dismissAndNavigateToDetail(createdActivity)))))) {
            $0.destination = nil
        }

        await store.withExhaustivity(.off) {
            await store.receive(\.navigateToCreatedActivity, createdActivity)
        }
        #expect(store.state.path.count == 1)
        #expect(store.state.path.last?.activityDetail?.activityId == createdActivity.id)
        #expect(bootstrap.wrappedValue.managerData?.activities[id: createdActivity.id] == createdActivity)
    }
}
