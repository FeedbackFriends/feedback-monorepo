import Foundation
import ComposableArchitecture

@DependencyClient
public struct AuthClient: Sendable {
    public var fetchCustomRole: @Sendable () async throws -> Role?
    public var googleLogin: @Sendable () async throws -> Void
    public var appleLogin: @Sendable () async throws -> Void
    public var logout: @Sendable () async throws -> Void
    public var userStateChanged: @Sendable () async -> AsyncStream<UserState> = { .never }
    public var signInWithCustomToken: @Sendable (String) async throws -> Void
}

public enum UserState: Sendable {
    case authenticated, loggedOut
}

public enum AuthenticationError: Error {
    case notSignedIn, couldNotFindWindow, couldNotFindClientID, loginCancelled, identityTokenMissing, tokenSerializationFailed
}
