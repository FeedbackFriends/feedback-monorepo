import ComposableArchitecture
import Domain
import SwiftUI

@Reducer
public struct ParticipantEvents: Sendable {
    
    @Reducer
    public enum Destination {
        @ReducerCaseIgnored
        case info(ParticipantEvent)
        @ReducerCaseIgnored
        case startFeedbackConfirmation(PinCode)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents public var destination: Destination.State?
        @Shared var session: Session
        public var startFeedbackPincodeInFlight: PinCode?
        public init(session: Shared<Session>) {
            self._session = session
        }
    }
    
    public enum Action: BindableAction {
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case infoButtonTap(ParticipantEvent)
        case startFeedbackButtonTap(pinCode: PinCode)
        case confirmedToStartFeedback(pinCode: PinCode)
        case delegate(Delegate)
        public enum Delegate: Equatable {
            case startFeedback(pinCode: PinCode)
            case navigateToSignUp
        }
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .binding:
                return .none
                
            case .confirmedToStartFeedback(pinCode: let pinCode):
                return .send(.startFeedbackButtonTap(pinCode: pinCode))
                
            case .destination:
                return .none
                
            case .startFeedbackButtonTap(pinCode: let pinCode):
                state.startFeedbackPincodeInFlight = pinCode
                return .send(.delegate(.startFeedback(pinCode: pinCode)))
                
            case .delegate:
                return .none
                
            case .infoButtonTap(let event):
                state.destination = .info(event)
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ParticipantEvents.Destination.State: Equatable, Sendable {}
