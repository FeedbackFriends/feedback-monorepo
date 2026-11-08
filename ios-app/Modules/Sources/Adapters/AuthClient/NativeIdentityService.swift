import AuthenticationServices
import Auth
import Foundation
import UIKit
import GoogleSignIn
import Domain

class NativeIdentityService {
    
    @MainActor
    func startSignInWithAppleFlow() async throws -> OpenIDConnectCredentials {
        
        let appleLogin = AppleLogin(
            continuation: nil,
            nonce: CryptoHelper.randomNonceString()
        )
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = CryptoHelper.sha256(appleLogin.nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = appleLogin
        defer {
            withExtendedLifetime(appleLogin) {}
            withExtendedLifetime(authorizationController) {}
        }
        
        do {
            return try await withCheckedThrowingContinuation { continuation in
                appleLogin.continuation = continuation
                authorizationController.performRequests()
            }
        } catch let error as NSError where error.domain == ASAuthorizationErrorDomain && error.code == ASAuthorizationError.canceled.rawValue {
            throw AuthenticationError.loginCancelled
        } catch {
            throw error
        }
    }
    
    @MainActor
    func startGoogleSignInFlow() async throws -> OpenIDConnectCredentials {
        do {
            guard
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let rootViewController = windowScene.windows.first?.rootViewController
            else {
                throw AuthenticationError.couldNotFindWindow
            }
            
            guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_CLIENT_ID") as? String,
                  !clientID.isEmpty, !clientID.hasPrefix("$(") else {
                throw AuthenticationError.couldNotFindClientID
            }
            
            let config = GIDConfiguration(clientID: clientID)
            
            GIDSignIn.sharedInstance.configuration = config
            let googleResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = googleResult.user.idToken?.tokenString else {
                throw URLError(URLError.Code.unknown)
            }
            
            return OpenIDConnectCredentials(provider: .google, idToken: idToken, accessToken: googleResult.user.accessToken.tokenString)
        } catch let error as NSError where error.domain == GIDSignInError.errorDomain && error.code == GIDSignInError.canceled.rawValue {
            throw AuthenticationError.loginCancelled
        } catch {
            throw error
        }
    }
}
