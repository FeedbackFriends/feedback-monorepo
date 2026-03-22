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
            fetchCustomRole: {
                guard let currentUser = Auth.auth().currentUser else {
                    throw AuthenticationError.notSignedIn
                }
                guard let role = try await currentUser.getIDTokenResult().claims["role"] as? String else {
                    Logger.debug("🔥 Firebase user loggedin: Logged in user, but no custom roles found")
                    return nil
                }
                
                if role == "Manager" {
                    Logger.debug("🔥 Firebase user loggedin: Manager role found")
                    return Role.manager
                } else if role == "Participant" {
                    Logger.debug("🔥 Firebase user loggedin: Participant role found")
                    return Role.participant
                }
                Logger.log(.error, "Role is unknown: \(role)")
                struct UnkownRoleError: Error {}
                throw UnkownRoleError()
                
            },
            googleLogin: {
                let credential = try await FirebaseService().startGoogleSignInFlow()
                try await credential.linkOrSignInWithCredential()
            },
            appleLogin: {
                let credential = try await FirebaseService().startSignInWithAppleFlow()
                try await credential.linkOrSignInWithCredential()
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
        )
    }
}

extension AuthCredential {
    func linkOrSignInWithCredential () async throws {
        guard let currentUser = Auth.auth().currentUser else {
            _ = try await Auth.auth().signIn(with: self)
            return
        }
        do {
            if currentUser.isAnonymous {
                try await currentUser.link(with: self)
            } else {
                try Auth.auth().signOut()
                _ = try await Auth.auth().signIn(with: self)
            }
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.credentialAlreadyInUse.rawValue:
                _ = try await Auth.auth().signIn(with: self)
            default:
                throw error
            }
        }
    }
}
