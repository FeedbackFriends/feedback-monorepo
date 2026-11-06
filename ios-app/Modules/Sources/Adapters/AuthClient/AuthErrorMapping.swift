import AuthenticationServices
import Domain
import FirebaseAuth
import Foundation
import GoogleSignIn
import Logger

func normalizedAuthError(_ error: any Error) -> any Error {
    if error is CancellationError || error is AuthenticationError || error is AppFailure || error is URLError {
        return error
    }
    let diagnostic = error as NSError
    if diagnostic.domain == ASAuthorizationErrorDomain {
        Logger.debug("Apple authentication failed: \(diagnostic.localizedDescription)")
        return diagnostic.code == ASAuthorizationError.canceled.rawValue
            ? AuthenticationError.loginCancelled : AppFailure.authenticationFailed
    }
    if diagnostic.domain == GIDSignInError.errorDomain {
        Logger.debug("Google authentication failed: \(diagnostic.localizedDescription)")
        return diagnostic.code == GIDSignInError.canceled.rawValue
            ? AuthenticationError.loginCancelled : AppFailure.authenticationFailed
    }
    guard diagnostic.domain == AuthErrors.domain else { return error }
    Logger.debug("Firebase authentication failed: \(diagnostic.localizedDescription)")
    switch AuthErrorCode(rawValue: diagnostic.code) {
    case .networkError:
        // Firebase supplies the underlying URL error when available.
        return (diagnostic.userInfo[NSUnderlyingErrorKey] as? URLError) ?? URLError(.cannotConnectToHost)
    case .tooManyRequests: return AppFailure.rateLimited
    case .userTokenExpired, .invalidUserToken, .userDisabled: return AuthenticationError.notSignedIn
    default: return AppFailure.authenticationFailed
    }
}

private func withAuthErrorMapping<T>(_ operation: () async throws -> T) async throws -> T {
    do {
        return try await operation()
    } catch {
        throw normalizedAuthError(error)
    }
}

extension AuthClient {
    func mappingAuthenticationErrors() -> Self {
        var mapped = self
        mapped.signInAnonymously = { try await withAuthErrorMapping { try await self.signInAnonymously() } }
        mapped.googleLogin = { try await withAuthErrorMapping { try await self.googleLogin() } }
        mapped.appleLogin = { try await withAuthErrorMapping { try await self.appleLogin() } }
        mapped.logout = { try await withAuthErrorMapping { try await self.logout() } }
        mapped.signInWithCustomToken = { token in
            try await withAuthErrorMapping { try await self.signInWithCustomToken(token) }
        }
        return mapped
    }
}
