@testable import EventsFeature
import Testing
import ComposableArchitecture
import Foundation

struct JoinEventTests {
    @Test
    func `Join event succeeds and navigates to participant event`() async {
        let store = await TestStore(initialState: JoinEvent.State(pinCodeInput: .init(value: "1234"))) {
            JoinEvent()
        } withDependencies: {
            $0.apiClient.joinEvent = { _ in () }
        }
        await store.send(.binding(.set(\.pinCodeTextfieldFocused, true))) {
            $0.pinCodeTextfieldFocused = true
        }
        await store.send(.joinButtonTap) {
            $0.joinRequestInFlight = true
            $0.pinCodeTextfieldFocused = false
        }
        
        await store.receive(\.joinSuccess) {
            $0.joinRequestInFlight = false
            $0.showSuccessOverlay = true
        }
        await store.receive(\.delegate, .navigateToParticipantEvent(withPinCode: .init(value: "1234")))
    }
    
    @Test
    func `Join event failure shows error alert`() async {
        struct Failure: Error, Equatable {}
        let store = await TestStore(initialState: JoinEvent.State(pinCodeInput: .init(value: "1234"))) {
            JoinEvent()
        } withDependencies: {
            $0.apiClient.joinEvent = { _ in throw Failure() }
        }
        
        await store.send(.joinButtonTap) {
            $0.joinRequestInFlight = true
        }
        
        await store.receive(\.presentError) {
            $0.joinRequestInFlight = false
            $0.destination = .alert(.init(error: Failure()))
        }
    }
    
    @Test
    func `Close button dismisses join event view`() async {
        
        let didDismiss = LockIsolated(false)
        
        let store = await TestStore(initialState: JoinEvent.State(pinCodeInput: .init(value: "1234"))) {
            JoinEvent()
        } withDependencies: {
            $0.dismiss = .init({
                didDismiss.setValue(true)
            })
        }
        
        #expect(!didDismiss.value)
        await store.send(.closeButtonTap)
        #expect(didDismiss.value)
    }
}
