import Foundation
import Domain
import ComposableArchitecture

extension DeleteAccount.Destination.State: Sendable, Equatable {}

@Reducer
public struct DeleteAccount: Sendable {
    
    @Reducer
    public enum Destination {
        case alert(AlertState<AlertAction>)
        public enum AlertAction: Equatable, Sendable {
            case confirmedToDeleteAccount
            case closeSessionButtonTap
            case logout
        }
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents var destination: Destination.State?
        var deleteAccountInFlight: Bool
        public init(
            destination: Destination.State? = nil,
            deleteAccountInFlight: Bool = false
        ) {
            self.destination = destination
            self.deleteAccountInFlight = deleteAccountInFlight
        }
    }
    
    public enum Action {
        case destination(PresentationAction<Destination.Action>)
        case deleteAccountButtonTapped
        case presentError(Error)
        case accountSuccesfullyDeleted
        case logoutFailed
    }
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.notificationClient) var notificationClient
    @Dependency(\.authClient) var authClient
    @Dependency(\.continuousClock) var clock
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .deleteAccountButtonTapped:
                state.destination = .alert(
                    AlertState<Destination.AlertAction>(
                        title: { TextState("Are you sure?") },
                        actions: {
                            ButtonState(
                                role: .destructive,
                                action: .confirmedToDeleteAccount,
                                label: { TextState("Delete account") }
                            )
                            ButtonState(
                                role: .cancel,
                                label: { TextState("Cancel") }
                            )
                        },
                        message: { TextState("All data related to your account will be deleted and cannot be restored. ⚠️") }
                    )
                )
                return .none
                
            case .accountSuccesfullyDeleted:
                state.deleteAccountInFlight = false
                state.destination = .alert(
                    AlertState<Destination.AlertAction>(
                        title: { TextState("Account deleted.") },
                        actions: {
                            ButtonState(
                                role: .cancel,
                                action: .send(.closeSessionButtonTap),
                                label: { TextState("Close") }
                            )
                        },
                        message: { TextState("Thank you for using Lets Grow.") }
                    )
                )
                return .none
                
            case .destination(.presented(.alert(let alertAction))):
                switch alertAction {
                    
                case .confirmedToDeleteAccount:
                    state.deleteAccountInFlight = true
                    return .run { send in
                        do {
                            try await clock.sleep(for: .seconds(1))
                            _ = try await apiClient.deleteAccount()
                            await send(.accountSuccesfullyDeleted)
                        } catch {
                            await send(.presentError(error))
                        }
                    }
                    
                case .closeSessionButtonTap:
                    return .run { send in
                        do {
                            try await authClient.logout()
                        } catch {
                            await send(.logoutFailed)
                        }
                    }
                    
                case .logout:
                    return .run { send in
                        do {
                            try await authClient.logout()
                        } catch {
                            await send(.logoutFailed)
                        }
                    }
                }
                
            case .logoutFailed:
                state.destination = .alert(
                    AlertState<Destination.AlertAction>(
                        title: { TextState("Logout failed.") },
                        actions: {
                            ButtonState(
                                action: .send(.logout),
                                label: { TextState("Log out") }
                            )
                        },
                        message: { TextState("Please try again.") }
                    )
                )
                return .none
                
            case .destination:
                return .none
                
            case .presentError(let error):
                state.deleteAccountInFlight = false
                state.destination = .alert(.init(error: error))
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
