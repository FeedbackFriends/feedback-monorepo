import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct ProfileSettings: Sendable {

    @Reducer
    public enum Destination {
        case modifyAccount(ModifyAccount)
        case alert(AlertState<Never>)
    }

    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents var destination: Destination.State?
        var isOrganizerModeEnabled: Bool
        var persistedRole: Role
        var accountInfo: AccountInfo
        var isLoading = false
        var isInAppNotificationsEnabled = false
        var isEmailEventsEnabled = false

        public init(role: Role, accountInfo: AccountInfo) {
            self.persistedRole = role
            self.isOrganizerModeEnabled = role == .manager
            self.accountInfo = accountInfo
        }
    }

    public enum Action {
        case destination(PresentationAction<Destination.Action>)
        case updateProfileButtonTap
        case organizerModeToggleChanged(Bool)
        case updateAccountRoleResponse(Role)
        case inAppNotificationsToggleChanged(Bool)
        case emailEventsToggleChanged(Bool)
        case presentError(Error)
        case delegate(Delegate)

        public enum Delegate {
            case refreshSession
        }
    }

    private enum CancelID {
        case updateAccountRole
    }

    public init() {}

    @Dependency(\.apiClient) var apiClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .destination:
                return .none

            case .updateProfileButtonTap:
                state.destination = .modifyAccount(
                    .init(
                        nameInput: state.accountInfo.name ?? "",
                        emailInput: state.accountInfo.email ?? "",
                        phoneNumberInput: state.accountInfo.phoneNumber ?? ""
                    )
                )
                return .none

            case .organizerModeToggleChanged(let isEnabled):
                let newRole: Role = isEnabled ? .manager : .participant
                state.isOrganizerModeEnabled = isEnabled
                state.isLoading = true
                return .run { send in
                    do {
                        try await apiClient.updateAccountRole(newRole)
                        await send(.updateAccountRoleResponse(newRole))
                    } catch {
                        await send(.presentError(error))
                    }
                }
                .cancellable(id: CancelID.updateAccountRole, cancelInFlight: true)

            case .updateAccountRoleResponse(let role):
                state.isLoading = false
                state.persistedRole = role
                return .send(.delegate(.refreshSession))

            case .emailEventsToggleChanged(let isEnabled):
                state.isEmailEventsEnabled = isEnabled
                return .none

            case .inAppNotificationsToggleChanged(let isEnabled):
                state.isInAppNotificationsEnabled = isEnabled
                return .none

            case .presentError(let error):
                state.isLoading = false
                state.isOrganizerModeEnabled = state.persistedRole == .manager
                state.destination = .alert(.init(error: error))
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ProfileSettings.Destination.State: Sendable, Equatable {}
