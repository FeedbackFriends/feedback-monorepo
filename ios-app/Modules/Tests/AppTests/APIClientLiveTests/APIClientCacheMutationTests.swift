@testable import Domain
import Adapters
import ComposableArchitecture
import Foundation
import Testing

@MainActor
struct APIClientCacheMutationTests {
    // Protects deterministic cache mutation invariants for manager state, entity lookup, seen/unseen counters,
    // and stream emission semantics for bootstrap-updating operations.

    @Test
    func `Manager-only mutations throw when manager data is unavailable`() async throws {
        let cache = APIClientCache(bootstrap: Self.participantBootstrap)

        let mutations: [(String, @Sendable (APIClientCache) async throws -> Void)] = [
            ("deleteActivity", { cache in try await cache.deleteActivity(Self.activityId) }),
            ("updateOrAppendActivity", { cache in try await cache.updateOrAppendActivity(Self.activity(id: Self.activityId, title: "Updated")) }),
            ("updateOrAppendEvent", { cache in try await cache.updateOrAppendEvent(Self.event(id: Self.eventId, unseenResponses: 0, seenByManager: true)) }),
            ("markEventAsSeen", { cache in try await cache.markEventAsSeen(eventId: Self.eventId) }),
            ("markActivityAsSeen", { cache in try await cache.markActivityAsSeen(activityId: Self.activityId) }),
            ("updateNotificationHistory", { cache in
                try await cache.updateNotificationHistory(.init(items: [], unseenTotal: 0))
            }),
            ("markNotificationHistoryAsSeen", { cache in try await cache.markNotificationHistoryAsSeen() })
        ]

        for (name, mutation) in mutations {
            do {
                try await mutation(cache)
                Issue.record("Expected managerDataUnavailable for \(name)")
            } catch let error as APIClientCache.CacheMutationError {
                #expect(error == .managerDataUnavailable)
            }
        }
    }

    @Test
    func `Entity-targeted mutations throw not-found for missing IDs`() async throws {
        let unknownActivityId = UUID(uuidString: "00000000-0000-0000-0000-0000000000AA")!
        let unknownEventId = UUID(uuidString: "00000000-0000-0000-0000-0000000000BB")!
        let cache = APIClientCache(bootstrap: Self.managerBootstrap())

        let cases: [(String, APIClientCache.CacheMutationError, @Sendable (APIClientCache) async throws -> Void)] = [
            (
                "deleteActivity",
                .activityNotFound(unknownActivityId),
                { cache in try await cache.deleteActivity(unknownActivityId) }
            ),
            (
                "markActivityAsSeen",
                .activityNotFound(unknownActivityId),
                { cache in try await cache.markActivityAsSeen(activityId: unknownActivityId) }
            ),
            (
                "markEventAsSeen",
                .eventNotFound(unknownEventId),
                { cache in try await cache.markEventAsSeen(eventId: unknownEventId) }
            ),
            (
                "updateOrAppendEvent",
                .eventNotFound(unknownEventId),
                { cache in try await cache.updateOrAppendEvent(Self.event(id: unknownEventId, unseenResponses: 1, seenByManager: false)) }
            )
        ]

        for (name, expectedError, mutation) in cases {
            do {
                try await mutation(cache)
                Issue.record("Expected \(expectedError) for \(name)")
            } catch let error as APIClientCache.CacheMutationError {
                #expect(error == expectedError)
            }
        }
    }

    @Test
    func `updateOrAppendActivity updates existing and appends missing by ID`() async throws {
        let existingActivity = Self.activity(id: Self.activityId, title: "Original")
        let cache = APIClientCache(bootstrap: Self.managerBootstrap(activities: [existingActivity]))

        try await cache.updateOrAppendActivity(Self.activity(id: Self.activityId, title: "Updated"))

        let appendedId = UUID(uuidString: "00000000-0000-0000-0000-0000000000CC")!
        try await cache.updateOrAppendActivity(Self.activity(id: appendedId, title: "Appended"))

        let updated = try #require(await cache.getBootstrap())
        let activities = try #require(updated.managerData?.activities)

        #expect(activities[id: Self.activityId]?.title == "Updated")
        #expect(activities[id: appendedId]?.title == "Appended")
        #expect(activities.count == 2)
    }

