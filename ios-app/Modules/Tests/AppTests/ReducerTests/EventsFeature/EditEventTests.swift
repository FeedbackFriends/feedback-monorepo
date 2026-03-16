@testable import EventsFeature
import Testing
import ComposableArchitecture
import Foundation

@MainActor
struct EditEventTests {
    @Test
    func `Edit event succeeds and shows success overlay`() async {
        var updateEventCalled = false
        let store = TestStore(
            initialState: EditEvent.State(
                eventForm: .init(
                    eventInput: .init(title: "Meeting", questions: [.init(questionText: "Q1", feedbackType: .emoji)]),
                    shouldOpenKeyboardOnAppear: false,
                    recentlyUsedQuestions: .init([]),
                    successOverlayMessage: "Success edit"
                ),
                eventId: UUID(),
                recentlyUsedQuestions: .init([])
            )
        ) {
            EditEvent()
        } withDependencies: {
            $0.apiClient.updateEvent = { @MainActor _, _ in
                updateEventCalled = true
                return .mock()
            }
            $0.continuousClock = ImmediateClock()
        }
        
        await store.send(.editEventButtonTap) {
            $0.editRequestInFlight = true
        }
        await store.receive(\.editEventResponse) {
            $0.editRequestInFlight = false
            $0.showSuccessOverlay = true
        }
        #expect(updateEventCalled == true)
    }
    
    @Test
    func `Edit event fails and shows error alert`() async {
        struct Failure: Error, Equatable {}
        
        let store = TestStore(
            initialState: EditEvent.State(
                eventForm: .init(
                    eventInput: .init(title: "Meeting", questions: [.init(questionText: "Q1", feedbackType: .emoji)]),
                    shouldOpenKeyboardOnAppear: false,
                    recentlyUsedQuestions: .init([]),
                    successOverlayMessage: "Success edit"
                ),
                eventId: UUID(),
                recentlyUsedQuestions: .init([])
            )
        ) {
            EditEvent()
        } withDependencies: {
            $0.apiClient.updateEvent = { _, _ in throw Failure() }
        }
        
        await store.send(.editEventButtonTap) {
            $0.editRequestInFlight = true
        }
        
        await store.receive(\.presentError) {
            $0.editRequestInFlight = false
            $0.alert = .init(error: Failure())
        }
    }
}
