@testable import ActivityFeature
import Testing
import ComposableArchitecture
import Foundation
import Domain

@MainActor
struct ManagerEventsTests {
    @Test
    func `Deleting notification session pops its route and confirms on activity list`() async {
        let bootstrap: Shared<Bootstrap> = .init(value: .mock(numberOfManagerEvents: 1))
        let activity = bootstrap.wrappedValue.managerData!.activities[0]
        let event = Event.mock()
        bootstrap.withLock { $0.managerData!.activities[id: activity.id]!.events = [event] }
        let clock = TestClock()
        let store = TestStore(initialState: ActivityList.State(bootstrap: bootstrap)) {
            ActivityList()
        } withDependencies: {
            $0.continuousClock = clock
            $0.apiClient.deleteEvent = { id in
                bootstrap.withLock { $0.managerData!.activities[id: activity.id]!.events.removeAll { $0.id == id } }
            }
        }
        await store.send(.eventTap(activityId: activity.id, eventId: event.id)) {
            $0.path.append(.eventDetail(.init(activityId: activity.id, eventId: event.id, bootstrap: bootstrap)))
        }
        let id = store.state.path.ids.last!
        await store.send(.path(.element(id: id, action: .eventDetail(.deleteEventConfirmButtonTapped)))) {
            var detail = $0.path[id: id]!.eventDetail!
            detail.deleteEventInFlight = true
            $0.path[id: id] = .eventDetail(detail)
        }
        await store.receive(\.path[id: id].eventDetail.deleteEventSuccess) {
            $0.$bootstrap.withLock { $0.managerData!.activities[id: activity.id]!.events.removeAll { $0.id == event.id } }
            var detail = $0.path[id: id]!.eventDetail!
            detail.deleteEventInFlight = false
            detail.wasDeleted = true
            $0.path[id: id] = .eventDetail(detail)
        }
        await store.receive(\.path[id: id].eventDetail.delegate, .eventDeleted) {
            $0.path.removeAll()
            $0.confirmation.queue("Session slettet")
        }
        #expect(store.state.path.isEmpty)
        #expect(bootstrap.wrappedValue.managerData!.activities[id: activity.id]!.events.contains { $0.id == event.id } == false)
        #expect(!store.state.confirmation.isPresented)
        await clock.advance(by: .seconds(2))
        await store.send(.confirmation(.transitionCompleted)) {
            $0.confirmation.isPending = false
            $0.confirmation.isPresented = true
        }
        await clock.advance(by: .seconds(1))
        await store.receive(\.confirmation.dismiss) {
            $0.confirmation.isPresented = false
        }
    }

    @Test
    func `Deleting last activity returns immediately to empty list and briefly confirms deletion`() async {
        let bootstrap: Shared<Bootstrap> = .init(value: .mock(numberOfManagerEvents: 1))
        let activity = bootstrap.wrappedValue.managerData!.activities[0]
        bootstrap.withLock { $0.managerData!.activities = [activity] }
        let clock = TestClock()
        let store = TestStore(initialState: ActivityList.State(bootstrap: bootstrap)) {
            ActivityList()
        } withDependencies: {
            $0.continuousClock = clock
            $0.apiClient.deleteActivity = { id in
                bootstrap.withLock { $0.managerData!.activities.remove(id: id) }
            }
        }

        await store.send(.activityTap(activity)) {
            $0.path.append(.activityDetail(.init(activityId: activity.id, bootstrap: bootstrap)))
        }
        let detailId = store.state.path.ids.last!
        await store.send(.path(.element(id: detailId, action: .activityDetail(.deleteActivityConfirmButtonTap)))) {
            var detail = $0.path[id: detailId]!.activityDetail!
            detail.deleteActivityInFlight = true
            $0.path[id: detailId] = .activityDetail(detail)
        }
        await store.receive(\.path[id: detailId].activityDetail.deleteActivitySuccess) {
            $0.$bootstrap.withLock { $0.managerData!.activities.remove(id: activity.id) }
            var detail = $0.path[id: detailId]!.activityDetail!
            detail.deleteActivityInFlight = false
            detail.activityWasDeleted = true
            $0.path[id: detailId] = .activityDetail(detail)
        }
        await store.receive(\.path[id: detailId].activityDetail.delegate, .activityDeleted) {
            $0.path.removeAll()
            $0.confirmation.queue("Aktivitet slettet")
        }
        #expect(store.state.activities.isEmpty)
        #expect(store.state.path.isEmpty)

        #expect(!store.state.confirmation.isPresented)
        await clock.advance(by: .seconds(2))
        await store.send(.confirmation(.transitionCompleted)) {
            $0.confirmation.isPending = false
            $0.confirmation.isPresented = true
        }
        await clock.advance(by: .seconds(1))
        await store.receive(\.confirmation.dismiss) {
            $0.confirmation.isPresented = false
        }
    }
    
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
            $0.pendingCreatedActivity = createdActivity
        }
        #expect(store.state.path.isEmpty)
        await store.send(.activityEditorDismissed) {
            $0.pendingCreatedActivity = nil
            $0.$bootstrap.withLock { $0.managerData!.activities.updateOrAppend(createdActivity) }
        }
        await store.withExhaustivity(.off) {
            await store.receive(\.navigateToCreatedActivity, createdActivity)
        }
        #expect(store.state.path.last?.activityDetail?.confirmation.isPending == true)
        #expect(store.state.path.last?.activityDetail?.confirmation.isPresented == false)
        #expect(store.state.path.last?.activityDetail?.confirmation.message == "Aktivitet oprettet")
        #expect(store.state.path.count == 1)
        #expect(store.state.path.last?.activityDetail?.activityId == createdActivity.id)
        #expect(bootstrap.wrappedValue.managerData?.activities[id: createdActivity.id] == createdActivity)
    }
}
