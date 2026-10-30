@testable import ActivityFeature
@testable import TabbarFeature
import ComposableArchitecture
import Domain
import Foundation
import Testing
import IssueReportingTestSupport

@MainActor
struct InsightFeatureTests {
    @Test func activityHistoryUsesCanonicalQuestionAndKeepsVersionsSeparate() {
        let canonical = UUID()
        let first = makeEvent(date: 100, canonical: canonical)
        let second = makeEvent(date: 200, canonical: canonical)
        let other = makeEvent(date: 300, canonical: canonical)
        let activity = makeActivity(events: [second, first])
        let data = ActivityInsightData(activity: activity)
        #expect(data.questions.count == 1)
        #expect(data.questions[0].sessions.map(\.event.id) == [first.id, second.id])
        #expect(!data.questions[0].sessions.contains { $0.event.id == other.id })
        #expect(data.responseCount == 2)
        #expect(data.latestFeedbackAt == Date(timeIntervalSince1970: 210))

        var edited = second
        edited.questionsSnapshot = [.init(
            id: UUID(), questionText: "Changed question", feedbackType: .zeroToTen,
            feedback: [], feedbackSummary: nil, activityQuestionId: canonical
        )]
        #expect(ActivityInsightData(activity: makeActivity(events: [first, edited])).questions.count == 2)
    }

    @Test func activitiesOrderByResponseTimestampAndPlacesEmptyActivitiesLast() {
        let older = makeActivity(events: [makeEvent(date: 100)])
        let newer = makeActivity(events: [makeEvent(date: 200)])
        let empty = makeActivity(events: [])
        #expect(ActivityInsightData.sorted([empty, older, newer]).map(\.id) == [newer.id, older.id, empty.id])
        let ties = [makeActivity(events: []), makeActivity(events: [])]
        #expect(ActivityInsightData.sorted(ties).map(\.id) == ActivityInsightData.sorted(ties.reversed()).map(\.id))
    }

    @Test func comparisonCountsOnlyRatingsInLatestComparableSessions() {
        let events = [makeEvent(date: 100), makeEvent(date: 200), makeEvent(date: 300)]
        let trend = ActivityTrend(
            direction: .stable, indicator: .neutral, metric: .averageRating,
            latestValue: 4, previousValue: 4, delta: 0, comparedEventCount: 2
        )
        let data = ActivityInsightData(activity: makeActivity(events: events, trend: trend))
        #expect(data.responseCount == 3)
        #expect(data.comparisonResponseCount == 2)
        #expect(ActivityInsightData(activity: makeActivity(events: [events[0]])).activity.trend.direction == .insufficientData)
    }

    @Test func failedRefreshRetainsResultsAndCanRetry() async {
        let bootstrap = makeBootstrap(activities: [makeActivity(events: [makeEvent(date: 100)])])
        let store = TestStore(initialState: ActivityList.State(bootstrap: Shared(value: bootstrap))) { ActivityList() }
            withDependencies: { $0.apiClient.getBootstrap = { throw URLError(.notConnectedToInternet) } }
        await store.send(.refresh) { $0.isRefreshing = true }
        await store.receive(\.refreshFailed) {
            $0.isRefreshing = false
            $0.destination = .alert(.refreshFailure)
        }
        #expect(store.state.bootstrap == bootstrap)
        let updated = makeBootstrap(activities: [])
        let clock = TestClock()
        store.dependencies.apiClient.getBootstrap = {
            try await clock.sleep(for: .seconds(1))
            return updated
        }
        await store.send(.destination(.presented(.alert(.retryRefresh)))) {
            $0.destination = nil
        }
        await store.receive(\.refresh) { $0.isRefreshing = true }
        await clock.advance(by: .seconds(1))
        await store.receive(\.refreshed) {
            $0.isRefreshing = false
            $0.$bootstrap.withLock { $0 = updated }
        }
        #expect(store.state.activities.isEmpty)
    }

    @Test func anonymousUsersCannotOpenOwnerActivitiesOrRestoreOwnerStateFromStaleRefresh() async {
        let participant = Bootstrap(
            participantEvents: [], accountInfo: .init(name: nil, email: nil, phoneNumber: nil), role: nil
        )
        let store = TestStore(initialState: ActivityList.State(bootstrap: Shared(value: participant))) { ActivityList() }
        await store.send(.activityTap(makeActivity(events: [])))
        await store.send(.createActivityButtonTap)
        await store.send(.refresh)
        await store.send(.refreshed(makeBootstrap(activities: [])))
        await store.send(.refreshFailed)
        #expect(store.state.bootstrap.role == nil)
        #expect(store.state.destination == nil)
    }

    @Test func dismissingRefreshAlertKeepsExistingActivities() async {
        let bootstrap = makeBootstrap(activities: [makeActivity(events: [makeEvent(date: 100)])])
        let store = TestStore(initialState: ActivityList.State(
            destination: .alert(.refreshFailure), bootstrap: Shared(value: bootstrap)
        )) { ActivityList() }

        await store.send(.destination(.dismiss)) { $0.destination = nil }
        #expect(store.state.bootstrap == bootstrap)
        #expect(!store.state.isRefreshing)
    }

