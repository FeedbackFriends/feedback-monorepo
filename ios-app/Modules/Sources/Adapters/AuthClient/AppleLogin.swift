import AuthenticationServices
import Foundation
import Auth
import Domain

class AppleLogin: NSObject, ASAuthorizationControllerDelegate {
    
    @MainActor var continuation: CheckedContinuation<OpenIDConnectCredentials, Error>?
    var nonce: String
    
    init(continuation: CheckedContinuation<OpenIDConnectCredentials, Error>? = nil, nonce: String) {
        self.continuation = continuation
        self.nonce = nonce
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let continuation = continuation else { return }
        self.continuation = nil
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            do {
                
                guard let appleIDToken = appleIDCredential.identityToken else {
                    throw AuthenticationError.identityTokenMissing
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    throw AuthenticationError.tokenSerializationFailed
                }
                let credential = OpenIDConnectCredentials(
                    provider: .apple,
                    idToken: idTokenString,
                    nonce: nonce
                )
                continuation.resume(returning: credential)
            } catch {
                continuation.resume(throwing: error)
            }
        } else {
            continuation.resume(throwing: AuthenticationError.identityTokenMissing)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
