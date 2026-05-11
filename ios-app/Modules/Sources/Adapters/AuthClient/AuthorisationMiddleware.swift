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
        guard let currentUser = Auth.auth().currentUser else {
            Logger.log(.error, "Session has expired for good, should only happen if user is deleted or disabled")
            throw URLError(URLError.Code.userAuthenticationRequired)
        }
        let idToken = try await currentUser.getIDToken()
        var mutableRequest = request
        mutableRequest.headerFields[.authorization] = "Bearer \(idToken)"
        let response = try await next(mutableRequest, body, baseURL)
        if request.forceRefreshAfter {
            _ = try await currentUser.getIDToken(forcingRefresh: true)
        }
        return response
    }
}
