import Domain
import Foundation
import HTTPTypes
import Localization
import OpenAPIRuntime
import Logger

/// Negotiates error language and preserves safe copy, status and codes before generated accessors discard them.
public struct APIErrorMiddleware: ClientMiddleware {
    private let language: @Sendable () -> String

    public init(language: @escaping @Sendable () -> String = { L10n.locale.identifier }) {
        self.language = language
    }

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        request.headerFields[.acceptLanguage] = language()
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
            if let payload = try? JSONDecoder().decode(APIErrorEnvelope.self, from: data) {
                Logger.debug("API failure message: \(payload.message ?? "")")
                throw ApiError(
                    timestamp: payload.timestamp,
                    message: payload.message,
                    domainCode: payload.domainCode.flatMap(DomainCode.init(rawValue:)),
                    exceptionType: payload.exceptionType,
                    path: payload.path,
                    statusCode: status,
                    rawDomainCode: payload.domainCode,
                    userTitle: payload.userTitle,
                    userMessage: payload.userMessage
                )
            }
        }
        // Malformed responses and HTML error pages never become UI copy.
        throw AppFailure.http(statusCode: status)
    }
}

/// Error responses must remain readable when a server introduces a code unknown to this client.
private struct APIErrorEnvelope: Decodable {
    let timestamp: String?
    let message: String?
    let domainCode: String?
    let exceptionType: String?
    let path: String?
    let userTitle: String?
    let userMessage: String?
}

/// The generated client wraps transport and middleware failures. Keep SDK types in Adapters.
func normalizedAPIError(_ error: any Error) -> any Error {
    guard let clientError = error as? ClientError else { return normalizedAuthError(error) }
    return normalizedAPIError(clientError.underlyingError)
}
