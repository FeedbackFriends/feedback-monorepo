import Auth
import Domain
import Foundation

/// Shared SDK client owns Keychain persistence and serialized refresh for API and UI callers.
public enum SupabaseSession {
    private static let configured: Result<Auth.AuthClient, Error> = Result {
        guard let rawURL = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let url = URL(string: rawURL), url.scheme == "https", url.host != nil,
              let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_PUBLISHABLE_KEY") as? String,
              !key.isEmpty, !key.hasPrefix("$(") else {
            throw AppFailure.authenticationFailed
        }
        return Auth.AuthClient(
            url: url.appending(path: "auth/v1"), headers: ["apikey": key],
            storageKey: "letsgrow.supabase.\(url.host() ?? "")",
            localStorage: KeychainLocalStorage(), autoRefreshToken: true
        )
    }

    public static func client() throws -> Auth.AuthClient { try configured.get() }

    /// Debug fixtures supply a Supabase access/refresh pair as JSON, never a Firebase custom token.
    public static func restoreTestSession(_ token: String) async throws {
        #if DEBUG
        struct Tokens: Decodable { let accessToken: String; let refreshToken: String }
        let tokens = try JSONDecoder().decode(Tokens.self, from: Data(token.utf8))
        _ = try await client().setSession(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)
        #else
        throw AuthenticationError.notSignedIn
        #endif
    }
}
