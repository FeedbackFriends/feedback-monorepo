@testable import ActivityFeature
@testable import RootFeature
@testable import TabbarFeature
import ComposableArchitecture
import Domain
import Foundation
import Testing

@MainActor
struct RootNavigationTests {
    @Test
    func feedbackNotificationOpensSessionInOwningActivity() throws {
        var activity = Activity.mock()
        let event = Event.mock()
        activity.events = [event]
        let shared = Shared(value: Bootstrap(
            participantEvents: [],
            managerData: .init(
                activities: .init(uniqueElements: [activity]),
                notificationHistory: .init(items: [], unseenTotal: 0),
                questionAnalytics: [], bootstrapHash: UUID()
            ),
            accountInfo: .init(name: nil, email: nil, phoneNumber: nil), role: .manager
        ))

        let state = RootFeature.State.fromDeeplink(deeplink: .managerEvent(id: event.id), sharedBootstrap: shared)
        let tabs = try #require(state.destination.loggedIn)
        let detail = try #require(tabs.managerEvents.destination?.quickLook?.destination?.eventDetail)
        #expect(detail.activityId == activity.id)
        #expect(detail.eventId == event.id)
        #expect(tabs.selectedTab == .home)
        #expect(tabs.activities.path.isEmpty)
    }

    @Test
    func accountCreationFinishesLoading() {
        let store = Store(initialState: RootFeature.State(isLoading: true)) { RootFeature() }
        store.send(.createAccountResponse(.mock(), .manager))
        #expect(!store.isLoading)
        #expect(store.destination.loggedIn?.selectedTab == .home)
    }
}
