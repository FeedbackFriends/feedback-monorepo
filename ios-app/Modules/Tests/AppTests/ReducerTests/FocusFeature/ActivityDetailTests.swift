@testable import FocusFeature
import ComposableArchitecture
import Domain
import Foundation
import Testing

@MainActor
struct ActivityDetailTests {

    @Test
    func `Delete confirmation button deletes activity and dismisses detail`() async {
        let session: Shared<Bootstrap> = .init(value: .mock(numberOfManagerEvents: 1))
        let activity = session.wrappedValue.managerData!.activities[0]
        let deletedActivityId = LockIsolated<UUID?>(nil)
        let didDismiss = LockIsolated(false)

        let store = await TestStore(
            initialState: ActivityDetail.State(
                activityId: activity.id,
                session: session
            )
        ) {
            ActivityDetail()
        } withDependencies: {
            $0.apiClient.deleteActivity = { id in
                deletedActivityId.setValue(id)
            }
            $0.continuousClock = ImmediateClock()
            $0.dismiss = .init {
                didDismiss.setValue(true)
            }
        }

        await store.send(.deleteActivityButtonTap) {
            $0.showDeleteConfirmation = true
            $0.deleteActivityInFlight = false
        }

        await store.send(.deleteActivityConfirmButtonTap) {
            $0.deleteActivityInFlight = true
        }

        await store.receive(\.deleteActivitySuccess) {
            $0.deleteActivityInFlight = false
            $0.showDeleteConfirmation = false
            $0.showDeleteSuccessOverlay = true
        }

        #expect(deletedActivityId.value == activity.id)
        #expect(didDismiss.value)
    }

    @Test
    func `Delete confirmation button shows alert when deletion fails`() async {
        struct Failure: Error, Equatable {}

        let session: Shared<Bootstrap> = .init(value: .mock(numberOfManagerEvents: 1))
        let activity = session.wrappedValue.managerData!.activities[0]

        let store = await TestStore(
            initialState: ActivityDetail.State(
                activityId: activity.id,
                session: session
            )
        ) {
            ActivityDetail()
        } withDependencies: {
            $0.apiClient.deleteActivity = { _ in
                throw Failure()
            }
            $0.continuousClock = ImmediateClock()
        }

        await store.send(.deleteActivityButtonTap) {
            $0.showDeleteConfirmation = true
            $0.deleteActivityInFlight = false
        }

        await store.send(.deleteActivityConfirmButtonTap) {
            $0.deleteActivityInFlight = true
        }

        await store.receive(\.presentError) {
            $0.deleteActivityInFlight = false
            $0.alert = .init(error: Failure())
        }
    }

    @Test
    func `Cancel button closes delete confirmation`() async {
        let session: Shared<Bootstrap> = .init(value: .mock(numberOfManagerEvents: 1))
        let activity = session.wrappedValue.managerData!.activities[0]

        let store = await TestStore(
            initialState: ActivityDetail.State(
                activityId: activity.id,
                session: session
            )
        ) {
            ActivityDetail()
        }

        await store.send(.deleteActivityButtonTap) {
            $0.showDeleteConfirmation = true
            $0.deleteActivityInFlight = false
        }

        await store.send(.deleteActivityCancelButtonTap) {
            $0.showDeleteConfirmation = false
            $0.deleteActivityInFlight = false
        }
    }
}