    @Test func drillDownRejectsSessionsOutsideSelectedActivity() async {
        let event = makeEvent(date: 100)
        let activity = makeActivity(events: [event])
        let bootstrap = Shared(value: makeBootstrap(activities: [activity]))
        let store = TestStore(initialState: ActivityDetail.State(activityId: activity.id, bootstrap: bootstrap)) {
            ActivityDetail()
        }
        await store.send(.eventTapped(makeEvent(date: 300)))
        await store.send(.eventTapped(event)) {
            $0.destination = .eventDetail(.init(activityId: activity.id, eventId: event.id, bootstrap: bootstrap))
        }
        await store.send(.destination(.presented(.eventDetail(.delegate(.editActivity))))) {
            $0.destination = .editActivity(.edit(activity: activity))
        }
    }

    @Test func emptyStateCreationOpensExistingActivityCreationFlow() async {
        let store = TestStore(initialState: Tabbar.State(bootstrap: Shared(value: makeBootstrap(activities: [])), selectedTab: .activities)) {
            Tabbar()
        }
        await store.withExhaustivity(.off) {
            await store.send(.activities(.createActivityButtonTap))
        }
        #expect(store.state.activities.destination?.manageActivity != nil)
    }

    @Test func creationPushesCreatedActivity() async {
        let activity = makeActivity(events: [])
        let shared = Shared(value: makeBootstrap(activities: []))
        let store = TestStore(initialState: ActivityList.State(bootstrap: shared)) { ActivityList() }
        await store.send(.navigateToCreatedActivity(activity)) {
            $0.$bootstrap.withLock { $0.managerData!.activities.updateOrAppend(activity) }
            $0.path.append(.activityDetail(.init(activityId: activity.id, bootstrap: shared)))
        }
        #expect(store.state.path.last?.activityDetail?.activityId == activity.id)
    }

    @Test func activitySessionOpensFeedbackAndRejectsForeignSessions() async {
        let event = makeEvent(date: 100)
        let activity = makeActivity(events: [event])
        let shared = Shared(value: makeBootstrap(activities: [activity]))
        let store = TestStore(initialState: ActivityList.State(bootstrap: shared)) { ActivityList() }
        await store.send(.eventTap(activityId: activity.id, eventId: UUID()))
        await store.send(.eventTap(activityId: UUID(), eventId: event.id))
        await store.send(.eventTap(activityId: activity.id, eventId: event.id)) {
            $0.path.append(.eventDetail(.init(activityId: activity.id, eventId: event.id, bootstrap: shared)))
        }
    }

    @Test func anonymousUserCanRemainOnActivitiesTab() async {
        let participant = Bootstrap(
            participantEvents: [], accountInfo: .init(name: nil, email: nil, phoneNumber: nil), role: nil
        )
        let store = TestStore(initialState: Tabbar.State(bootstrap: Shared(value: participant), selectedTab: .activities)) {
            Tabbar()
        }
        await store.send(.validateSelectedTab)
    }

    @Test func anonymousUserCanOpenActivitiesToLogIn() async {
        let participant = Bootstrap(
            participantEvents: [], accountInfo: .init(name: nil, email: nil, phoneNumber: nil), role: nil
        )
        let store = TestStore(initialState: Tabbar.State(bootstrap: Shared(value: participant), selectedTab: .feedback)) {
            Tabbar()
        }
        await store.send(.binding(.set(\.selectedTab, .activities))) { $0.selectedTab = .activities }
    }
}

private func makeEvent(date: TimeInterval, canonical: UUID = UUID()) -> Event {
    let questionId = UUID()
    let question = ManagerQuestion(
        id: questionId, questionText: "Hvor nyttigt var mødet?", feedbackType: .zeroToTen,
        feedback: [.init(type: .zeroToTen(zeroToTen: 8, comment: nil), questionId: questionId,
                         seenByManager: false, createdAt: Date(timeIntervalSince1970: date + 10))],
        feedbackSummary: nil, activityQuestionId: canonical
    )
    return Event(
        id: UUID(), date: Date(timeIntervalSince1970: date), pinCode: nil, durationInMinutes: 30,
        averageRating: 4,
        overallFeedbackSummary: .init(
            segmentationStats: .init(verySadPercentage: 0, sadPercentage: 0, happyPercentage: 0, veryHappyPercentage: 0),
            countStats: .init(verySadCount: 0, sadCount: 0, happyCount: 0, veryHappyCount: 0, commentsCount: 0),
            unseenResponses: 1, responses: 1
        ),
        questionsSnapshot: [question], calendarProvider: nil
    )
}

private func makeActivity(events: [Event], trend: ActivityTrend = .insufficientData) -> Activity {
    .init(
        id: UUID(), title: "Teammøde", activityEmail: "1234@letsgrow.dk", date: .distantPast, pinCode: nil, durationInMinutes: 0,
        ownerInfo: .init(name: nil, email: nil, phoneNumber: nil), trend: trend,
        overallFeedbackSummary: nil, questions: [], events: events, isDraft: false,
        invitedEmails: [], participants: [], calendarProvider: nil
    )
}

private func makeBootstrap(activities: [Activity]) -> Bootstrap {
    .init(
        participantEvents: [],
        managerData: .init(
            activities: .init(uniqueElements: activities), notificationHistory: .init(items: [], unseenTotal: 0),
            questionAnalytics: [], bootstrapHash: UUID()
        ),
        accountInfo: .init(name: nil, email: nil, phoneNumber: nil), role: .manager
    )
}
