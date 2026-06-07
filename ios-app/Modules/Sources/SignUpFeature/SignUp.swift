import DesignSystem
import SwiftUI
import Foundation
import ComposableArchitecture
import Domain
import Logger

private enum E2EAuthenticationConfig {
    static let enabledKey = "E2E_ENABLE_TEST_LOGIN"
    static let tokenKey = "E2E_CUSTOM_TOKEN"

    static func tokenFromLaunchArguments() -> String? {
        let userDefaults = UserDefaults.standard
        let enabled = userDefaults.string(forKey: enabledKey) == "1"
        guard enabled else { return nil }

        let token = userDefaults.string(forKey: tokenKey)
        guard let token, !token.isEmpty else { return nil }
        return token
    }
}

@Reducer
public struct SignUp: Sendable {
    
    @Reducer
    public enum Destination {
        case alert(AlertState<Never>)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents public var destination: Destination.State?
        var googleLoginInFlight: Bool
        var appleLoginInFlight: Bool
        var e2eAuthenticationSheetPresented: Bool
        var e2eAuthenticationStatus: String?
        public init(
            destination: Destination.State? = nil,
            googleLoginInFlight: Bool = false,
            appleLoginInFlight: Bool = false,
            e2eAuthenticationSheetPresented: Bool = false,
            e2eAuthenticationStatus: String? = nil
        ) {
            self.destination = destination
            self.googleLoginInFlight = googleLoginInFlight
            self.appleLoginInFlight = appleLoginInFlight
            self.e2eAuthenticationSheetPresented = e2eAuthenticationSheetPresented
            self.e2eAuthenticationStatus = e2eAuthenticationStatus
        }
    }
    
    public enum Action: BindableAction {
        case signUpWithAppleButtonTap
        case signUpWithGoogleButtonTap
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case presentError(Error)
        case loginCancelled
        case signUpSuccess
        case iconTenTimesTap
        case e2eAuthenticationIconTap
        case e2eAuthenticationSheetDismissed
        case e2eLoginWithInjectedTokenTap
        case e2eAuthenticationStatusResponse(String)
    }
    
    public init() {}
    
    @Dependency(\.authClient) var authClient
    @Dependency(\.continuousClock) var clock
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            
            switch action {
            case .e2eAuthenticationIconTap:
                state.e2eAuthenticationSheetPresented = true
                return .none

            case .e2eAuthenticationSheetDismissed:
                state.e2eAuthenticationSheetPresented = false
                return .none

            case .e2eAuthenticationStatusResponse(let status):
                state.e2eAuthenticationStatus = status
                return .none

            case .e2eLoginWithInjectedTokenTap:
                return .run { send in
                    do {
                        guard let token = E2EAuthenticationConfig.tokenFromLaunchArguments() else {
                            await send(.e2eAuthenticationStatusResponse("No injected E2E token found"))
                            return
                        }

                        try await authClient.signInWithCustomToken(token)
                        await send(.e2eAuthenticationStatusResponse("E2E injected token login succeeded"))
                    } catch {
                        await send(.e2eAuthenticationStatusResponse(error.localizedDescription))
                    }
                }
                
            case .iconTenTimesTap:
                return .run { send in
                    guard let token = E2EAuthenticationConfig.tokenFromLaunchArguments() else {
                        Logger.debug("No injected E2E token found")
                        return
                    }

                    do {
                        try await authClient.signInWithCustomToken(token)
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .presentError(let error):
                state.appleLoginInFlight = false
                state.googleLoginInFlight = false
                state.destination = .alert(.init(error: error))
                return .none
                
            case .destination:
                return .none
                
            case .binding:
                return .none
                
            case .signUpWithAppleButtonTap:
                state.appleLoginInFlight = true
                return .run { [authClient = self.authClient] send in
                    do {
                        _ = try await authClient.appleLogin()
                        await send(.signUpSuccess)
                    } catch let error as AuthenticationError where error == .loginCancelled {
                        await send(.loginCancelled)
                        return
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .signUpWithGoogleButtonTap:
                state.googleLoginInFlight = true
                return .run { [authClient = self.authClient] send in
                    do {
                        _ = try await authClient.googleLogin()
                        await send(.signUpSuccess)
                    } catch let error as AuthenticationError where error == .loginCancelled {
                        await send(.loginCancelled)
                        return
                    } catch {
                        await send(.presentError(error))
                    }
                }
            case .loginCancelled:
                state.appleLoginInFlight = false
                state.googleLoginInFlight = false
                return .none
                
            case .signUpSuccess:
                state.appleLoginInFlight = false
                state.googleLoginInFlight = false
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension SignUp.Destination.State: Equatable, Sendable {}
