@testable import TabbarFeature
@testable import FeedbackFlowFeature
@testable import ActivityFeature
@testable import MoreFeature
import ComposableArchitecture
import Domain
import Testing

@MainActor
struct TabbarTests {
    @Test
    func `Account sign out forwards navigation to sign-up`() async {
        let store = TestStore(initialState: Tabbar.State(bootstrap: .init(value: .mock()))) {
            Tabbar()
        }

        await store.send(.accountSection(.signOutButtonTapped))
        await store.receive(\.accountSection.delegate)
        await store.receive(\.delegate, .navigateToSignUp)
    }

    @Test
    func `Profile button opens the profile sheet`() async {
        let store = TestStore(initialState: Tabbar.State(bootstrap: .init(value: .mock()))) {
            Tabbar()
        }

        await store.send(.toolbar(.profileButtonTap)) {
            $0.isProfilePresented = true
        }
    }

    @Test
    func `Join event opens code entry for anonymous participants`() async {
        let store = TestStore(initialState: Tabbar.State(bootstrap: .init(value: .mockAnonymous()))) {
            Tabbar()
        }

        await store.send(.toolbar(.joinEventButtonTap)) {
            $0.destination = .joinEvent(.init())
        }
    }

    @Test
    func `Anonymous users are moved from manager tabs to feedback`() async {
        let store = TestStore(initialState: Tabbar.State(
            bootstrap: .init(value: .mockAnonymous()), selectedTab: .activities
        )) {
            Tabbar()
        }

        await store.send(.validateSelectedTab) {
            $0.selectedTab = .feedback
        }
    }

    @Test
    func `Managers keep their selected tab`() async {
        let store = TestStore(initialState: Tabbar.State(bootstrap: .init(value: .mock()))) {
            Tabbar()
        }

        await store.send(.validateSelectedTab)
    }

    @Test
    func `Sign-up button forwards navigation`() async {
        let store = TestStore(initialState: Tabbar.State(bootstrap: .init(value: .mockAnonymous()))) {
            Tabbar()
        }

        await store.send(.signUpButtonTap)
        await store.receive(\.delegate, .navigateToSignUp)
    }

    @Test
    func `Start feedback from enter code presents the feedback flow`() async {
        let feedback = FeedbackEventDto.mock
        let store = TestStore(initialState: Tabbar.State(bootstrap: .init(value: .mockAnonymous()))) {
            Tabbar()
        } withDependencies: {
            $0.apiClient.startFeedbackEvent = { _ in feedback }
        }

        await store.send(.enterCode(.delegate(.startFeedback(pinCode: feedback.pinCode))))
        await store.receive(\.initialiseFeedback.startFeedback, feedback.pinCode)
        await store.withExhaustivity(.off) {
            await store.receive(\.initialiseFeedback.startFeedbackEventResponse, feedback)
        }
        let flow = store.state.initialiseFeedback.destination?.feedbackFlowCoordinator
        #expect(flow?.feedbackSession == feedback)
        #expect(flow?.path.count == 1)
        #expect(flow?.path.first?.id == feedback.questions.first?.id)
        await store.receive(\.initialiseFeedback.delegate)
        await store.send(.dismissFeedbackFlow) {
            $0.initialiseFeedback.destination = nil
        }
    }
}
