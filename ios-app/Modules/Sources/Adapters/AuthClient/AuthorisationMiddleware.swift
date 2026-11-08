import OpenAPIRuntime
import Foundation
import OpenAPIURLSession
import Network
import HTTPTypes
import Logger
import Auth

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
        let idToken = try await SupabaseSession.client().session.accessToken
        var mutableRequest = request
        mutableRequest.headerFields[.authorization] = "Bearer \(idToken)"
        let response = try await next(mutableRequest, body, baseURL)
        return response
    }
}
