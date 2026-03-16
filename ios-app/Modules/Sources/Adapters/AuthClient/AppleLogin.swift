import AuthenticationServices
import Foundation
import FirebaseAuth
import Domain

class AppleLogin: NSObject, ASAuthorizationControllerDelegate {
    
    @MainActor var continuation: CheckedContinuation<AuthCredential, Error>?
    var nonce: String
    
    init(continuation: CheckedContinuation<AuthCredential, Error>? = nil, nonce: String) {
        self.continuation = continuation
        self.nonce = nonce
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let continuation = continuation else { return }
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            do {
                
                guard let appleIDToken = appleIDCredential.identityToken else {
                    throw AuthenticationError.identityTokenMissing
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    throw AuthenticationError.tokenSerializationFailed
                }
                let credential = OAuthProvider.credential(
                    providerID: .apple,
                    idToken: idTokenString,
                    rawNonce: nonce
                )
                continuation.resume(returning: credential)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
    }
}
