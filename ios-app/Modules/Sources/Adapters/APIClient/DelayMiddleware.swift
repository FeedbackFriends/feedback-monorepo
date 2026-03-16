import OpenAPIRuntime
import HTTPTypes
import Foundation

public struct DelayMiddleware: ClientMiddleware {
    public init() {}
    public func intercept(
        _ request: HTTPTypes.HTTPRequest,
        body: OpenAPIRuntime.HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPTypes.HTTPRequest, OpenAPIRuntime.HTTPBody?, URL)
        async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)
    ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        try await Task.sleep(for: .seconds(0.5))
        let response = try await next(request, body, baseURL)
        return response
    }
}
