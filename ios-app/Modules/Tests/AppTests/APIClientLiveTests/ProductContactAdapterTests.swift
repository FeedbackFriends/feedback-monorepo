@testable import Adapters
import ComposableArchitecture
import Domain
import Foundation
import OpenAPI
import Testing

struct ProductContactAdapterTests {
    @Test
    func serializesOnlyAllowedMetadataAndDoesNotChangeMeetingCacheOnRetries() async throws {
        let id = UUID()
        let date = Date(timeIntervalSince1970: 0)
        let input = ProductContactInput(
            id: id, kind: .productFeedback, rating: .happy, message: "Comment",
            expectedBehavior: nil, contactEmail: nil,
            metadata: .init(appVersion: "1.2", appBuild: "42", osVersion: "27.2")
        )
        let calls = LockIsolated(0)
        var api = MockAPI()
        api.submitSupportSubmissionHandler = { request in
            #expect(Request.needsAuthorization)
            let body: Components.Schemas.SupportSubmissionInput
            switch request.body {
            case .json(let payload): body = payload
            }
            #expect(body.id == id.uuidString)
            #expect(body.kind == .productFeedback)
            #expect(body.rating == .happy)
            let json = try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(body)) as? [String: Any])
            let metadata = try #require(json["metadata"] as? [String: String])
            #expect(Set(metadata.keys) == Set(["appVersion", "appBuild", "osVersion"]))
            #expect(json["pinCode"] == nil)
            #expect(json["eventId"] == nil)
            calls.withValue { $0 += 1 }
            return .ok(.init(body: .json(.init(id: id.uuidString, receivedAt: date))))
        }
        let before = Bootstrap.mock()
        let cache = APIClientCache(bootstrap: before)
        let client = APIClient.live(client: api, provideFcmToken: { nil }, sessionCache: cache)
        #expect(try await client.submitProductContact(input) == .init(id: id, receivedAt: date))
        #expect(try await client.submitProductContact(input) == .init(id: id, receivedAt: date))
        #expect(calls.value == 2)
        #expect(await cache.getBootstrap() == before)
    }

    @Test
    func mismatchedReceiptNeverBecomesAConfirmedSubmission() async {
        let input = ProductContactInput(
            id: UUID(), kind: .bugReport, rating: nil, message: "Description",
            expectedBehavior: nil, contactEmail: nil,
            metadata: .init(appVersion: "1", appBuild: "1", osVersion: "27")
        )
        var api = MockAPI()
        api.submitSupportSubmissionHandler = { _ in
            .ok(.init(body: .json(.init(id: UUID().uuidString, receivedAt: .now))))
        }
        let client = APIClient.live(client: api, provideFcmToken: { nil })
        do {
            _ = try await client.submitProductContact(input)
            Issue.record("Expected receipt validation failure")
        } catch {
            #expect(error as? AppFailure == .supportReceiptUnavailable)
        }
    }
}
