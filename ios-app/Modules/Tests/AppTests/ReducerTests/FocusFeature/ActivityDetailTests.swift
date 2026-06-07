@testable import FocusFeature
import ComposableArchitecture
import Domain
import Foundation
import Testing

@MainActor
struct ActivityDetailTests {

    @Test
    func `Delete confirmation button deletes activity and dismisses detail`() async {
        let bootstrap: Shared<Bootstrap> = .init(value: .mock(numberOfManagerEvents: 1))
        let activity = bootstrap.wrappedValue.managerData!.activities[0]
        let deletedActivityId = LockIsolated<UUID?>(nil)
        let didDismiss = LockIsolated(false)

        let store = await TestStore(
            initialState: ActivityDetail.State(
                activityId: activity.id,
                bootstrap: bootstrap
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
            $0.destination = .showDeleteConfirmation
            $0.deleteActivityInFlight = false
        }

        await store.send(.deleteActivityConfirmButtonTap) {
            $0.deleteActivityInFlight = true
        }

        await store.receive(\.deleteActivitySuccess) {
            $0.deleteActivityInFlight = false
            $0.destination = nil
        }

        #expect(deletedActivityId.value == activity.id)
        #expect(didDismiss.value)
    }

    @Test
    func `Delete confirmation button shows alert when deletion fails`() async {
        struct Failure: Error, Equatable {}

        let bootstrap: Shared<Bootstrap> = .init(value: .mock(numberOfManagerEvents: 1))
        let activity = bootstrap.wrappedValue.managerData!.activities[0]

        let store = await TestStore(
            initialState: ActivityDetail.State(
                activityId: activity.id,
                bootstrap: bootstrap
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
            $0.destination = .showDeleteConfirmation
            $0.deleteActivityInFlight = false
        }

        await store.send(.deleteActivityConfirmButtonTap) {
            $0.deleteActivityInFlight = true
        }

        await store.receive(\.presentError) {
            $0.deleteActivityInFlight = false
            $0.destination = .alert(.init(error: Failure()))
        }
    }

    @Test
    func `Cancel button closes delete confirmation`() async {
        let bootstrap: Shared<Bootstrap> = .init(value: .mock(numberOfManagerEvents: 1))
        let activity = bootstrap.wrappedValue.managerData!.activities[0]

        let store = await TestStore(
            initialState: ActivityDetail.State(
                activityId: activity.id,
                bootstrap: bootstrap
            )
        ) {
            ActivityDetail()
        }

        await store.send(.deleteActivityButtonTap) {
            $0.destination = .showDeleteConfirmation
            $0.deleteActivityInFlight = false
        }

        await store.send(.deleteActivityCancelButtonTap) {
            $0.destination = nil
            $0.deleteActivityInFlight = false
        }
    }

    @Test
    func `Event tap pushes session detail`() async {
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
        let sharedBootstrap: Shared<Bootstrap> = .init(value: bootstrap)

        let store = TestStore(
            initialState: ActivityDetail.State(
                activityId: activity.id,
                bootstrap: sharedBootstrap
            )
        ) {
            ActivityDetail()
        }

        await store.send(.eventTapped(event)) {
            $0.destination = .eventDetail(
                EventDetailFeature.State(
                    activityId: activity.id,
                    eventId: event.id,
                    bootstrap: sharedBootstrap
                )
            )
        }
    }

    @Test
    func `Create session delegate closes sheet and navigates to session detail with invite`() async {
        let event = Event(
            id: UUID(),
            date: Date(timeIntervalSince1970: 1_000),
            pinCode: PinCode(value: "1234"),
            durationInMinutes: 30,
            overallFeedbackSummary: nil,
            questionsSnapshot: [],
            calendarProvider: nil
        )
        let bootstrap: Shared<Bootstrap> = .init(value: .mock(numberOfManagerEvents: 1))
        let activity = bootstrap.wrappedValue.managerData!.activities[0]

        let store = TestStore(
            initialState: ActivityDetail.State(
                activityId: activity.id,
                destination: .manageEvent(.create(activity: activity)),
                bootstrap: bootstrap
            )
        ) {
            ActivityDetail()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
        }

        await store.send(.destination(.presented(.manageEvent(.delegate(.dismissAndNavigateToEvent(event)))))) {
            $0.destination = nil
        }

        await store.receive(.navigateToEvent(event, presentInvite: true)) {
            var updatedActivity = activity
            updatedActivity.events = [event]
            $0.$bootstrap.withLock {
                $0.managerData!.activities[id: activity.id] = updatedActivity
            }
            $0.destination = .eventDetail(
                EventDetailFeature.State(
                    activityId: activity.id,
                    eventId: event.id,
                    destination: .invite(event),
                    bootstrap: bootstrap
                )
            )
        }
    }

    @Test
    func `Manage event edit activity delegate opens activity editor`() async {
        let bootstrap: Shared<Bootstrap> = .init(value: .mock(numberOfManagerEvents: 1))
        let activity = bootstrap.wrappedValue.managerData!.activities[0]

        let store = TestStore(
            initialState: ActivityDetail.State(
                activityId: activity.id,
                destination: .manageEvent(.create(activity: activity)),
                bootstrap: bootstrap
            )
        ) {
            ActivityDetail()
        }

        await store.send(.destination(.presented(.manageEvent(.delegate(.editActivity))))) {
            $0.destination = .editActivity(ManageActivity.State.edit(activity: activity))
        }
    }

    @Test
    func `Event detail edit activity delegate opens activity editor`() async {
        let bootstrap: Shared<Bootstrap> = .init(value: .mock(numberOfManagerEvents: 1))
        let activity = bootstrap.wrappedValue.managerData!.activities[0]
        let event = activity.events[0]

        let store = TestStore(
            initialState: ActivityDetail.State(
                activityId: activity.id,
                destination: .eventDetail(
                    EventDetailFeature.State(
                        activityId: activity.id,
                        eventId: event.id,
                        bootstrap: bootstrap
                    )
                ),
                bootstrap: bootstrap
            )
        ) {
            ActivityDetail()
        }

        await store.send(.destination(.presented(.eventDetail(.delegate(.editActivity))))) {
            $0.destination = .editActivity(ManageActivity.State.edit(activity: activity))
        }
    }

    @Test
    func `Session grouping puts three closest events in active section`() {
        let now = Self.date(day: 7, hour: 12)
        let farPrevious = Self.event(id: 1, date: Self.date(day: 1, hour: 10))
        let today = Self.event(id: 2, date: Self.date(day: 7, hour: 10))
        let tomorrow = Self.event(id: 3, date: Self.date(day: 8, hour: 10))
        let closeComingUp = Self.event(id: 4, date: Self.date(day: 7, hour: 13))
        let farComingUp = Self.event(id: 5, date: Self.date(day: 12, hour: 10))

        let grouping = ActivityDetailSessionGrouping(
            events: [farComingUp, today, farPrevious, tomorrow, closeComingUp],
            now: now,
            calendar: Self.calendar
        )

        #expect(grouping.sections.map(\.title) == ["Aktuelt", "Kommende", "Tidligere"])
        #expect(grouping.sections[0].events.map(\.id) == [closeComingUp.id, today.id, tomorrow.id])
        #expect(grouping.sections[1].events.map(\.id) == [farComingUp.id])
        #expect(grouping.sections[2].events.map(\.id) == [farPrevious.id])
        #expect(grouping.activeSections.map(\.title) == ["Aktuelt"])
        #expect(grouping.comingUpSections.map(\.title) == ["Kommende"])
        #expect(grouping.previousSections.map(\.title) == ["Tidligere"])
        #expect(grouping.hasSessionsOutsideActive)
    }

    @Test
    func `Active sessions with unseen responses sort before closer sessions`() {
        let now = Self.date(day: 7, hour: 12)
        let closeWithoutUnseen = Self.event(id: 1, date: Self.date(day: 7, hour: 12, minute: 30))
        let fartherWithUnseen = Self.event(id: 2, date: Self.date(day: 6, hour: 16), unseenResponses: 2)
        let secondClosestWithoutUnseen = Self.event(id: 3, date: Self.date(day: 7, hour: 10))

        let grouping = ActivityDetailSessionGrouping(
            events: [closeWithoutUnseen, fartherWithUnseen, secondClosestWithoutUnseen],
            now: now,
            calendar: Self.calendar
        )

        #expect(grouping.sections.map(\.title) == ["Aktuelt"])
        #expect(grouping.activeSections.map(\.title) == ["Aktuelt"])
        #expect(grouping.sections[0].events.map(\.id) == [
            fartherWithUnseen.id,
            closeWithoutUnseen.id,
            secondClosestWithoutUnseen.id
        ])
    }

