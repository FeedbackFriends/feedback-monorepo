import AuthenticationServices
import FirebaseAuth
import Firebase
import FirebaseCore
import GoogleSignIn
import Domain

class FirebaseService {
    
    @MainActor
    func startSignInWithAppleFlow() async throws -> AuthCredential {
        
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
        authorizationController.performRequests()
        
        do {
            return try await withCheckedThrowingContinuation { continuation in
                appleLogin.continuation = continuation
            }
        } catch let error as NSError where error.domain == ASAuthorizationErrorDomain && error.code == ASAuthorizationError.canceled.rawValue {
            throw AuthenticationError.loginCancelled
        } catch {
            throw error
        }
    }
    
    @MainActor
    func startGoogleSignInFlow() async throws -> AuthCredential {
        do {
            guard
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let rootViewController = windowScene.windows.first?.rootViewController
            else {
                throw AuthenticationError.couldNotFindWindow
            }
            
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                throw AuthenticationError.couldNotFindClientID
            }
            
            let config = GIDConfiguration(clientID: clientID)
            
            GIDSignIn.sharedInstance.configuration = config
            let googleResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = googleResult.user.idToken?.tokenString else {
                throw URLError(URLError.Code.unknown)
            }
            
            return GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: googleResult.user.accessToken.tokenString
            )
        } catch let error as NSError where error.domain == GIDSignInError.errorDomain && error.code == GIDSignInError.canceled.rawValue {
            throw AuthenticationError.loginCancelled
        } catch {
            throw error
        }
    }
}
