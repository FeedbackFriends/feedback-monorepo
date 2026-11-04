@testable import ActivityFeature
@testable import RootFeature
@testable import TabbarFeature
import ComposableArchitecture
import Domain
import Foundation
import Testing

@MainActor
struct NotificationTests {
    @Test(arguments: [false, true])
    func payloadTapRefreshesBootstrapAndOpensSession(warmStart: Bool) async throws {
        let payload = try payload()
        let deeplink = try #require(Deeplink(notificationUserInfo: payload))
        let eventIdString = try #require(payload["eventId"] as? String)
        let eventId = try #require(UUID(uuidString: eventIdString))
        let bootstrap = fixture(eventId: eventId)
        let initialState = warmStart
            ? RootFeature.State(destination: .loggedIn(.init(bootstrap: Shared(value: Bootstrap.mock()))))
            : RootFeature.State()
        let refreshCount = LockIsolated(0)
        let store = Store(initialState: initialState) { RootFeature() } withDependencies: {
            $0.apiClient.getBootstrap = {
                refreshCount.withValue { $0 += 1 }
                return bootstrap
            }
        }

        await store.send(.onNotificationTap(deeplink)).finish()

        let tabs = try #require(store.state.destination.loggedIn)
        let detail = try #require(tabs.activities.path.last?.eventDetail)
        #expect(refreshCount.value == 1)
        #expect(detail.eventId == eventId)
        #expect(detail.activityId == bootstrap.managerData?.activities.first?.id)
        #expect(tabs.selectedTab == .activities)
        #expect(tabs.activities.path.count == 2)
        #expect(!store.state.isLoading)
        #expect(!store.state.notificationDeeplinkInFlight)
    }

    @Test
    func deletedSessionReturnsToActivitiesWithoutOpeningAnotherSession() async throws {
        let deeplink = try #require(Deeplink(notificationUserInfo: try payload()))
        let store = Store(initialState: RootFeature.State()) { RootFeature() } withDependencies: {
            $0.apiClient.getBootstrap = { Bootstrap.mock() }
        }

        await store.send(.onNotificationTap(deeplink)).finish()

        let tabs = try #require(store.state.destination.loggedIn)
        #expect(tabs.selectedTab == .activities)
        #expect(tabs.activities.path.isEmpty)
        #expect(!store.state.isLoading)
    }

    @Test(arguments: ["", "not-a-uuid"])
    func malformedPayloadDoesNotProduceNavigation(eventId: String) throws {
        var payload = try payload()
        payload["eventId"] = eventId
        #expect(Deeplink(notificationUserInfo: payload) == nil)
    }

    @Test
    func fixtureUsesLocalizedAPNsAlertAndStringArguments() throws {
        let payload = try payload()
        let aps = try #require(payload["aps"] as? [String: Any])
        let alert = try #require(aps["alert"] as? [String: Any])
        #expect(alert["title-loc-key"] as? String == "notification_feedback_received_title")
        #expect(alert["loc-key"] as? String == "notification_feedback_received_body")
        #expect(alert["loc-args"] as? [String] == ["99", "Weekly 100% sync"])
        #expect(alert["title"] == nil)
        #expect(alert["body"] == nil)
    }

    private func payload() throws -> [String: Any] {
        let url = try #require(Bundle.module.url(forResource: "feedback-received", withExtension: "apns", subdirectory: "Fixtures"))
        return try #require(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
    }

    private func fixture(eventId: UUID) -> Bootstrap {
        var activity = Activity.mock()
        let event = Event(
            id: eventId, date: Date(), pinCode: nil, durationInMinutes: 30,
            overallFeedbackSummary: nil, questionsSnapshot: [], calendarProvider: nil
        )
        activity.events = [event]
        return Bootstrap(
            participantEvents: [],
            managerData: .init(
                activities: .init(uniqueElements: [activity]),
                notificationHistory: .init(items: [], unseenTotal: 0),
                questionAnalytics: [], bootstrapHash: UUID()
            ),
            accountInfo: .init(name: nil, email: nil, phoneNumber: nil), role: .manager
        )
    }
}