    @Test
    func `Upcoming and previous sessions sort from most relevant edge`() {
        let now = Self.date(day: 7, hour: 12)
        let activeOne = Self.event(id: 1, date: Self.date(day: 7, hour: 13))
        let activeTwo = Self.event(id: 2, date: Self.date(day: 7, hour: 14))
        let activeThree = Self.event(id: 3, date: Self.date(day: 7, hour: 15))
        let earliestUpcoming = Self.event(id: 4, date: Self.date(day: 9, hour: 9))
        let laterUpcoming = Self.event(id: 5, date: Self.date(day: 12, hour: 9))
        let newestPrevious = Self.event(id: 6, date: Self.date(day: 5, hour: 9))
        let olderPrevious = Self.event(id: 7, date: Self.date(day: 1, hour: 9))

        let grouping = ActivityDetailSessionGrouping(
            events: [laterUpcoming, olderPrevious, activeTwo, earliestUpcoming, newestPrevious, activeOne, activeThree],
            now: now,
            calendar: Self.calendar
        )

        #expect(grouping.sections.map(\.title) == ["Aktuelt", "Kommende", "Tidligere"])
        #expect(grouping.comingUpSections[0].events.map(\.id) == [earliestUpcoming.id, laterUpcoming.id])
        #expect(grouping.previousSections[0].events.map(\.id) == [newestPrevious.id, olderPrevious.id])
    }

