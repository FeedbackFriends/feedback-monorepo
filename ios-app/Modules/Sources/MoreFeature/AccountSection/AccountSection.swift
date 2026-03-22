import ComposableArchitecture
import Domain
import SwiftUI

@Reducer
public struct AccountSection: Sendable {
    
    @Reducer
    public enum Destination {
        case profileSettings(ProfileSettings)
        @ReducerCaseEphemeral
        case confirmationDialog(ConfirmationDialogState<ConfirmationDialog>)
        public enum ConfirmationDialog: Equatable, Sendable {
            case logoutConfirmed
        }
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents public var destination: Destination.State?
        @Shared var session: Session
        var accountInfo: AccountInfo {
            session.accountInfo
        }
        public init(session: Shared<Session>) {
            self._session = session
        }
    }
    
    public enum Action: BindableAction {
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case settingsButtonTap
        case signOutButtonTapped
        case deleteAccountButtonTapped
        case delegate(Delegate)
        public enum Delegate: Equatable, Sendable {
            case navigateToSignUp
            case deleteAccountButtonTapped
        }
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .settingsButtonTap:
//                state.destination = .profileSettings(
//                    .init(
//                        role: state.session.role,
//                        accountInfo: state.session.accountInfo
//                    )
//                )
                return .none
                
            case .signOutButtonTapped:
                state.destination = .confirmationDialog(
                    ConfirmationDialogState<Destination.ConfirmationDialog>(
                        title: { TextState("Logout") },
                        actions: {
                            ButtonState(role: .destructive, action: .logoutConfirmed, label: { TextState("Logout") })
                            ButtonState(label: { TextState("Cancel") })
                        },
                        message: { TextState("Are you sure you want to logout?") }
                    )
                )
                return .none
                
            case .deleteAccountButtonTapped:
                return .send(.delegate(.deleteAccountButtonTapped))
                
            case .destination(.presented(.confirmationDialog(let confirmationDialogAction))):
                switch confirmationDialogAction {
                case .logoutConfirmed:
                    return .send(.delegate(.navigateToSignUp))
                }
                
            case .binding:
                return .none
                
            case .delegate:
                return .none
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension AccountSection.Destination.State: Sendable, Equatable {}

private struct AccountSectionDestinationsModifier: ViewModifier {
    @Bindable var store: StoreOf<AccountSection>
    let isDeleteAccountLoading: Bool

    func body(content: Content) -> some View {
        content
            .navigationDestination(
                item: $store.scope(
                    state: \.destination?.profileSettings,
                    action: \.destination.profileSettings
                )
            ) { profileSettingsStore in
                ProfileSettingsView(
                    store: profileSettingsStore,
                    logoutButtonTap: {
                        store.send(.signOutButtonTapped)
                    },
                    deleteAccountButtonTap: {
                        store.send(.deleteAccountButtonTapped)
                    },
                    isDeleteAccountLoading: isDeleteAccountLoading,
                )
            }
            .confirmationDialog(
                $store.scope(
                    state: \.destination?.confirmationDialog,
                    action: \.destination.confirmationDialog
                )
            )
    }
}

public extension View {
    func accountSectionDestinations(
        store: StoreOf<AccountSection>,
        isDeleteAccountLoading: Bool,
    ) -> some View {
        modifier(
            AccountSectionDestinationsModifier(
                store: store,
                isDeleteAccountLoading: isDeleteAccountLoading,
            )
        )
    }
}
