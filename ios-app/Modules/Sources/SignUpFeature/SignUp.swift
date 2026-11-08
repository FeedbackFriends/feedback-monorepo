import Localization
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
        var email = ""
        var emailCode = ""
        var emailCodeSent = false
        var emailLoginInFlight = false
        var emailResendAt: Date?
        var emailStatus: String?
        var loginInFlight: Bool { emailLoginInFlight || googleLoginInFlight || appleLoginInFlight }
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
        case emailContinueTap
        case emailResendTap
        case emailChangeTap
        case emailCodeSent(Date)
        case emailFailed
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
    @Dependency(\.date.now) var now
    @Dependency(\.continuousClock) var clock
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            
            switch action {
            case .emailChangeTap:
                guard !state.loginInFlight else { return .none }
                state.emailCodeSent = false
                state.emailCode = ""
                state.emailStatus = nil
                return .none

            case .emailCodeSent(let sentAt):
                state.emailLoginInFlight = false
                state.emailCodeSent = true
                state.emailResendAt = sentAt.addingTimeInterval(60)
                state.emailStatus = String(appStrings: .signInCodeSent)
                return .none

            case .emailFailed:
                state.emailLoginInFlight = false
                state.emailStatus = String(appStrings: .signInCodeFailed)
                return .none

            case .emailResendTap:
                guard !state.loginInFlight else { return .none }
                if let resendAt = state.emailResendAt, now < resendAt {
                    state.emailStatus = String(appStrings: .signInResendWait)
                    return .none
                }
                state.emailLoginInFlight = true
                state.emailStatus = nil
                return .run { [email = state.email, now] send in
                    do {
                        try await authClient.sendEmailCode(email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
                        await send(.emailCodeSent(now))
                    } catch { await send(.emailFailed) }
                }

            case .emailContinueTap:
                guard !state.loginInFlight else { return .none }
                let email = state.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                guard email.contains("@"), email.count <= 254,
                      !state.emailCodeSent || !state.emailCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return .none }
                state.emailLoginInFlight = true
                state.emailStatus = nil
                return .run { [verify = state.emailCodeSent, code = state.emailCode, now] send in
                    do {
                        if verify {
                            try await authClient.verifyEmailCode(email, code.trimmingCharacters(in: .whitespacesAndNewlines))
                            await send(.signUpSuccess)
                        } else {
                            try await authClient.sendEmailCode(email)
                            await send(.emailCodeSent(now))
                        }
                    } catch { await send(.emailFailed) }
                }

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
                            await send(.e2eAuthenticationStatusResponse(String(appStrings: .debugNoToken)))
                            return
                        }

                        try await authClient.restoreTestSession(token)
                        await send(.e2eAuthenticationStatusResponse(String(appStrings: .debugLoginSucceeded)))
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
                        try await authClient.restoreTestSession(token)
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
                guard !state.loginInFlight else { return .none }
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
                guard !state.loginInFlight else { return .none }
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
                state.emailLoginInFlight = false
                state.appleLoginInFlight = false
                state.googleLoginInFlight = false
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension SignUp.Destination.State: Equatable, Sendable {}
