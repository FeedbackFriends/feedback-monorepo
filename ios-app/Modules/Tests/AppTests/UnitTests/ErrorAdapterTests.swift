@testable import Adapters
import AuthenticationServices
import Domain
import FirebaseAuth
import Foundation
import GoogleSignIn
import HTTPTypes
import OpenAPIRuntime
import Testing

struct ErrorAdapterTests {
    @Test func wrappedTransportErrorsKeepNetworkClassification() {
        let wrapped = ClientError(
            operationID: "test", operationInput: "", causeDescription: "English diagnostic",
            underlyingError: URLError(.notConnectedToInternet)
        )
        #expect(normalizedAPIError(wrapped).localized.title == "Ingen internetforbindelse")
    }

    @Test func authenticationSDKCodesAreMappedAtTheBoundary() {
        let expired = NSError(domain: AuthErrors.domain, code: AuthErrorCode.userTokenExpired.rawValue)
        #expect(normalizedAuthError(expired) as? AuthenticationError == .notSignedIn)
        let network = NSError(
            domain: AuthErrors.domain, code: AuthErrorCode.networkError.rawValue,
            userInfo: [NSUnderlyingErrorKey: URLError(.timedOut)]
        )
        #expect((normalizedAuthError(network) as? URLError)?.code == .timedOut)
        let throttled = NSError(domain: AuthErrors.domain, code: AuthErrorCode.tooManyRequests.rawValue)
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