    @Test
    func `updateOrAppendEvent updates only matching event in owning activity`() async throws {
        let targetEvent = Self.event(id: Self.eventId, unseenResponses: 1, seenByManager: false)
        let untouchedEvent = Self.event(id: Self.secondEventId, unseenResponses: 2, seenByManager: false)
        let primaryActivity = Self.activity(id: Self.activityId, title: "A", events: [targetEvent])
        let secondaryActivity = Self.activity(id: Self.secondActivityId, title: "B", events: [untouchedEvent])
        let cache = APIClientCache(bootstrap: Self.managerBootstrap(activities: [primaryActivity, secondaryActivity]))

        try await cache.updateOrAppendEvent(Self.event(id: Self.eventId, unseenResponses: 9, seenByManager: false))

        let updated = try #require(await cache.getBootstrap())
        let activities = try #require(updated.managerData?.activities)
        #expect(activities[id: Self.activityId]?.events.first?.title == "Target new")
        #expect(activities[id: Self.activityId]?.events.first?.overallFeedbackSummary?.unseenResponses == 9)
        #expect(activities[id: Self.secondActivityId]?.events.first?.title == "Other old")
    }

    @Test
    func `deleteActivity removes exactly one activity`() async throws {
        let first = Self.activity(id: Self.activityId, title: "First")
        let second = Self.activity(id: Self.secondActivityId, title: "Second")
        let cache = APIClientCache(bootstrap: Self.managerBootstrap(activities: [first, second]))

        try await cache.deleteActivity(Self.activityId)

        let updated = try #require(await cache.getBootstrap())
        let activities = try #require(updated.managerData?.activities)
        #expect(activities.count == 1)
        #expect(activities[id: Self.activityId] == nil)
        #expect(activities[id: Self.secondActivityId]?.title == "Second")
    }

    @Test
    func `markActivityAsSeen updates unseen responses and feedback flags and marks all notifications seen`() async throws {
        let activity = Self.activity(id: Self.activityId, title: "Activity", unseenResponses: 4, feedbackSeen: false)
        let history = Self.notificationHistory(items: [
            Self.notification(id: Self.notificationId, eventId: Self.eventId, seen: false),
            Self.notification(id: Self.secondNotificationId, eventId: Self.secondEventId, seen: false)
        ], unseenTotal: 3)
        let cache = APIClientCache(bootstrap: Self.managerBootstrap(activities: [activity], notificationHistory: history))

        try await cache.markActivityAsSeen(activityId: Self.activityId)

        let updated = try #require(await cache.getBootstrap())
        let managerData = try #require(updated.managerData)
        let updatedActivity = try #require(managerData.activities[id: Self.activityId])

        #expect(updatedActivity.overallFeedbackSummary?.unseenResponses == 0)
        #expect(updatedActivity.questions.flatMap(\.feedback).allSatisfy(\.seenByManager))
        #expect(managerData.notificationHistory.items.allSatisfy(\.seenByManager))
        #expect(managerData.notificationHistory.unseenTotal == 1)
    }

    @Test
    func `markEventAsSeen updates event unseen responses and only decrements unseen total for newly seen matching event items`() async throws {
        let event = Self.event(id: Self.eventId, unseenResponses: 2, seenByManager: false)
        let history = Self.notificationHistory(items: [
            Self.notification(id: Self.notificationId, eventId: Self.eventId, seen: false),
            Self.notification(id: Self.secondNotificationId, eventId: Self.eventId, seen: true),
            Self.notification(id: Self.thirdNotificationId, eventId: Self.secondEventId, seen: false)
        ], unseenTotal: 1)
        let cache = APIClientCache(bootstrap: Self.managerBootstrap(activities: [Self.activity(id: Self.activityId, title: "Activity", events: [event])], notificationHistory: history))

        try await cache.markEventAsSeen(eventId: Self.eventId)

        let updated = try #require(await cache.getBootstrap())
        let managerData = try #require(updated.managerData)
        let updatedEvent = try #require(managerData.activities[id: Self.activityId]?.events.first)
        let items = managerData.notificationHistory.items

        #expect(updatedEvent.overallFeedbackSummary?.unseenResponses == 0)
        #expect(updatedEvent.questions.flatMap(\.feedback).allSatisfy(\.seenByManager))
        #expect(items.first { $0.id == Self.notificationId }?.seenByManager == true)
        #expect(items.first { $0.id == Self.secondNotificationId }?.seenByManager == true)
        #expect(items.first { $0.id == Self.thirdNotificationId }?.seenByManager == false)
        #expect(managerData.notificationHistory.unseenTotal == 0)
    }

    @Test
    func `markNotificationHistoryAsSeen marks all notifications seen and unseen total never below zero`() async throws {
        let history = Self.notificationHistory(items: [
            Self.notification(id: Self.notificationId, eventId: Self.eventId, seen: false),
            Self.notification(id: Self.secondNotificationId, eventId: Self.secondEventId, seen: false)
        ], unseenTotal: 1)
        let cache = APIClientCache(bootstrap: Self.managerBootstrap(notificationHistory: history))

        try await cache.markNotificationHistoryAsSeen()

        let updated = try #require(await cache.getBootstrap())
        let notificationHistory = try #require(updated.managerData?.notificationHistory)

        #expect(notificationHistory.items.allSatisfy(\.seenByManager))
        #expect(notificationHistory.unseenTotal == 0)
    }

