@testable import TabbarFeature
@testable import FeedbackFlowFeature
import ComposableArchitecture
import Foundation
import Testing
@testable import Domain
@testable import MoreFeature
@testable import EventsFeature

@MainActor
struct TabbarTests {
    
    @Test
    func `Sign out button shows confirmation dialog and navigates to sign-up after confirmation`() async {
        
        let store = TestStore(
            initialState: .init(
                session: .init(value: .mock())
            )
        ) {
            Tabbar()
        }
        await store.send(.signOutButtonTapped) {
            $0.destination = .confirmationDialog(
                .init(
                    title: { TextState("Logout") },
                    actions: {
                        ButtonState(role: .destructive, action: .logoutConfirmed, label: { TextState("Logout") })
                        ButtonState(label: { TextState("Cancel") })
                    },
                    message: { TextState("Are you sure you want to logout?") }
                )
            )
        }
        await store.send(.destination(.presented(.confirmationDialog(.logoutConfirmed)))) {
            $0.destination = nil
        }
        await store.receive(\.delegate, .navigateToSignUp)
    }
    
    @Test
    func `Activity button opens activity list and navigates to event detail`() async {
        let event: ManagerEvent = .mock()
        let sharedSession = Shared<Session>(
            value: .init(
                participantEvents: .init(uniqueElements: []),
                managerData: .init(
                    managerEvents: .init(uniqueElements: [event]),
                    activity: .init(
                        items: [.init(
                            id: UUID(),
                            date: Date(),
                            eventTitle: event.title,
                            eventId: event.id,
                            newFeedbackCount: 2,
                            seenByManager: false
                        )],
                        unseenTotal: 2
                    ),
                    recentlyUsedQuestions: .init(),
                    feedbackSessionHash: UUID()
                ),
                accountInfo: .init(
                    name: nil,
                    email: nil,
                    phoneNumber: nil
                ),
                role: .manager
            )
        )
        let session = sharedSession
        let store = TestStore(initialState: .init(session: session)) {
            Tabbar()
        } withDependencies: {
            $0.apiClient.markActivityAsSeen = {}
        }
        await store.send(.toolbar(.activityButtonTap)) {
            $0.destination = .activity(session.activity.items.wrappedValue)
        }
        await store.send(.activityManagerEventButtonTap(session.activity.items.wrappedValue.first!)) {
            $0.managerEvents.destination = .eventDetail(.init(event: event, session: sharedSession))
        }
    }
    
    @Test
    func `Create event button as manager navigates to create screen and event detail`() async {
        let sharedSession = Shared<Session>(
            value: .mock()
        )
        let createdEvent = ManagerEvent.mock()
        let session = sharedSession
        let store = TestStore(initialState: .init(session: session)) {
            Tabbar()
        }
        await store.send(.toolbar(.createEventButtonTap)) {
            $0.destination = .createEvent(
                .init(
                    eventForm: .init(
                        initialFocus: .title,
                        eventInput: .init(),
                        shouldOpenKeyboardOnAppear: true,
                        recentlyUsedQuestions: .init([]),
                        successOverlayMessage: "Session created"
                    )
                )
            )
        }
        await store.send(.destination(.presented(.createEvent(.delegate(.dismissAndNavigateToDetail(createdEvent)))))) {
            $0.destination = nil
            $0.managerEvents.destination = .eventDetail(
                .init(
                    event: createdEvent,
                    destination: .invite(createdEvent),
                    session: $0.$session
                )
            )
        }
    }
    
    @Test
    func `Create event button as anonymous shows login required alert`() async {
        let sharedSession = Shared<Session>(
            value: .mockAnonymous()
        )
        let session = sharedSession
        let store = TestStore(
            initialState: .init(
                session: session
            )
        ) {
            Tabbar()
        }
        await store.send(.toolbar(.createEventButtonTap)) {
            $0.destination = .alert(.init(
                title: { TextState("Login required") },
                actions: {
                    ButtonState(action: .confirmedToCreateUser, label: { TextState("Create account") })
                    ButtonState(role: .cancel, label: { TextState("Not now") })
                },
                message: { TextState("Create an account to access your own events") }
            ))
        }
        await store.send(.destination(.presented(.alert(.confirmedToCreateUser)))) {
            $0.destination = nil
        }
        await store.receive(\.delegate, .navigateToSignUp)
    }
    
