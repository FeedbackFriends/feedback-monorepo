import Auth
import Domain
import Foundation

public extension Domain.AuthClient {
    static var live: Self {
        Self(
            signInAnonymously: {
                let client = try SupabaseSession.client()
                guard client.currentSession == nil else { return }
                _ = try await client.signInAnonymously()
            },
            googleLogin: {
                let credentials = try await NativeIdentityService().startGoogleSignInFlow()
                _ = try await SupabaseSession.client().signInWithIdToken(credentials: credentials)
            },
            appleLogin: {
                let credentials = try await NativeIdentityService().startSignInWithAppleFlow()
                _ = try await SupabaseSession.client().signInWithIdToken(credentials: credentials)
            },
            logout: { try await SupabaseSession.client().signOut(scope: .local) },
            userStateChanged: {
                AsyncStream { continuation in
                    let task = Task {
                        do {
                            for await (event, session) in try SupabaseSession.client().authStateChanges {
                                guard event != .tokenRefreshed else { continue }
                                continuation.yield(session.map { $0.user.isAnonymous ? .anonymous : .authenticated } ?? .loggedOut)
                            }
                        } catch {
                            continuation.yield(.loggedOut)
                            continuation.finish()
                        }
                    }
                    continuation.onTermination = { _ in task.cancel() }
                }
            },
            restoreTestSession: { try await SupabaseSession.restoreTestSession($0) },
            sendEmailCode: { email in try await SupabaseSession.client().signInWithOTP(email: email) },
            verifyEmailCode: { email, code in
                _ = try await SupabaseSession.client().verifyOTP(email: email, token: code, type: .email)
            }
        ).mappingAuthenticationErrors()
    }
}
