import Domain
import Foundation
import OpenAPI

extension APIClient {
    static func makeSubmitProductContact(api: APIProtocol) -> @Sendable (ProductContactInput) async throws -> ProductContactReceipt {
        { input in
            try await withAuthorization {
                let response = try await api.submitSupportSubmission(.init(body: .json(.init(input)))).ok.body.json
                guard UUID(uuidString: response.id) == input.id else {
                    throw AppFailure.supportReceiptUnavailable
                }
                return ProductContactReceipt(id: input.id, receivedAt: response.receivedAt)
            }
        }
    }
}

extension Components.Schemas.SupportSubmissionInput {
    init(_ input: ProductContactInput) {
        let rating: RatingPayload? = input.rating.map { rating in
            switch rating {
            case .verySad: .verySad
            case .sad: .sad
            case .happy: .happy
            case .veryHappy: .veryHappy
            }
        }
        self.init(
            id: input.id.uuidString,
            kind: input.kind == .productFeedback ? .productFeedback : .bugReport,
            rating: rating,
            message: input.message,
            expectedBehavior: input.expectedBehavior,
            contactEmail: input.contactEmail,
            metadata: .init(
                appVersion: input.metadata.appVersion,
                appBuild: input.metadata.appBuild,
                osVersion: input.metadata.osVersion
            )
        )
    }
}
