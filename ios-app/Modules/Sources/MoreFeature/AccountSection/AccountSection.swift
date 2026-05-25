import ComposableArchitecture
import Domain
import SwiftUI

@Reducer
public struct AccountSection: Sendable {
    
    @Reducer
    public enum Destination {
        case profileSettings(ProfileSettings)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents public var destination: Destination.State?
        @Shared var bootstrap: Bootstrap
        var accountInfo: AccountInfo {
            bootstrap.accountInfo
        }
        public init(bootstrap: Shared<Bootstrap>) {
            self._bootstrap = bootstrap
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
                state.destination = .profileSettings(
                    .init(
                        role: state.bootstrap.role,
                        accountInfo: state.bootstrap.accountInfo
                    )
                )
                return .none
                
            case .signOutButtonTapped:
                return .send(.delegate(.navigateToSignUp))
                
            case .deleteAccountButtonTapped:
                return .send(.delegate(.deleteAccountButtonTapped))
                
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
