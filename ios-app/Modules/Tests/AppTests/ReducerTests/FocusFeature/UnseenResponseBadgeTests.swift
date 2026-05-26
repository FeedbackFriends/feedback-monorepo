@testable import Adapters
@testable import FocusFeature
import ComposableArchitecture
import Domain
import Foundation
import Testing

@MainActor
struct UnseenResponseBadgeTests {
    @Test
    func `Focus badge sums unseen responses across events`() {
        let firstEvent = Self.event(id: Self.firstEventId, unseenResponses: 2)
        let secondEvent = Self.event(id: Self.secondEventId, unseenResponses: 3)
        let activity = Self.activity(
            overallUnseenResponses: 99,
            events: [firstEvent, secondEvent]
        )
        let bootstrap = Self.bootstrap(activity: activity)

        #expect(bootstrap.managerUnseenResponses == 5)
    }

    @Test
    func `Marking one event as seen leaves other event unseen responses unchanged`() async throws {
        let firstEvent = Self.event(id: Self.firstEventId, unseenResponses: 2)
        let secondEvent = Self.event(id: Self.secondEventId, unseenResponses: 3)
        let cache = APIClientCache(
            session: Self.bootstrap(
                activity: Self.activity(events: [firstEvent, secondEvent]),
                notificationHistory: .init(
                    items: [
                        Self.notificationHistoryItem(id: Self.firstNotificationId, eventId: Self.firstEventId),
                        Self.notificationHistoryItem(id: Self.secondNotificationId, eventId: Self.secondEventId)
                    ],
                    unseenTotal: 2
                )
            )
        )

        try await cache.markEventAsSeen(eventId: Self.firstEventId)

        let updated = await cache.getBootstrap()
        let updatedActivity = try #require(updated?.managerData?.activities[id: Self.activityId])
        let updatedFirstEvent = updatedActivity.events.first { $0.id == Self.firstEventId }
        let updatedSecondEvent = updatedActivity.events.first { $0.id == Self.secondEventId }
        #expect(updatedFirstEvent?.overallFeedbackSummary?.unseenResponses == 0)
        #expect(updatedSecondEvent?.overallFeedbackSummary?.unseenResponses == 3)
        #expect(updatedFirstEvent?.questions.first?.feedback.allSatisfy(\.seenByManager) == true)
        #expect(updatedSecondEvent?.questions.first?.feedback.allSatisfy(\.seenByManager) == false)
        #expect(updated?.managerData?.notificationHistory.unseenTotal == 1)
        #expect(
            updated?.managerData?.notificationHistory.items.first { $0.id == Self.firstNotificationId }?.seenByManager == true
        )
        #expect(
            updated?.managerData?.notificationHistory.items.first { $0.id == Self.secondNotificationId }?.seenByManager == false
        )
    }

    @Test
    func `Opening activity detail does not clear event unseen responses`() async {
        let event = Self.event(id: Self.firstEventId, unseenResponses: 2)
        let activity = Self.activity(events: [event])
        let sharedBootstrap = Shared(value: Self.bootstrap(activity: activity))
        let store = TestStore(
            initialState: ActivityList.State(bootstrap: sharedBootstrap)
        ) {
            ActivityList()
        }

        await store.send(.activityTap(activity)) {
            $0.destination = .activityDetail(
                ActivityDetail.State(
                    activityId: activity.id,
                    bootstrap: sharedBootstrap
                )
            )
        }

        let updatedEvent = sharedBootstrap.wrappedValue.managerData?.activities[id: activity.id]?.events.first { $0.id == event.id }
        #expect(updatedEvent?.overallFeedbackSummary?.unseenResponses == 2)
    }
}

private extension UnseenResponseBadgeTests {
    static let activityId = UUID(uuidString: "00000000-0000-0000-0000-000000000101")!
    static let firstEventId = UUID(uuidString: "00000000-0000-0000-0000-000000000102")!
    static let secondEventId = UUID(uuidString: "00000000-0000-0000-0000-000000000103")!
    static let questionId = UUID(uuidString: "00000000-0000-0000-0000-000000000104")!
    static let firstNotificationId = UUID(uuidString: "00000000-0000-0000-0000-000000000105")!
    static let secondNotificationId = UUID(uuidString: "00000000-0000-0000-0000-000000000106")!
    static let referenceDate = Date(timeIntervalSince1970: 1_710_000_000)

    static func bootstrap(
        activity: Activity,
        notificationHistory: NotificationHistory = .init(items: [], unseenTotal: 0)
    ) -> Bootstrap {
        .init(
            participantEvents: [],
            managerData: .init(
                activities: .init(uniqueElements: [activity]),
                notificationHistory: notificationHistory,
                questionAnalytics: [],
                bootstrapHash: UUID()
            ),
            accountInfo: .init(name: nil, email: nil, phoneNumber: nil),
            role: .manager
        )
    }

    static func activity(
        overallUnseenResponses: Int = 0,
        events: [Event]
    ) -> Activity {
        .init(
            id: activityId,
            title: "Weekly retro",
            date: referenceDate,
            pinCode: nil,
            durationInMinutes: 45,
            ownerInfo: .init(name: nil, email: nil, phoneNumber: nil),
            overallFeedbackSummary: summary(unseenResponses: overallUnseenResponses),
            questions: [],
            events: events,
            isDraft: false,
            invitedEmails: [],
            participants: [],
            calendarProvider: nil
        )
    }

    static func event(id: UUID, unseenResponses: Int) -> Event {
        .init(
            id: id,
            date: referenceDate,
            pinCode: nil,
            durationInMinutes: 45,
            overallFeedbackSummary: summary(unseenResponses: unseenResponses),
            questionsSnapshot: [
                .init(
                    id: questionId,
                    questionText: "How did it go?",
                    feedbackType: .emoji,
                    feedback: [
                        .init(
                            type: .emoji(emoji: .happy, comment: nil),
                            questionId: questionId,
                            seenByManager: false,
                            createdAt: referenceDate
                        )
                    ],
                    feedbackSummary: nil
                )
            ],
            calendarProvider: nil
        )
    }

    static func summary(unseenResponses: Int) -> OverallFeedbackSummary {
        .init(
            segmentationStats: .init(
                verySadPercentage: 0,
                sadPercentage: 0,
                happyPercentage: 100,
                veryHappyPercentage: 0
            ),
            countStats: .init(
                verySadCount: 0,
                sadCount: 0,
                happyCount: 1,
                veryHappyCount: 0,
                commentsCount: 0
            ),
            unseenResponses: unseenResponses,
            responses: 1
        )
    }

    static func notificationHistoryItem(id: UUID, eventId: UUID) -> NotificationHistoryItem {
        .init(
            id: id,
            date: referenceDate,
            eventTitle: "Weekly retro",
            eventId: eventId,
            newFeedbackCount: 1,
            seenByManager: false
        )
    }
}
