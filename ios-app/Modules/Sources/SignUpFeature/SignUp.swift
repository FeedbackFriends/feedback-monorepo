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
        case selectUserType(SelectUserType)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents public var destination: Destination.State?
        var googleLoginInFlight: Bool
        var appleLoginInFlight: Bool
        public init(
            destination: Destination.State? = nil,
            googleLoginInFlight: Bool = false,
            appleLoginInFlight: Bool = false
        ) {
            self.destination = destination
            self.googleLoginInFlight = googleLoginInFlight
            self.appleLoginInFlight = appleLoginInFlight
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
    }
    
    public init() {}
    
    @Dependency(\.authClient) var authClient
    @Dependency(\.continuousClock) var clock
    @Dependency(\.apiClient) var apiClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            
            switch action {
                
            case .iconTenTimesTap:
                return .run { _ in
                    do {
                        let mockToken = try await apiClient.getMockToken()
                        try await authClient.signInWithCustomToken(mockToken)
                    } catch {
                        Logger.debug(error.localizedDescription)
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