    @Test
    func `mutation operations that update bootstrap emit one stream value`() async throws {
        let cache = APIClientCache(bootstrap: Self.managerBootstrap())
        var listener = await cache.bootstrapChangedListener().makeAsyncIterator()

        try await cache.updateOrAppendActivity(Self.activity(id: Self.activityId, title: "Updated"))

        let emitted = try #require(await listener.next())
        #expect(emitted.managerData?.activities[id: Self.activityId]?.title == "Updated")
    }
}

private extension APIClientCacheMutationTests {
    static let referenceDate = Date(timeIntervalSince1970: 1_710_000_000)

    static let activityId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let secondActivityId = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let eventId = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    static let secondEventId = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
    static let questionId = UUID(uuidString: "00000000-0000-0000-0000-000000000005")!
    static let notificationId = UUID(uuidString: "00000000-0000-0000-0000-000000000006")!
    static let secondNotificationId = UUID(uuidString: "00000000-0000-0000-0000-000000000007")!
    static let thirdNotificationId = UUID(uuidString: "00000000-0000-0000-0000-000000000008")!
    static let bootstrapHash = UUID(uuidString: "00000000-0000-0000-0000-000000000009")!

    static let participantBootstrap = Bootstrap(
        participantEvents: [],
        managerData: nil,
        accountInfo: .init(name: "Participant", email: "participant@example.com", phoneNumber: nil),
        role: .participant
    )

    static func feedback(seen: Bool) -> Feedback {
        .init(
            type: .emoji(emoji: .happy, comment: "ok"),
            questionId: questionId,
            seenByManager: seen,
            createdAt: referenceDate
        )
    }

    static func question(feedbackSeen: Bool) -> ManagerQuestion {
        .init(
            id: questionId,
            questionText: "How did it go?",
            feedbackType: .emoji,
            feedback: [feedback(seen: feedbackSeen)],
            feedbackSummary: nil
        )
    }

    static func overallSummary(unseenResponses: Int) -> OverallFeedbackSummary {
        .init(
            segmentationStats: .init(verySadPercentage: 0, sadPercentage: 0, happyPercentage: 100, veryHappyPercentage: 0),
            countStats: .init(verySadCount: 0, sadCount: 0, happyCount: 1, veryHappyCount: 0, commentsCount: 0),
            unseenResponses: unseenResponses,
            responses: 1
        )
    }

    static func event(
        id: UUID,
        unseenResponses: Int,
        seenByManager: Bool
    ) -> Event {
        .init(
            id: id,
            date: referenceDate,
            pinCode: .init(value: "123456"),
            durationInMinutes: 45,
            location: "Room Blue",
            overallFeedbackSummary: overallSummary(unseenResponses: unseenResponses),
            questionsSnapshot: [question(feedbackSeen: seenByManager)],
            calendarProvider: nil
        )
    }

    static func activity(
        id: UUID,
        title: String,
        unseenResponses: Int = 0,
        feedbackSeen: Bool = true,
        events: [Event]? = nil
    ) -> Activity {
        .init(
            id: id,
            title: title,
            agenda: "Agenda",
            date: referenceDate,
            pinCode: .init(value: "123456"),
            durationInMinutes: 45,
            location: "Room Blue",
            ownerInfo: .init(name: "Owner", email: "owner@example.com", phoneNumber: "12345678"),
            overallFeedbackSummary: overallSummary(unseenResponses: unseenResponses),
            questions: [question(feedbackSeen: feedbackSeen)],
            events: events ?? [event(id: eventId, unseenResponses: unseenResponses, seenByManager: feedbackSeen)],
            isDraft: false,
            invitedEmails: [],
            participants: [],
            calendarProvider: nil
        )
    }

    static func notification(id: UUID, eventId: UUID, seen: Bool) -> NotificationHistoryItem {
        .init(
            id: id,
            date: referenceDate,
            eventTitle: "Event",
            eventId: eventId,
            newFeedbackCount: 1,
            seenByManager: seen
        )
    }

    static func notificationHistory(items: [NotificationHistoryItem], unseenTotal: Int) -> NotificationHistory {
        .init(items: items, unseenTotal: unseenTotal)
    }

    static func managerBootstrap(
        activities: [Activity] = [activity(id: activityId, title: "Activity")],
        notificationHistory: NotificationHistory = notificationHistory(items: [], unseenTotal: 0)
    ) -> Bootstrap {
        .init(
            participantEvents: [],
            managerData: .init(
                activities: .init(uniqueElements: activities),
                notificationHistory: notificationHistory,
                questionAnalytics: [.mock()],
                bootstrapHash: bootstrapHash
            ),
            accountInfo: .init(name: "Manager", email: "manager@example.com", phoneNumber: "12345678"),
            role: .manager
        )
    }
}
