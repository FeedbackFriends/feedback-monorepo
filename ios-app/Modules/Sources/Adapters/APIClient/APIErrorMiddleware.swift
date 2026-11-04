import Domain
import Foundation
import HTTPTypes
import OpenAPI
import OpenAPIRuntime
import Logger

/// Preserves HTTP status and known domain codes before generated success accessors discard them.
public struct APIErrorMiddleware: ClientMiddleware {
    public init() {}

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let (response, responseBody) = try await next(request, body, baseURL)
        let status = response.status.code
        guard status >= 400 else { return (response, responseBody) }
        Logger.debug("API failure: operation=\(operationID), status=\(status)")
        if let responseBody {
            let data: Data
            do {
                data = try await Data(collecting: responseBody, upTo: 1_048_576)
            } catch let error as CancellationError {
                throw error
            } catch let error as URLError where error.code == .cancelled {
                throw error
            } catch {
                throw AppFailure.http(statusCode: status)
            }
            if let payload = try? JSONDecoder().decode(Components.Schemas.ApiError.self, from: data) {
                Logger.debug("API failure message: \(payload.message ?? "")")
                throw ApiError(payload, statusCode: status)
            }
        }
        // Unknown domain codes, malformed responses and HTML error pages never become UI copy.
        throw AppFailure.http(statusCode: status)
    }
}

/// The generated client wraps transport and middleware failures. Keep SDK types in Adapters.
func normalizedAPIError(_ error: any Error) -> any Error {
    guard let clientError = error as? ClientError else { return normalizedAuthError(error) }
    return normalizedAPIError(clientError.underlyingError)
}
