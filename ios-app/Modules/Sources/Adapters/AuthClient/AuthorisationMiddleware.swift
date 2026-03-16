import OpenAPIRuntime
import Foundation
import OpenAPIURLSession
import Network
import HTTPTypes
import Logger
import FirebaseAuth

public struct AuthorisationMiddleware: ClientMiddleware {
    public init() {}
    public func intercept(
        _ request: HTTPTypes.HTTPRequest,
        body: OpenAPIRuntime.HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPTypes.HTTPRequest, OpenAPIRuntime.HTTPBody?, URL)
        async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)
    ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        guard request.needsAuthorization else {
            return try await next(request, body, baseURL)
        }
        guard let idToken = try await Auth.auth().currentUser?.getIDToken() else {
            Logger.log(.error, "Session has expired for good, should only happen if user is deleted or disabled")
            throw URLError(URLError.Code.userAuthenticationRequired)
        }
        var mutableRequest = request
        mutableRequest.headerFields[.authorization] = "Bearer \(idToken)"
        let response = try await next(mutableRequest, body, baseURL)
        if request.forceRefreshAfter {
            _ = try await Auth.auth().currentUser?.getIDToken(forcingRefresh: true)
        }
        return response
    }
}
