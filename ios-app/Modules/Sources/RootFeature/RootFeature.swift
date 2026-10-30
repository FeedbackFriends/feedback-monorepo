import ComposableArchitecture
import TabbarFeature
import Network
import SignUpFeature
import DesignSystem
import Domain
import ActivityFeature
import Logger
import Foundation

@Reducer
public struct RootFeature: Sendable {
    
    @Reducer
    public enum Destination {
        case signUp(SignUp)
        @ReducerCaseIgnored
        case error(ErrorType)
        case loggedIn(Tabbar)
        @ReducerCaseEphemeral
        case isLoading
    }
    
    public enum ErrorType: Equatable {
        case handleAuthenticatedAccountError(error: PresentableError)
        case anonymousSignUpError(error: PresentableError)
        case createAccountError(error: PresentableError, Role?)
        case getSessionError(error: PresentableError)
        var error: PresentableError {
            switch self {
            case .handleAuthenticatedAccountError(let error):
                return error
            case .anonymousSignUpError(let error):
                return error
            case .createAccountError(let error, _):
                return error
            case .getSessionError(let error):
                return error
            }
        }
    }
    
    @ObservableState
    public struct State {
        var notificationDeeplinkInFlight = false
        /// Set when the user explicitly asks to sign up / sign out, so that the
        /// resulting `.loggedOut` state shows the SignUp screen instead of
        /// silently signing back in anonymously.
        var userRequestedSignUp = false
        var destination: Destination.State
        var isLoading: Bool
        var logout: Logout.State
        public init(
            destination: Destination.State = .isLoading,
            isLoading: Bool = false,
            logout: Logout.State = .init(),
        ) {
            self.destination = destination
            self.isLoading = isLoading
            self.logout = logout
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(Destination.Action)
        case getSessionResponse(bootstrap: Bootstrap, deeplink: Deeplink? = nil)
        case presentError(ErrorType)
        case tryAgainButtonTap(ErrorType)
        case createAccountResponse(Bootstrap, Role?)
        case logout(Logout.Action)
        case onNotificationTap(Deeplink)
        case onUrlOpen(Deeplink)
        case onAppOpen
        case didReceiveFCMToken(String?)
        case authenticationStateChanged(UserState)
    }
    
