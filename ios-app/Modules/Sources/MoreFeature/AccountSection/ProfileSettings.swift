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
        var accountInfo: AccountInfo
        var isLoading = false
        var isInAppNotificationsEnabled = false
        var isEmailEventsEnabled = false

        public init(accountInfo: AccountInfo) {
            self.accountInfo = accountInfo
        }
    }

    public enum Action {
        case destination(PresentationAction<Destination.Action>)
        case updateProfileButtonTap
        case inAppNotificationsToggleChanged(Bool)
        case emailEventsToggleChanged(Bool)
        case presentError(Error)
    }

    public init() {}

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

            case .emailEventsToggleChanged(let isEnabled):
                state.isEmailEventsEnabled = isEnabled
                return .none

            case .inAppNotificationsToggleChanged(let isEnabled):
                state.isInAppNotificationsEnabled = isEnabled
                return .none

            case .presentError(let error):
                state.isLoading = false
                state.destination = .alert(.init(error: error))
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ProfileSettings.Destination.State: Sendable, Equatable {}
