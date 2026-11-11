import Domain
import Foundation
import OpenAPI

extension SuggestionTrial {
    init(_ dto: Components.Schemas.SuggestionTrial) throws {
        self.init(
            id: dto.id, revision: Int(dto.revision), decisionId: dto.decisionId,
            change: dto.change, intendedBenefit: dto.intendedBenefit, responsibleName: dto.responsibleName,
            needsReassignment: dto.needsReassignment,
            startDate: try Date(dto.startDate + "T00:00:00Z", strategy: .iso8601),
            endDate: try Date(dto.endDate + "T00:00:00Z", strategy: .iso8601),
            followUpDate: try Date(dto.followUpDate + "T00:00:00Z", strategy: .iso8601),
            publishedAt: Date(timeIntervalSince1970: Double(dto.publishedAt) / 1000)
        )
    }
}
