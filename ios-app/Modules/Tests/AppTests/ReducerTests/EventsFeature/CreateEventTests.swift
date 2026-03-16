@testable import EventsFeature
import Testing
import ComposableArchitecture
import Foundation
import Domain

struct CreateEventTests {
    @Test
    func `Event is created successfully and navigates to detail`() async {
        let mockEvent = ManagerEvent.mock()
        
        let store = await TestStore(
            initialState: CreateEvent.State(
                eventForm: .init(
                    eventInput: .init(.mock()),
                    shouldOpenKeyboardOnAppear: false,
                    recentlyUsedQuestions: .init([]),
                    successOverlayMessage: "Success besked"
                )
            )
        ) {
            CreateEvent()
        } withDependencies: {
            $0.apiClient.createEvent = { _ in mockEvent }
            $0.continuousClock = ImmediateClock()
        }
        
        await store.send(.createEventButtonTap) {
            $0.createEventRequestInFlight = true
        }
        
        await store.receive(\.createEventResponse) {
            $0.createEventRequestInFlight = false
            $0.showSuccessOverlay = true
        }
        await store.receive(\.delegate, .dismissAndNavigateToDetail(mockEvent))
    }
    
    @Test
    func `Event creation failure shows error alert`() async {
        struct Failure: Error, Equatable {}
        let store = await TestStore(initialState: CreateEvent.State(
            eventForm: .init(
                eventInput: .init(.mock()),
                shouldOpenKeyboardOnAppear: false,
                recentlyUsedQuestions: .init([]),
                successOverlayMessage: "Success besked"
            )
        )) {
            CreateEvent()
        } withDependencies: {
            $0.apiClient.createEvent = { _ in throw Failure() }
        }
        
        await store.send(.createEventButtonTap) {
            $0.createEventRequestInFlight = true
        }
        
        await store.receive(\.presentError) {
            $0.createEventRequestInFlight = false
            $0.alert = .init(error: Failure())
        }
    }
}
