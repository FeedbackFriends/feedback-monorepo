import DesignSystem
import SwiftUI
import Foundation
import ComposableArchitecture
import Domain
import Logger

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
        var anonymousLoginInFlight: Bool
        var e2eAuthenticationSheetPresented: Bool
        var e2eAuthenticationStatus: String?
        public init(
            destination: Destination.State? = nil,
            googleLoginInFlight: Bool = false,
            appleLoginInFlight: Bool = false,
            anonymousLoginInFlight: Bool = false,
            e2eAuthenticationSheetPresented: Bool = false,
            e2eAuthenticationStatus: String? = nil
        ) {
            self.destination = destination
            self.googleLoginInFlight = googleLoginInFlight
            self.appleLoginInFlight = appleLoginInFlight
            self.anonymousLoginInFlight = anonymousLoginInFlight
            self.e2eAuthenticationSheetPresented = e2eAuthenticationSheetPresented
            self.e2eAuthenticationStatus = e2eAuthenticationStatus
        }
    }
    
    public enum Action: BindableAction {
        case signUpWithAppleButtonTap
        case signUpWithGoogleButtonTap
        case skipButtonTap
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case presentError(Error)
        case loginCancelled
        case signUpSuccess
        case iconTenTimesTap
        case e2eAuthenticationIconTap
        case e2eAuthenticationSheetDismissed
        case e2eSeedParticipantWithDataTap
        case e2eSeedParticipantEmptyTap
        case e2eSeedManagerWithDataTap
        case e2eSeedManagerEmptyTap
        case e2eSeedEmptyAccountTap
        case e2eLoginWithIdTap(String)
        case e2eLoginWithPresetTap(String)
        case e2eAuthenticationStatusResponse(String)
    }
    
    public init() {}
    
    @Dependency(\.authClient) var authClient
    @Dependency(\.continuousClock) var clock
    @Dependency(\.apiClient) var apiClient
    
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

            case .e2eSeedParticipantWithDataTap:
                return .run { send in
                    do {
                        let token = try await apiClient.seedParticipantWithData()
                        try await authClient.signInWithCustomToken(token.token)
                        await send(.e2eAuthenticationStatusResponse("Seed participant with data succeeded"))
                    } catch {
                        await send(.e2eAuthenticationStatusResponse(error.localizedDescription))
                    }
                }

            case .e2eSeedParticipantEmptyTap:
                return .run { send in
                    do {
                        let token = try await apiClient.seedParticipantEmpty()
                        try await authClient.signInWithCustomToken(token.token)
                        await send(.e2eAuthenticationStatusResponse("Seed participant empty succeeded"))
                    } catch {
                        await send(.e2eAuthenticationStatusResponse(error.localizedDescription))
                    }
                }

            case .e2eSeedManagerWithDataTap:
                return .run { send in
                    do {
                        let token = try await apiClient.seedManagerWithData()
                        try await authClient.signInWithCustomToken(token.token)
                        await send(.e2eAuthenticationStatusResponse("Seed manager with data succeeded"))
                    } catch {
                        await send(.e2eAuthenticationStatusResponse(error.localizedDescription))
                    }
                }

            case .e2eSeedManagerEmptyTap:
                return .run { send in
                    do {
                        let token = try await apiClient.seedManagerEmpty()
                        try await authClient.signInWithCustomToken(token.token)
                        await send(.e2eAuthenticationStatusResponse("Seed manager empty succeeded"))
                    } catch {
                        await send(.e2eAuthenticationStatusResponse(error.localizedDescription))
                    }
                }

            case .e2eSeedEmptyAccountTap:
                return .run { send in
                    do {
                        let token = try await apiClient.seedEmptyAccount()
                        try await authClient.signInWithCustomToken(token.token)
                        await send(.e2eAuthenticationStatusResponse("Seed empty account succeeded"))
                    } catch {
                        await send(.e2eAuthenticationStatusResponse(error.localizedDescription))
                    }
                }

            case .e2eLoginWithIdTap(let loginId):
                return .run { send in
                    do {
                        let token = try await apiClient.login(loginId)
                        try await authClient.signInWithCustomToken(token.token)
                        await send(.e2eAuthenticationStatusResponse("E2E login endpoint with id \(loginId) succeeded"))
                    } catch {
                        await send(.e2eAuthenticationStatusResponse(error.localizedDescription))
                    }
                }

            case .e2eLoginWithPresetTap(let presetLoginId):
                return .run { send in
                    do {
                        let token = try await apiClient.login(presetLoginId)
                        try await authClient.signInWithCustomToken(token.token)
                        await send(.e2eAuthenticationStatusResponse("E2E login endpoint with preset \(presetLoginId) succeeded"))
                    } catch {
                        await send(.e2eAuthenticationStatusResponse(error.localizedDescription))
                    }
                }
                
            case .iconTenTimesTap:
                return .run { _ in
                    do {
                        let token = try await apiClient.login("mock_id")
                        try await authClient.signInWithCustomToken(token.token)
                    } catch {
                        Logger.debug(error.localizedDescription)
                    }
                }
                
            case .presentError(let error):
                state.appleLoginInFlight = false
                state.googleLoginInFlight = false
                state.anonymousLoginInFlight = false
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
            case .skipButtonTap:
                state.anonymousLoginInFlight = true
                return .run { [authClient = self.authClient] send in
                    do {
                        try await authClient.signInAnonymously()
                        await send(.signUpSuccess)
                    } catch {
                        await send(.presentError(error))
                    }
                }
            case .loginCancelled:
                state.appleLoginInFlight = false
                state.googleLoginInFlight = false
                state.anonymousLoginInFlight = false
                return .none
                
            case .signUpSuccess:
                state.appleLoginInFlight = false
                state.googleLoginInFlight = false
                state.anonymousLoginInFlight = false
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension SignUp.Destination.State: Equatable, Sendable {}
