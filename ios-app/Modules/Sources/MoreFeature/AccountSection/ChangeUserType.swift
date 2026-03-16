import Domain
import SwiftUI
import ComposableArchitecture

@Reducer
public struct ChangeUserType: Sendable {
    
    @Reducer
    public enum Destination {
        case alert(AlertState<Never>)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents var destination: Destination.State?
        var selectedUserType: Role?
        var isLoading = false
        public init(selectedUserType: Role) {
            self.selectedUserType = selectedUserType
        }
    }
    
    public enum Action: BindableAction {
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case presentError(Error)
        case saveButtonTap
        case updateAccountRoleResponse
        case closeButtonTap
        case delegate(Delegate)
        public enum Delegate {
            case refreshSession
        }
    }
    
    public init() {}
    
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
                guard let role = state.selectedUserType else { return .none }
                state.isLoading = true
                return .run { send in
                    do {
                        try await apiClient.updateAccountRole(role)
                        await send(.updateAccountRoleResponse)
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .updateAccountRoleResponse:
                state.isLoading = false
                return .run { send in
                    await send(.delegate(.refreshSession))
                }
                
            case .delegate:
                return .none
                
            case .closeButtonTap:
                return .run { _ in
                    await dismiss()
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ChangeUserType.Destination.State: Sendable, Equatable {}
