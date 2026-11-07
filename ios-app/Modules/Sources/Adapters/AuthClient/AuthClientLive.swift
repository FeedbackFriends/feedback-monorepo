import Foundation
import Logger
import FirebaseAuth
import Domain

actor UserStateStream {
    private var continuation: AsyncStream<UserState>.Continuation?
    
    func yield(_ state: UserState) {
        if continuation == nil {
            Logger.log(.error, "UserStateStream yielded but no one is listening")
        }
        continuation?.yield(state)
    }
    
    func stream() -> AsyncStream<UserState> {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }
}

public extension AuthClient {
    
    static var live: Self {
        let stateStream = UserStateStream()
        return Self.init(
            signInAnonymously: {
                guard Auth.auth().currentUser != nil else {
                    Logger.debug("🔥 Firebase signInAnonymously: Signing in anonymously since no user was logged in before")
                    try await Auth.auth().signInAnonymously()
                    return
                }
                Logger.log(.error, "🔥 Firebase signInAnonymously: Sign in anonymously called but user was already logged in.")
            },
            googleLogin: {
                let credential = try await FirebaseService().startGoogleSignInFlow()
                try await credential.signInWithCredential()
            },
            appleLogin: {
                let credential = try await FirebaseService().startSignInWithAppleFlow()
                try await credential.signInWithCredential()
            },
            logout: {
                try Auth.auth().signOut()
            },
            userStateChanged: {
                
                let stream = await stateStream.stream()
                
                _ = Auth.auth().addStateDidChangeListener { _, optionalUser in
                    
                    let userState: UserState = {
                        guard let user = optionalUser.optional else { return .loggedOut }
                        return user.isAnonymous ? .anonymous : .authenticated
                    }()
                    Task { [stateStream] in
                        await stateStream.yield(userState)
                    }
                }
                
                return stream
            },
            signInWithCustomToken: { customToken in
                try await Auth.auth().signIn(withCustomToken: customToken)
                _ = try await Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true)
            }
        ).mappingAuthenticationErrors()
    }
}

extension AuthCredential {
    func signInWithCredential () async throws {
        _ = try await Auth.auth().signIn(with: self)
    }
}
