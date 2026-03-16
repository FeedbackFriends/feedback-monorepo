import SwiftUI
import ComposableArchitecture
import Domain
import DesignSystem

@Reducer
public struct SelectUserType: Sendable {
    
    @Reducer
    public enum Destination {
        case alert(AlertState<Never>)
        case notificationPermissionPrompt(NotificationPermissionPrompt)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents var destination: Destination.State?
        var selectedUserType: Role?
        public init() {}
        var isLoading: Bool = false
        var disableUserTypeSelectionButton: Bool {
            selectedUserType == nil
        }
    }
    
    public enum Action: BindableAction {
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case presentError(Error)
        case createAccountButtonTap
        case createAccountResponse
        case delegate(Delegate)
        public enum Delegate {
            case getSession
        }
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    
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
                
            case .createAccountButtonTap:
                state.isLoading = true
                return .run { [role = state.selectedUserType, apiClient = self.apiClient] send in
                    do {
                        _ = try await apiClient.createAccount(role)
                        await send(.createAccountResponse)
                    } catch {
                        await send(.presentError(error))
                    }
                }

            case .createAccountResponse:
                state.isLoading = false
                state.destination = .notificationPermissionPrompt(.init())
                return .none

            case .destination(.presented(.notificationPermissionPrompt(.delegate(.completed)))):
                return .send(.delegate(.getSession))

            case .destination:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension SelectUserType.Destination.State: Equatable, Sendable {}
