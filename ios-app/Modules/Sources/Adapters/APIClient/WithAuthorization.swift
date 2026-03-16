import HTTPTypes

/// Executes an authorized API call.
///
/// - Parameters:
///   - forceRefresh: A flag indicating whether the ID token should be refreshed after the call.
///   - task: The task to execute that requires authorization.
/// - Returns: The result of the executed task.
/// - Throws: Rethrows any errors encountered during the execution of the task.
func withAuthorization<T>(
    forceRefreshAfter: Bool = false,
    _ task: @escaping () async throws -> T
) async throws -> T {
    try await Request.$needsAuthorization.withValue(true) {
        try await Request.$forceRefreshAfter.withValue(forceRefreshAfter) {
            try await task()
        }
    }
}

enum Request {
    /// Indicates whether the request requires authorization
    @TaskLocal static var needsAuthorization: Bool = false
    
    /// Indicates whether the ID token should be refreshed after an API call
    @TaskLocal static var forceRefreshAfter: Bool = false
}

extension HTTPTypes.HTTPRequest {
    
    public var needsAuthorization: Bool {
        Request.needsAuthorization
    }
    
    public var forceRefreshAfter: Bool {
        Request.forceRefreshAfter
    }
}
