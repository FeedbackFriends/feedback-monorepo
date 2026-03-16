import OpenAPIRuntime
import HTTPTypes
import Foundation

public struct DeviceIdHeaderMiddleware: ClientMiddleware {
    let deviceId: String
    public init(deviceId: String) {
        self.deviceId = deviceId
    }
    public func intercept(
        _ request: HTTPTypes.HTTPRequest,
        body: OpenAPIRuntime.HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPTypes.HTTPRequest, OpenAPIRuntime.HTTPBody?, URL)
        async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)
    ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        var modifiedRequest = request
        modifiedRequest.headerFields.append(HTTPField(name: .deviceId, value: deviceId))
        let response = try await next(modifiedRequest, body, baseURL)
        return response
    }
}
extension HTTPField.Name {
    static let deviceId = Self("X-Device-ID")!
}
