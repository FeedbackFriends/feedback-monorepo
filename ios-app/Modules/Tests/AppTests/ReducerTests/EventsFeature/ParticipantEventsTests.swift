@testable import EventsFeature
import Testing
import ComposableArchitecture
import Foundation
import Domain

@MainActor
struct ParticipantEventsTests {
    
    @Test
    func infoButtonTap() async {
        let mockEvent = ParticipantEvent.mock()
        
        let store = TestStore(initialState: ParticipantEvents.State(session: .init(value: .mock()))) {
            ParticipantEvents()
        }
        
        await store.send(.infoButtonTap(mockEvent)) {
            $0.destination = .info(mockEvent)
        }
        await store.send(.binding(.set(\.destination, nil))) {
            $0.destination = nil
        }
    }
    
    @Test
    func `Start feedback button triggers delegate with correct pin code`() async {
        let pinCode = PinCode(value: "1234")
        
        let store = TestStore(initialState: ParticipantEvents.State(session: .init(value: .mock()))) {
            ParticipantEvents()
        }
        
        await store.send(.startFeedbackButtonTap(pinCode: pinCode)) {
            $0.startFeedbackPincodeInFlight = pinCode
        }
        
        await store.receive(\.delegate, .startFeedback(pinCode: pinCode))
    }
    
    @Test
    func confirmedToStartFeedback() async {
        let pinCode = PinCode(value: "1234")
        
        let store = TestStore(initialState: ParticipantEvents.State(session: .init(value: .mock()))) {
            ParticipantEvents()
        }
        
        await store.send(.confirmedToStartFeedback(pinCode: pinCode))
        await store.receive(\.startFeedbackButtonTap) {
            $0.startFeedbackPincodeInFlight = pinCode
        }
        await store.receive(\.delegate, .startFeedback(pinCode: pinCode))
    }
}
