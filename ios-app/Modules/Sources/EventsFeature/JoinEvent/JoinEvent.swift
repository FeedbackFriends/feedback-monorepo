import ComposableArchitecture
import DesignSystem
import Domain
import Foundation

@Reducer
public struct JoinEvent: Sendable {
    
    @Reducer
    public enum Destination {
        case alert(AlertState<Never>)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents var destination: Destination.State?
        var pinCodeInput: PinCodeInput
        var enterCodeKeyboardIsFocused = false
        var showSuccessOverlay = false
        var joinRequestInFlight = false
        var pinCodeTextfieldFocused = false
        var disableJoinButton: Bool {
            if pinCodeInput.pinCode() == nil || joinRequestInFlight || showSuccessOverlay {
                return true
            }
            return false
        }
        public init(pinCodeInput: PinCodeInput = .initial()) {
            self.pinCodeInput = pinCodeInput
        }
    }
    
    public enum Action: BindableAction {
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case presentError(Error)
        case closeButtonTap
        case joinButtonTap
        case joinSuccess(pinCode: PinCode)
        case delegate(Delegate)
        case onAppear
        public enum Delegate: Equatable {
            case navigateToParticipantEvent(withPinCode: PinCode)
        }
    }
    
    public init() {}
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.apiClient) var apiClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                state.pinCodeTextfieldFocused = true
                return .none
                
            case .binding:
                return .none
                
            case .presentError(let error):
                state.joinRequestInFlight = false
                state.destination = .alert(
                    .init(error: error)
                )
                return .none
                
            case .destination:
                return .none
                
            case .closeButtonTap:
                return .run { _ in
                    await dismiss()
                }
                
            case .joinButtonTap:
                guard let pinCode = state.pinCodeInput.pinCode() else {
                    return .none
                }
                state.pinCodeTextfieldFocused = false
                state.joinRequestInFlight = true
                return .run { send in
                    do {
                        _ = try await apiClient.joinEvent(pinCode: pinCode)
                        await send(.joinSuccess(pinCode: pinCode))
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .joinSuccess(let pinCode):
                state.joinRequestInFlight = false
                state.showSuccessOverlay = true
                return .send(.delegate(.navigateToParticipantEvent(withPinCode: pinCode)))
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension JoinEvent.Destination.State: Equatable, Sendable {}
