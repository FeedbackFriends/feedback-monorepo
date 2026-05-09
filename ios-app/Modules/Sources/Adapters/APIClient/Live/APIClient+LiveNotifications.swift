import Domain
import OpenAPI

extension APIClient {
    static func makeSendNotification(api: APIProtocol) -> @Sendable (SendNotificationInput) async throws -> Void {
        { input in
            try await withAuthorization {
                _ = try await api.sendNotification(body: .json(.init(input))).ok
                return ()
            }
        }
    }
}
