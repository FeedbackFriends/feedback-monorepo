import Foundation

/// App-facing failure categories; technical descriptions stay in diagnostics.
public enum AppFailure: Error, Sendable, Equatable {
    case http(statusCode: Int)
    case cacheUpdate
    case inviteUnavailable
    case sessionUnavailable
    case authenticationFailed
    case rateLimited
}

/// Lets adapters classify a local failure without exposing SDK types to Domain.
public protocol AppFailureProviding: Error {
    var appFailure: AppFailure { get }
}
