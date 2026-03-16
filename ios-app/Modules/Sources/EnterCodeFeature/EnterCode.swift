import DesignSystem
import ComposableArchitecture
import Foundation
import Domain
import SwiftUI

@Reducer
public struct EnterCode: Sendable {
    
    @ObservableState
    public struct State: Equatable, Sendable {
        public var pinCodeInput: PinCodeInput
        public var startFeedbackPincodeInFlight: Bool
        var enterCodeTextfieldFocused: Bool
        var disableStartFeedbackButton: Bool {
            if pinCodeInput.pinCode() == nil || startFeedbackPincodeInFlight {
                return true
            }
            return false
        }
        public init(
            pinCodeInput: PinCodeInput = .initial(),
            startFeedbackPincodeInFlight: Bool = false,
            enterCodeTextfieldFocused: Bool = false
        ) {
            self.pinCodeInput = pinCodeInput
            self.startFeedbackPincodeInFlight = startFeedbackPincodeInFlight
            self.enterCodeTextfieldFocused = enterCodeTextfieldFocused
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case startFeedbackButtonTap
        case delegate(Delegate)
        case backgroundTap
        public enum Delegate: Equatable {
            case startFeedback(pinCode: PinCode)
        }
    }
    
    public init() {}
    
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            
            switch action {
             
            case .binding:
                return .none
                
            case .startFeedbackButtonTap:
                guard let pinCode = state.pinCodeInput.pinCode() else { return .none }
                state.enterCodeTextfieldFocused = false
                state.startFeedbackPincodeInFlight = true
                return .send(.delegate(.startFeedback(pinCode: pinCode)))
                
            case .delegate:
                return .none
                
            case .backgroundTap:
                state.enterCodeTextfieldFocused = false
                return .none
            }
        }
    }
}