    @Test
    func `Join event as anonymous starts feedback flow successfully`() async {
        let session = Shared<Session>(
            value: .mockAnonymous()
        )
        let feedbackSession: FeedbackSession = .mock
        var pinCode: PinCode {
            feedbackSession.pinCode
        }
        let store = TestStore(
            initialState: Tabbar.State(
                session: session,
                selectedTab: .events,
                destination: nil
            )
        ) {
            Tabbar()
        } withDependencies: {
            $0.apiClient.startFeedbackSession = { _ in
                feedbackSession
            }
        }
        await store.send(.toolbar(.joinEventButtonTap)) {
            $0.destination = .joinEvent(.init(pinCodeInput: .initial()))
        }
        await store.send(.destination(.presented(.joinEvent(.delegate(.navigateToParticipantEvent(withPinCode: pinCode)))))) {
            $0.managerEvents.segmentedControl = .participating
            $0.managerEvents.participantEvents.destination = .startFeedbackConfirmation(pinCode)
            $0.participantEvents.destination = .startFeedbackConfirmation(pinCode)
        }
        await store.send(.participantEvents(.confirmedToStartFeedback(pinCode: pinCode)))
        await store.receive(\.participantEvents.startFeedbackButtonTap, pinCode) {
            $0.participantEvents.startFeedbackPincodeInFlight = pinCode
        }
        await store.receive(\.participantEvents.delegate, .startFeedback(pinCode: pinCode))
        await store.receive(\.initialiseFeedback.startFeedback, pinCode)
        await store.withExhaustivity(.off) {
            await store.receive(\.initialiseFeedback.startFeedbackSessionResponse, feedbackSession)
        }
        #expect(store.state.initialiseFeedback.destination!.feedbackFlowCoordinator!.path.first!.id == feedbackSession.questions.first!.id)
        #expect(store.state.initialiseFeedback.destination!.feedbackFlowCoordinator!.path.first!.questionText == feedbackSession.questions.first!.questionText)
        await store.receive(\.initialiseFeedback.delegate, .stopLoading) {
            $0.enterCode.startFeedbackPincodeInFlight = false
            $0.enterCode.pinCodeInput.value = ""
            $0.participantEvents.startFeedbackPincodeInFlight = nil
            $0.managerEvents.participantEvents.startFeedbackPincodeInFlight = nil
        }
    }
    
    @Test
    func `Notification permission prompt cancel button dismisses prompt`() async {
        let store = TestStore(
            initialState: .init(
                session: .init(value: .mock())
            )
        ) {
            Tabbar()
        }
        await store.send(.tabbarLifecyle(.delegate(.presentNotificationPermissionPrompt))) {
            $0.destination = .notificationPermissionPrompt
        }
        await store.send(.dimissNotificationPermissionButtonTap) {
            $0.destination = nil
        }
    }
    
    @Test
    func `Notification permission prompt requests authorization successfully`() async {
        let notificationAuthorizationRequested = LockIsolated(false)
        let store = TestStore(
            initialState: .init(
                session: .init(value: .mock())
            )
        ) {
            Tabbar()
        } withDependencies: {
            $0.notificationClient.requestAuthorization = { @Sendable in
                notificationAuthorizationRequested.setValue(true)
                return true
            }
        }
        await store.send(.tabbarLifecyle(.delegate(.presentNotificationPermissionPrompt))) {
            $0.destination = .notificationPermissionPrompt
        }
        await store.send(.requestNotificationAuthorization) {
            $0.destination = nil
        }
        #expect(notificationAuthorizationRequested.value == true)
    }

    @Test
    func `Start feedback from enter code screen triggers feedback flow`() async {
        let pin = PinCode(value: "123456")
        let store = TestStore(
            initialState: .init(
                session: .init(value: .mock())
            )
        ) {
            Tabbar()
        }
        store.exhaustivity = .off
        await store.send(.enterCode(.delegate(.startFeedback(pinCode: pin))))
        await store.receive(\.initialiseFeedback.startFeedback, pin)
    }
    
    @Test
    func `Start feedback from manager events triggers feedback flow`() async {
        let pin = PinCode(value: "654321")
        let store = TestStore(
            initialState: .init(
                session: .init(value: .mock())
            )
        ) {
            Tabbar()
        }
        store.exhaustivity = .off
        await store.send(.managerEvents(.participantEvents(.delegate(.startFeedback(pinCode: pin)))))
        await store.receive(\.initialiseFeedback.startFeedback, pin)
    }
    
    @Test
    func `Start feedback from participant events triggers feedback flow`() async {
        let pin = PinCode(value: "111111")
        let store = TestStore(
            initialState: .init(
                session: .init(value: .mockAnonymous())
            )
        ) {
            Tabbar()
        }
        store.exhaustivity = .off
        await store.send(.participantEvents(.delegate(.startFeedback(pinCode: pin))))
        await store.receive(\.initialiseFeedback.startFeedback, pin)
    }
}