    @Test
    func `Session grouping omits empty sections`() {
        let now = Self.date(day: 7, hour: 12)
        let active = Self.event(id: 1, date: Self.date(day: 7, hour: 13))

        let grouping = ActivityDetailSessionGrouping(
            events: [active],
            now: now,
            calendar: Self.calendar
        )

        #expect(grouping.sections.map(\.title) == ["Aktuelt"])
        #expect(grouping.activeSections.map(\.title) == ["Aktuelt"])
        #expect(grouping.comingUpSections.isEmpty)
        #expect(grouping.previousSections.isEmpty)
        #expect(grouping.hasSessionsOutsideActive == false)
    }
}

private extension ActivityDetailTests {
    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    static func date(day: Int, hour: Int, minute: Int = 0) -> Date {
        DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: 2026,
            month: 6,
            day: day,
            hour: hour,
            minute: minute
        )
        .date!
    }

    static func event(id: Int, date: Date, unseenResponses: Int = 0) -> Event {
        Event(
            id: UUID.mockUUID(forIndex: id),
            date: date,
            pinCode: PinCode(value: "1234"),
            durationInMinutes: 30,
            overallFeedbackSummary: unseenResponses > 0 ? feedbackSummary(unseenResponses: unseenResponses) : nil,
            questionsSnapshot: [],
            calendarProvider: nil
        )
    }

    static func feedbackSummary(unseenResponses: Int) -> OverallFeedbackSummary {
        OverallFeedbackSummary(
            segmentationStats: FeedbackSegmentationStats(
                verySadPercentage: 0,
                sadPercentage: 0,
                happyPercentage: 50,
                veryHappyPercentage: 50
            ),
            countStats: FeedbackCountStats(
                verySadCount: 0,
                sadCount: 0,
                happyCount: 1,
                veryHappyCount: 1,
                commentsCount: 0
            ),
            unseenResponses: unseenResponses,
            responses: 2
        )
    }
}
