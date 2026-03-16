import ComposableArchitecture
import TabbarFeature
import Network
import SignUpFeature
import DesignSystem
import Domain
import EventsFeature
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
        case createAccountError(error: PresentableError, Role?)
        case getSessionError(error: PresentableError)
        var error: PresentableError {
            switch self {
            case .handleAuthenticatedAccountError(let error):
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
        case getSessionResponse(session: Session, deeplink: Deeplink? = nil)
        case presentError(ErrorType)
        case tryAgainButtonTap(ErrorType)
        case createAccountResponse(Session, Role?)
        case navigateToSelectUserType
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
                
            case .destination(.signUp(.destination(.presented(.selectUserType(.delegate(.getSession)))))):
                return getSession(state: &state, deeplink: nil)
                
            case .destination(.loggedIn(.accountSection(.destination(.presented(.profileSettings(.delegate(.refreshSession))))))):
                return getSession(state: &state, deeplink: nil)
                
            case .destination(.loggedIn(.delegate(.navigateToSignUp))),
                .destination(.loggedIn(.participantEvents(.delegate(.navigateToSignUp)))):
                state.destination = .signUp(.init())
                return .none
                
            case .tryAgainButtonTap(let errorType):
                state.isLoading = true
                switch errorType {
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
                    
                case .loggedOut:
                    state.isLoading = false
                    state.destination = .signUp(.init())
                    return .none
                }
                
            case .destination:
                return .none
                
            case .binding:
                return .none
                
            case .getSessionResponse(let session, let deeplink):
                state.isLoading = false
                let sharedSession = Shared(value: session)
                state.notificationDeeplinkInFlight = false
                guard let deeplink else {
                    state.destination = Destination.State.loggedIn(
                        Tabbar.State(
                            session: sharedSession,
                            selectedTab: .feedback,
                        )
                    )
                    return .none
                }
                state = .fromDeeplink(
                    deeplink: deeplink,
                    sharedSession: sharedSession
                )
                return .none
                
            case .presentError(let errorType):
                Logger.log(.default, "Received error in app core: \(errorType)", nil)
                state.isLoading = false
                state.destination = .error(errorType)
                return .none
                
            case .navigateToSelectUserType:
                state.destination = .signUp(.init(destination: .selectUserType(.init())))
                state.isLoading = false
                return .none
                
            case .createAccountResponse(let session, _):
                state.destination = Destination.State.loggedIn(
                    Tabbar.State(
                        session: Shared(value: session),
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
                    sharedSession: Shared(value: existingState.session)
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
    static func fromDeeplink(deeplink: Deeplink, sharedSession: Shared<Session>) -> Self {
        switch deeplink {
        case .joinEvent(let pinCodeInput):
            return RootFeature.State(
                destination: RootFeature.Destination.State.loggedIn(
                    Tabbar.State(
                        session: sharedSession,
                        destination: .joinEvent(
                            .init(pinCodeInput: pinCodeInput)
                        )
                    )
                )
            )
        case .managerEvent(let eventId):
            var newTabbarState = Tabbar.State(
                session: sharedSession
            )
            if let managerEvent = sharedSession.wrappedValue.managerData?.managerEvents[id: eventId] {
                newTabbarState.managerEvents.destination = .eventDetail(
                    EventDetailFeature.State(
                        event: managerEvent,
                        session: sharedSession
                    )
                )
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
    func createAccount(
        withRole role: Role?,
        state: inout State
    ) -> EffectOf<Self> {
        state.isLoading = true
        return .run { send in
            do {
                let session = try await apiClient.createAccount(role)
                await send(.createAccountResponse(session, role))
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
                let session = try await apiClient.getSession()
                await send(.getSessionResponse(session: session, deeplink: deeplink))
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
                let existingRole = try await authClient.fetchCustomRole()
                guard let existingRole else {
                    await send(.navigateToSelectUserType)
                    return
                }
                let session = try await apiClient.createAccount(existingRole)
                await send(.createAccountResponse(session, existingRole))
            } catch {
                await send(.presentError(.handleAuthenticatedAccountError(error: error.localized)))
            }
        }
    }
}
