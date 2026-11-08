@testable import Adapters
import AuthenticationServices
import Domain
import Auth
import Foundation
import GoogleSignIn
import HTTPTypes
import OpenAPIRuntime
import Testing

struct ErrorAdapterTests {
    @Test(arguments: ["PINCODE_NOT_FOUND", "FUTURE_CODE"])
    func backendCopySurvivesKnownAndUnknownCodes(_ code: String) async throws {
        let payload = """
        {"message":"sensitive diagnostic","domainCode":"\(code)","userTitle":"Server title","userMessage":"Server message"}
        """
        do {
            _ = try await APIErrorMiddleware().intercept(
                HTTPRequest(method: .get, scheme: "https", authority: "example.com", path: "/"),
                body: nil, baseURL: URL(string: "https://example.com")!, operationID: "test"
            ) { _, _, _ in
                (HTTPResponse(status: .notFound), HTTPBody(payload))
            }
            Issue.record("Expected API failure")
        } catch {
            #expect((error as? ApiError)?.rawDomainCode == code)
            #expect(error.localized == PresentableError(title: "Server title", message: "Server message"))
        }
    }

    @Test
    func middlewareSendsSelectedAppLanguage() async throws {
        _ = try await APIErrorMiddleware(language: { "en-GB" }).intercept(
            HTTPRequest(method: .get, scheme: "https", authority: "example.com", path: "/"),
            body: nil, baseURL: URL(string: "https://example.com")!, operationID: "test"
        ) { request, _, _ in
            #expect(request.headerFields[.acceptLanguage] == "en-GB")
            return (HTTPResponse(status: .ok), nil)
        }
    }

    @Test
    func cancellationRemainsCancellation() async {
        do {
            _ = try await APIErrorMiddleware().intercept(
                HTTPRequest(method: .get, scheme: "https", authority: "example.com", path: "/"),
                body: nil, baseURL: URL(string: "https://example.com")!, operationID: "test"
            ) { _, _, _ in throw CancellationError() }
            Issue.record("Expected cancellation")
        } catch {
            #expect(error is CancellationError)
        }
    }

    @Test func wrappedTransportErrorsKeepNetworkClassification() {
        let wrapped = ClientError(
            operationID: "test", operationInput: "", causeDescription: "English diagnostic",
            underlyingError: URLError(.notConnectedToInternet)
        )
        #expect(normalizedAPIError(wrapped).localized.title == "Ingen internetforbindelse")
    }

    @Test func authenticationSDKCodesAreMappedAtTheBoundary() {
        let expired = AuthError.sessionMissing
        #expect(normalizedAuthError(expired) as? AuthenticationError == .notSignedIn)
        let network = URLError(.timedOut)
        #expect((normalizedAuthError(network) as? URLError)?.code == .timedOut)
        let throttled = AuthError.api(message: "rate limit", errorCode: .overRequestRateLimit,
            underlyingData: Data(), underlyingResponse: HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 429, httpVersion: nil, headerFields: nil)!)
        #expect(normalizedAuthError(throttled) as? AppFailure == .rateLimited)
        let apple = NSError(domain: ASAuthorizationErrorDomain, code: ASAuthorizationError.canceled.rawValue)
        let google = NSError(domain: GIDSignInError.errorDomain, code: GIDSignInError.canceled.rawValue)
        #expect(normalizedAuthError(apple) as? AuthenticationError == .loginCancelled)
        #expect(normalizedAuthError(google) as? AuthenticationError == .loginCancelled)
        #expect(normalizedAuthError(CancellationError()) is CancellationError)
    }

    @Test func middlewareRetainsDomainCodeWithHTTPStatus() async throws {
        let body = HTTPBody("""
        {"message":"English diagnostic","domainCode":"PINCODE_NOT_FOUND"}
        """)
        do {
            _ = try await APIErrorMiddleware().intercept(
                HTTPRequest(method: .get, scheme: "https", authority: "example.com", path: "/"),
                body: nil, baseURL: URL(string: "https://example.com")!, operationID: "test"
            ) { _, _, _ in
                (HTTPResponse(status: .notFound), body)
            }
            Issue.record("Expected API error")
        } catch {
            #expect(error.localized.title == "Ugyldig PIN-kode")
        }
    }

    @Test(arguments: ["<html>English gateway error</html>", "{\"domainCode\":\"futureCode\"}"])
    func malformedOrUnknownResponsesUseSafeStatusMessage(_ payload: String) async throws {
        do {
            _ = try await APIErrorMiddleware().intercept(
                HTTPRequest(method: .get, scheme: "https", authority: "example.com", path: "/"),
                body: nil, baseURL: URL(string: "https://example.com")!, operationID: "test"
            ) { _, _, _ in
                (HTTPResponse(status: .serviceUnavailable), HTTPBody(payload))
            }
            Issue.record("Expected HTTP error")
        } catch {
            #expect(error.localized.message == "Der opstod en serverfejl. Prøv igen om lidt.")
        }
    }

    @Test func successfulResponsesAreUnchanged() async throws {
        let response = try await APIErrorMiddleware().intercept(
            HTTPRequest(method: .get, scheme: "https", authority: "example.com", path: "/"),
            body: nil, baseURL: URL(string: "https://example.com")!, operationID: "test"
        ) { _, _, _ in
            (HTTPResponse(status: .ok), HTTPBody("unchanged"))
        }
        #expect(response.0.status == .ok)
        let data = try await Data(collecting: #require(response.1), upTo: 100)
        #expect(String(decoding: data, as: UTF8.self) == "unchanged")
    }
}
