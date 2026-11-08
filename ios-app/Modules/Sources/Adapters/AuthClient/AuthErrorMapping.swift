import AuthenticationServices
import Domain
import Auth
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
    guard let authError = error as? AuthError else { return error }
    switch authError.errorCode {
    case .overRequestRateLimit, .overEmailSendRateLimit: return AppFailure.rateLimited
    case .sessionNotFound, .refreshTokenNotFound, .refreshTokenAlreadyUsed, .invalidJWT:
        return AuthenticationError.notSignedIn
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

extension Domain.AuthClient {
    func mappingAuthenticationErrors() -> Self {
        var mapped = self
        mapped.signInAnonymously = { try await withAuthErrorMapping { try await self.signInAnonymously() } }
        mapped.googleLogin = { try await withAuthErrorMapping { try await self.googleLogin() } }
        mapped.appleLogin = { try await withAuthErrorMapping { try await self.appleLogin() } }
        mapped.logout = { try await withAuthErrorMapping { try await self.logout() } }
        mapped.restoreTestSession = { token in
            try await withAuthErrorMapping { try await self.restoreTestSession(token) }
        }
        mapped.sendEmailCode = { email in try await withAuthErrorMapping { try await self.sendEmailCode(email) } }
        mapped.verifyEmailCode = { email, code in try await withAuthErrorMapping { try await self.verifyEmailCode(email, code) } }
        return mapped
    }
}
