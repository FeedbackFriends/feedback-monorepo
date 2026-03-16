@testable import EnterCodeFeature
import Testing
import ComposableArchitecture
import Foundation
import Domain

@MainActor
struct EnterCodeTests {
    
    @Test
    func `Start feedback button triggers delegate with entered pin code`() async {
        let store = TestStore(initialState: EnterCode.State(pinCodeInput: PinCodeInput.initial())) {
            EnterCode()
        }
        await store.send(.binding(.set(\.pinCodeInput.value, "1234"))) {
            $0.pinCodeInput.value = "1234"
        }
        await store.send(.binding(.set(\.enterCodeTextfieldFocused, true))) {
            $0.enterCodeTextfieldFocused = true
        }
        await store.send(.startFeedbackButtonTap) {
            $0.startFeedbackPincodeInFlight = true
            $0.enterCodeTextfieldFocused = false
        }
        await store.receive(\.delegate, .startFeedback(pinCode: .init(value: "1234")))
    }
}
