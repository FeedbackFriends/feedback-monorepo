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
        let detail = try #require(tabs.activities.path.last?.eventDetail)
        #expect(detail.activityId == activity.id)
        #expect(detail.eventId == event.id)
        #expect(tabs.selectedTab == .activities)
        #expect(tabs.activities.path.count == 2)
        #expect(tabs.activities.path.first?.activityDetail?.activityId == activity.id)
    }

    @Test
    func accountCreationFinishesLoading() {
        let store = Store(initialState: RootFeature.State(isLoading: true)) { RootFeature() }
        store.send(.createAccountResponse(.mock(), .manager))
        #expect(!store.isLoading)
        #expect(store.destination.loggedIn?.selectedTab == .feedback)
    }

    @Test
    func authenticatedUsersDoNotRequestManagerPrivileges() async {
        let requestedRole = LockIsolated<Role?>(.manager)
        let store = Store(initialState: RootFeature.State()) { RootFeature() } withDependencies: {
            $0.apiClient.createAccount = { role in
                requestedRole.setValue(role)
                return .mock()
            }
        }

        await store.send(.authenticationStateChanged(.authenticated)).finish()
        #expect(requestedRole.value == nil)
        #expect(store.state.destination.loggedIn?.selectedTab == .feedback)
    }

    @Test
    func anonymousUsersStartOnTeamImprovements() {
        let store = Store(initialState: RootFeature.State()) { RootFeature() }
        store.send(.createAccountResponse(.mockAnonymous(), nil))
        #expect(store.destination.loggedIn?.bootstrap.role == nil)
        #expect(store.destination.loggedIn?.selectedTab == .activities)
    }

    @Test
    func restoredAnonymousSessionStartsOnTeamImprovements() {
        let store = Store(initialState: RootFeature.State()) { RootFeature() }
        store.send(.getSessionResponse(bootstrap: .mockAnonymous()))
        #expect(store.destination.loggedIn?.selectedTab == .activities)
    }

    @Test
    func restoredOwnerSessionStartsOnFeedback() {
        let store = Store(initialState: RootFeature.State()) { RootFeature() }
        store.send(.getSessionResponse(bootstrap: .mock()))
        #expect(store.destination.loggedIn?.selectedTab == .feedback)
    }

    @Test
    func anonymousStartupErrorsRejectLogoutWithoutResettingIdentity() async {
        let store = Store(initialState: RootFeature.State()) { RootFeature() }
        store.send(.presentError(.getSessionError(error: PreviewCatalogFixtures.error)))
        #expect(!store.state.canSignOut)
        await store.send(.logout(.logoutButtonTap)).finish()
        #expect(!store.state.logout.logoutInFlight)
        #expect(!store.state.userRequestedSignUp)
    }

    @Test
    func ownerStartupErrorsRetainLogoutRecovery() async {
        let logoutCalls = LockIsolated(0)
        let store = Store(initialState: RootFeature.State()) { RootFeature() } withDependencies: {
            $0.apiClient.createAccount = { _ in throw URLError(.notConnectedToInternet) }
            $0.apiClient.logout = { logoutCalls.withValue { $0 += 1 } }
            $0.authClient.logout = { logoutCalls.withValue { $0 += 1 } }
        }
        await store.send(.authenticationStateChanged(.authenticated)).finish()
        #expect(store.state.canSignOut)
        await store.send(.logout(.logoutButtonTap)).finish()
        #expect(logoutCalls.value == 2)
    }

    @Test
    func teamInvitationSurvivesColdStartupWithoutSubmittingARequest() {
        let store = Store(initialState: RootFeature.State()) { RootFeature() }
        store.send(.onUrlOpen(.joinTeam(code: "invite-code")))
        store.send(.createAccountResponse(.mockAnonymous(), nil))
        #expect(store.destination.loggedIn?.selectedTab == .activities)
        #expect(store.destination.loggedIn?.employeeTeam.code == "invite-code")
        #expect(store.destination.loggedIn?.employeeTeam.requestID == nil)
    }

}
