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

    @Test func overviewOrdersByResponseTimestampAndPlacesEmptyActivitiesLast() {
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
            $0.refreshError = "Kunne ikke opdatere dit overblik. Prøv igen."
        }
        #expect(store.state.bootstrap == bootstrap)
        let updated = makeBootstrap(activities: [])
        store.dependencies.apiClient.getBootstrap = { updated }
        await store.send(.refresh) { $0.isRefreshing = true; $0.refreshError = nil }
        await store.receive(\.refreshed) {
            $0.isRefreshing = false
            $0.$bootstrap.withLock { $0 = updated }
        }
        #expect(store.state.activities.isEmpty)
    }

    @Test func participantsCannotOpenOwnerActivitiesOrRestoreOwnerStateFromStaleRefresh() async {
        let participant = Bootstrap(
            participantEvents: [], accountInfo: .init(name: nil, email: nil, phoneNumber: nil), role: .participant
        )
        let store = TestStore(initialState: ActivityList.State(bootstrap: Shared(value: participant))) { ActivityList() }
        await store.send(.activityTap(makeActivity(events: [])))
        await store.send(.createActivityButtonTap)
        await store.send(.refresh)
        await store.send(.refreshed(makeBootstrap(activities: [])))
        #expect(store.state.bootstrap.role == .participant)
        #expect(store.state.destination == nil)
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
        let store = TestStore(initialState: Tabbar.State(bootstrap: Shared(value: makeBootstrap(activities: [])), selectedTab: .home)) {
            Tabbar()
        }
        await store.withExhaustivity(.off) {
            await store.send(.managerEvents(.createActivityButtonTap))
        }
        #expect(store.state.managerEvents.destination?.manageActivity != nil)
    }

    @Test func overviewCreationOpensCreatedActivityInSheet() async {
        let activity = makeActivity(events: [])
        let shared = Shared(value: makeBootstrap(activities: []))
        let store = TestStore(initialState: ActivityList.State(bootstrap: shared, presentation: .overview)) { ActivityList() }
        await store.send(.navigateToCreatedActivity(activity)) {
            $0.$bootstrap.withLock { $0.managerData!.activities.updateOrAppend(activity) }
            $0.destination = .quickLook(.init(activityId: activity.id, bootstrap: shared))
        }
        #expect(store.state.path.isEmpty)
    }

    @Test func homePrioritizesUnreadByFeedbackTimeAndShowsNearestUpcomingSession() {
        var future = makeEvent(date: 2_000)
        let past = makeEvent(date: 900)
        var seen = makeEvent(date: 3_000)
        seen.overallFeedbackSummary?.unseenResponses = 0
        future.questionsSnapshot[0].feedback = [.init(
            type: .zeroToTen(zeroToTen: 7, comment: nil), questionId: future.questionsSnapshot[0].id,
            seenByManager: false, createdAt: Date(timeIntervalSince1970: 50)
        )]
        let overview = HomeOverview(
            activities: [makeActivity(events: [future, past, seen])], now: Date(timeIntervalSince1970: 1_000)
        )
        #expect(overview.unreadSessions.map(\.id) == [past.id, future.id])
        #expect(overview.nextSession?.id == future.id)
        #expect(overview.unreadSessions[0].unseenResponses == 1)
    }

    @Test func homeOmitsStaleStableAndInsufficientDevelopments() {
        let now = Date(timeIntervalSince1970: 40 * 24 * 60 * 60)
        let improving = ActivityTrend(
            direction: .improving, indicator: .positive, metric: .averageRating,
            latestValue: 4, previousValue: 3, delta: 1, comparedEventCount: 2
        )
        let recent = makeActivity(events: [makeEvent(date: now.timeIntervalSince1970 - 60)], trend: improving)
        let stale = makeActivity(events: [makeEvent(date: 100)], trend: improving)
        let stable = makeActivity(events: [makeEvent(date: now.timeIntervalSince1970 - 60)], trend: .init(
            direction: .stable, indicator: .neutral, metric: .averageRating,
            latestValue: 4, previousValue: 4, delta: 0, comparedEventCount: 2
        ))
        let insufficient = makeActivity(events: [makeEvent(date: now.timeIntervalSince1970 - 60)])
        let overview = HomeOverview(activities: [stale, recent, stable, insufficient], now: now)
        #expect(overview.developments.map(\.id) == [recent.id])
        #expect(overview.nextSession == nil)
    }

    @Test func homeShowsEmptyAndCaughtUpStatesWithoutInventingCards() {
        let now = Date(timeIntervalSince1970: 1_000)
        let empty = HomeOverview(activities: [], now: now)
        #expect(empty.unreadSessions.isEmpty && empty.nextSession == nil && empty.developments.isEmpty)
        var seen = makeEvent(date: 100)
        seen.overallFeedbackSummary?.unseenResponses = 0
        let caughtUp = HomeOverview(activities: [makeActivity(events: [seen])], now: now)
        #expect(caughtUp.unreadSessions.isEmpty && caughtUp.nextSession == nil && caughtUp.developments.isEmpty)
    }

    @Test func latestFeedbackRemainsAvailableAfterReadingAndUsesFeedbackTime() {
        var olderSession = makeEvent(date: 100)
        olderSession.overallFeedbackSummary?.unseenResponses = 0
        olderSession.questionsSnapshot[0].feedback = [.init(
            type: .zeroToTen(zeroToTen: 7, comment: nil), questionId: olderSession.questionsSnapshot[0].id,
            seenByManager: true, createdAt: Date(timeIntervalSince1970: 900)
        )]
        var newerSession = makeEvent(date: 200)
        newerSession.overallFeedbackSummary?.unseenResponses = 0
        let activity = makeActivity(events: [newerSession, olderSession])
        let now = Date(timeIntervalSince1970: 1_000)
        let overview = HomeOverview(activities: [activity], now: now)
        #expect(overview.latestFeedbackSession?.id == olderSession.id)
        #expect(overview.latestFeedbackSession?.responseCount == 1)
        let withUnread = HomeOverview(activities: [activity, makeActivity(events: [makeEvent(date: 300)])], now: now)
        #expect(withUnread.latestFeedbackSession == nil)
        #expect(HomeOverview(activities: [], now: now).latestFeedbackSession == nil)
        var withoutFeedback = makeEvent(date: 100)
        withoutFeedback.overallFeedbackSummary = nil
        #expect(HomeOverview(activities: [makeActivity(events: [withoutFeedback])], now: now).latestFeedbackSession == nil)
    }

    @Test func recentStatusCountsCompletedSessionsAndSessionsWithFeedback() {
        let now = Date(timeIntervalSince1970: 40 * 24 * 60 * 60)
        let cutoff = now.timeIntervalSince1970 - 30 * 24 * 60 * 60
        let atBoundary = makeEvent(date: cutoff)
        var withoutFeedback = makeEvent(date: cutoff + 100)
        withoutFeedback.overallFeedbackSummary = nil
        let ongoing = makeEvent(date: now.timeIntervalSince1970 - 60)
        let future = makeEvent(date: now.timeIntervalSince1970 + 60)
        let stale = makeEvent(date: cutoff - 1)
        let endedNow = makeEvent(date: now.timeIntervalSince1970 - 30 * 60)
        let overview = HomeOverview(activities: [
            makeActivity(events: [atBoundary, withoutFeedback, ongoing]),
            makeActivity(events: [future, stale, endedNow])
        ], now: now)
        #expect(overview.recentSessionCount == 3)
        #expect(overview.recentFeedbackSessionCount == 2)
        let empty = HomeOverview(activities: [], now: now)
        #expect(empty.recentSessionCount == 0 && empty.recentFeedbackSessionCount == 0)
    }

    @Test func homeSessionOpensFeedbackAndRejectsForeignSessions() async {
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

    @Test func overviewActivityOpensSheetWithoutChangingActivitiesNavigation() async {
        let previous = makeActivity(events: [])
        let activity = makeActivity(events: [makeEvent(date: 100)])
        let shared = Shared(value: makeBootstrap(activities: [previous, activity]))
        var state = Tabbar.State(bootstrap: shared)
        state.activities.path.append(.activityDetail(.init(activityId: previous.id, bootstrap: shared)))
        let store = TestStore(initialState: state) { Tabbar() }
        await store.send(.managerEvents(.activityTap(activity))) {
            $0.managerEvents.destination = .quickLook(.init(activityId: activity.id, bootstrap: shared))
        }
        #expect(store.state.managerEvents.path.isEmpty)
        #expect(store.state.selectedTab == .home)
        #expect(store.state.activities.path.last?.activityDetail?.activityId == previous.id)
        await store.send(.managerEvents(.destination(.dismiss))) {
            $0.managerEvents.destination = nil
        }
        #expect(store.state.activities.path.last?.activityDetail?.activityId == previous.id)
    }

    @Test func overviewSessionOpensInsideSheetAndPreservesActivitiesNavigation() async {
        let event = makeEvent(date: 100)
        let activity = makeActivity(events: [event])
        let shared = Shared(value: makeBootstrap(activities: [activity]))
        var state = Tabbar.State(bootstrap: shared)
        state.activities.path.append(.activityDetail(.init(activityId: activity.id, bootstrap: shared)))
        let store = TestStore(initialState: state) { Tabbar() }
        await store.send(.managerEvents(.eventTap(activityId: activity.id, eventId: event.id))) {
            $0.managerEvents.destination = .quickLook(.init(
                activityId: activity.id,
                destination: .eventDetail(.init(activityId: activity.id, eventId: event.id, bootstrap: shared)),
                bootstrap: shared
            ))
        }
        #expect(store.state.managerEvents.path.isEmpty)
        #expect(store.state.selectedTab == .home)
        #expect(store.state.activities.path.last?.activityDetail?.activityId == activity.id)
        await store.send(.managerEvents(.destination(.dismiss))) {
            $0.managerEvents.destination = nil
        }
        #expect(store.state.activities.path.last?.activityDetail?.activityId == activity.id)
    }

    @Test func unreadFeedbackSheetDismissalReturnsToUnreadList() async {
        let event = makeEvent(date: 100)
        let activity = makeActivity(events: [event])
        let shared = Shared(value: makeBootstrap(activities: [activity]))
        let store = TestStore(initialState: Tabbar.State(bootstrap: shared)) { Tabbar() }
        await store.send(.managerEvents(.unreadFeedbackButtonTap)) {
            $0.managerEvents.path.append(.unreadFeedback)
        }
        await store.send(.managerEvents(.eventTap(activityId: activity.id, eventId: event.id))) {
            $0.managerEvents.destination = .quickLook(.init(
                activityId: activity.id,
                destination: .eventDetail(.init(activityId: activity.id, eventId: event.id, bootstrap: shared)),
                bootstrap: shared
            ))
        }
        await store.send(.managerEvents(.destination(.dismiss))) {
            $0.managerEvents.destination = nil
        }
        #expect(store.state.managerEvents.path.last == .unreadFeedback)
        #expect(store.state.selectedTab == .home)
        #expect(store.state.activities.path.isEmpty)
    }

    @Test func overviewShortcutsRejectMissingActivitiesAndForeignSessions() async {
        let activity = makeActivity(events: [makeEvent(date: 100)])
        let shared = Shared(value: makeBootstrap(activities: [activity]))
        let store = TestStore(initialState: Tabbar.State(bootstrap: shared)) { Tabbar() }
        await store.send(.managerEvents(.activityTap(makeActivity(events: []))))
        await store.send(.managerEvents(.eventTap(activityId: activity.id, eventId: UUID())))
        #expect(store.state.selectedTab == .home)
        #expect(store.state.managerEvents.path.isEmpty)
        #expect(store.state.activities.path.isEmpty)
    }

    @Test func activityTabsKeepIndependentDestinations() async {
        let activity = makeActivity(events: [makeEvent(date: 100)])
        let shared = Shared(value: makeBootstrap(activities: [activity]))
        let store = TestStore(initialState: Tabbar.State(bootstrap: shared)) { Tabbar() }
        await store.withExhaustivity(.off) {
            await store.send(.activities(.activityTap(activity)))
        }
        #expect(!store.state.activities.path.isEmpty)
        #expect(store.state.managerEvents.path.isEmpty)
        await store.withExhaustivity(.off) {
            await store.send(.managerEvents(.createActivityButtonTap))
        }
        #expect(store.state.managerEvents.destination?.manageActivity != nil)
        #expect(store.state.activities.path.last?.activityDetail != nil)
    }

    @Test func participantCannotRemainOnActivitiesTab() async {
        let participant = Bootstrap(
            participantEvents: [], accountInfo: .init(name: nil, email: nil, phoneNumber: nil), role: .participant
        )
        let store = TestStore(initialState: Tabbar.State(bootstrap: Shared(value: participant), selectedTab: .activities)) {
            Tabbar()
        }
        await store.send(.validateSelectedTab) { $0.selectedTab = .feedback }
    }

    @Test func participantCanOpenHomeToCreateAnAccount() async {
        let participant = Bootstrap(
            participantEvents: [], accountInfo: .init(name: nil, email: nil, phoneNumber: nil), role: .participant
        )
        let store = TestStore(initialState: Tabbar.State(bootstrap: Shared(value: participant), selectedTab: .feedback)) {
            Tabbar()
        }
        await store.send(.binding(.set(\.selectedTab, .home))) { $0.selectedTab = .home }
    }

    @Test func roleChangeReturnsToFeedback() async {
        let participant = Bootstrap(
            participantEvents: [], accountInfo: .init(name: nil, email: nil, phoneNumber: nil), role: .participant
        )
        let store = TestStore(initialState: Tabbar.State(bootstrap: Shared(value: participant), selectedTab: .home)) {
            Tabbar()
        }
        await store.send(.validateSelectedTab) { $0.selectedTab = .feedback }
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
