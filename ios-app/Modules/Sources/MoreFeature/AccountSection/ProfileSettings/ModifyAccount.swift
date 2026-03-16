import SwiftUI
import ComposableArchitecture
import Domain

@Reducer
public struct ModifyAccount: Sendable {
    
    @Reducer
    public enum Destination {
        case alert(AlertState<Never>)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents var destination: Destination.State?
        var nameInput: String
        var emailInput: String
        var phoneNumberInput: String
        var isLoading = false
    }
    
    public enum Action: BindableAction {
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case presentError(Error)
        case saveButtonTap
        case updateAccountResponse
    }
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .binding:
                return .none
                
            case .presentError(let error):
                state.isLoading = false
                state.destination = .alert(
                    .init(error: error)
                )
                return .none
                
            case .destination:
                return .none
                
            case .saveButtonTap:
                state.isLoading = true
                return .run { [state = state] send in
                    do {
                        _ = try await self.apiClient.updateAccount(
                            name: state.nameInput,
                            email: state.emailInput,
                            phoneNumber: state.phoneNumberInput
                        )
                        await send(.updateAccountResponse)
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .updateAccountResponse:
                state.isLoading = false
                return .run { _ in
                    await dismiss()
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ModifyAccount.Destination.State: Equatable, Sendable {}