    public init() {}
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.authClient) var authClient
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.continuousClock) var clock
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.logout, action: \.logout) {
            Logout()
        }
        Scope(state: \.destination, action: \.destination) {
            Destination.body
        }
        Reduce { state, action in
            switch action {
                
            case .destination(.loggedIn(.delegate(.navigateToSignUp))):
                state.userRequestedSignUp = true
                return .send(.logout(.logoutButtonTap))
                
            case .tryAgainButtonTap(let errorType):
                state.isLoading = true
                switch errorType {
                    
                case .anonymousSignUpError:
                    return signInAnonymously(state: &state)
                    
                case .createAccountError(_, let role):
                    return createAccount(withRole: role, state: &state)
                    
                case .getSessionError:
                    return getSession(state: &state, deeplink: nil)
                    
                case .handleAuthenticatedAccountError:
                    return handeAuthenticatedAccount(state: &state)
                }
                
            case .authenticationStateChanged(let authState):
                Logger.debug("Auth state changed: \(authState)")
                if state.notificationDeeplinkInFlight {
                    return .none
                }
                switch authState {
                    
                case .authenticated:
                    return handeAuthenticatedAccount(state: &state)
                    
                case .anonymous:
                    return createAccount(withRole: nil, state: &state)
                    
                case .loggedOut:
                    // When the user explicitly asked to sign up / sign out, take
                    // them to the SignUp screen. Otherwise (e.g. a fresh launch)
                    // sign them in anonymously so they land straight in the app.
                    if state.userRequestedSignUp {
                        state.userRequestedSignUp = false
                        state.destination = .signUp(.init())
                        state.isLoading = false
                        return .none
                    }
                    return signInAnonymously(state: &state)
                }
                
            case .destination:
                return .none
                
            case .binding:
                return .none
                
            case .getSessionResponse(let bootstrap, let deeplink):
                state.isLoading = false
                let sharedBootstrap = Shared(value: bootstrap)
                state.notificationDeeplinkInFlight = false
                guard let deeplink else {
                    state.destination = Destination.State.loggedIn(
                        Tabbar.State(
                            bootstrap: sharedBootstrap,
                            selectedTab: .feedback,
                        )
                    )
                    return .none
                }
                state = .fromDeeplink(
                    deeplink: deeplink,
                    sharedBootstrap: sharedBootstrap
                )
                return .none
                
            case .presentError(let errorType):
                Logger.log(.default, "Received error in app core: \(errorType)", nil)
                state.isLoading = false
                state.destination = .error(errorType)
                return .none
                
            case .createAccountResponse(let bootstrap, let role):
                state.isLoading = false
                state.destination = Destination.State.loggedIn(
                    Tabbar.State(
                        bootstrap: Shared(value: bootstrap),
                        selectedTab: .feedback
                    )
                )
                return .none
                
            case .logout:
                return .none
                
            case .onNotificationTap(let deeplink):
                state.notificationDeeplinkInFlight = true
                return .merge(
                    getSession(state: &state, deeplink: deeplink)
                )
                
            case .onUrlOpen(let deeplink):
                guard case let .loggedIn(existingState) = state.destination else {
                    return .none
                }
                state = .fromDeeplink(
                    deeplink: deeplink,
                    sharedBootstrap: existingState.$bootstrap
                )
                return .none
                
            case .onAppOpen:
                return .run { send in
                    let userStateChangedStream = await authClient.userStateChanged()
                    for await loggedInUser in userStateChangedStream {
                        Logger.debug("🔐 Auth state changed to: \(loggedInUser)")
                        await send(.authenticationStateChanged(loggedInUser), animation: .bouncy(duration: 1))
                    }
                }
                
            case .didReceiveFCMToken(let fcmToken):
                guard let fcmToken else { return .none }
                return .run { _ in
                    do {
                        try await apiClient.linkFCMTokenToAccount(fcmToken)
                    } catch {
                        Logger.log(.error, "Update fcm token api call failed silently with error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

extension RootFeature.State {
    static func fromDeeplink(deeplink: Deeplink, sharedBootstrap: Shared<Bootstrap>) -> Self {
        switch deeplink {
        case .joinEvent(let pinCodeInput):
            return RootFeature.State(
                destination: RootFeature.Destination.State.loggedIn(
                    Tabbar.State(
                        bootstrap: sharedBootstrap,
                        destination: .joinEvent(
                            .init(pinCodeInput: pinCodeInput)
                        )
                    )
                )
            )
        case .managerEvent(let eventId):
            var newTabbarState = Tabbar.State(
                bootstrap: sharedBootstrap,
                selectedTab: .activities
            )
            if let activity = sharedBootstrap.wrappedValue.managerData?.activities.first(where: {
                $0.events.contains { $0.id == eventId }
            }) {
                newTabbarState.activities.path.append(.activityDetail(.init(activityId: activity.id, bootstrap: sharedBootstrap)))
                newTabbarState.activities.path.append(.eventDetail(.init(
                    activityId: activity.id, eventId: eventId, bootstrap: sharedBootstrap
                )))
            }
            return RootFeature.State(
                destination: RootFeature.Destination.State.loggedIn(
                    newTabbarState
                )
            )
        }
    }
}

extension RootFeature.Destination.State: Equatable {}

/// Helpers
private extension RootFeature {
    func signInAnonymously(state: inout State) -> EffectOf<Self> {
        state.isLoading = true
        state.destination = .isLoading
        return .run { send in
            do {
                // The Firebase auth state listener started in `.onAppOpen` will
                // pick up the new anonymous user and drive the rest of the flow
                // via `.authenticationStateChanged(.anonymous)`.
                try await authClient.signInAnonymously()
            } catch {
                await send(.presentError(.anonymousSignUpError(error: error.localized)))
            }
        }
    }

    func createAccount(
        withRole role: Role?,
        state: inout State
    ) -> EffectOf<Self> {
        state.isLoading = true
        return .run { send in
            do {
                let bootstrap = try await apiClient.createAccount(role)
                await send(.createAccountResponse(bootstrap, role))
            } catch {
                await send(.presentError(ErrorType.createAccountError(error: error.localized, role)))
            }
        }
    }
    
    func getSession(state: inout State, deeplink: Deeplink?) -> EffectOf<Self> {
        state.isLoading = true
        state.destination = .isLoading
        return .run { send in
            do {
                let bootstrap = try await apiClient.getBootstrap()
                await send(.getSessionResponse(bootstrap: bootstrap, deeplink: deeplink))
            } catch {
                await send(.presentError(ErrorType.getSessionError(error: error.localized)))
            }
        }
    }
    
    func handeAuthenticatedAccount(state: inout State) -> EffectOf<Self> {
        state.isLoading = true
        state.destination = .isLoading
        return .run { send in
            do {
                let role = Role.manager
                let bootstrap = try await apiClient.createAccount(role)
                await send(.createAccountResponse(bootstrap, role))
            } catch {
                await send(.presentError(.handleAuthenticatedAccountError(error: error.localized)))
            }
        }
    }
}
