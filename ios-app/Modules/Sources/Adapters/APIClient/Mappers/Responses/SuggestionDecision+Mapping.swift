import Domain
import Foundation
import OpenAPI

extension SuggestionDecision {
    init(_ dto: Components.Schemas.SuggestionDecision) throws {
        let status: Status = switch dto.status {
        case .reviewing: .reviewing
        case .planned: .planned
        case .deferred: .deferred
        case .declined: .declined
        }
        self.init(
            id: dto.id, revision: Int(dto.revision), status: status, explanation: dto.explanation,
            responsibleName: dto.responsibleName,
            followUpDate: try dto.followUpDate.map { try Date($0 + "T00:00:00Z", strategy: .iso8601) },
            publishedAt: Date(timeIntervalSince1970: Double(dto.publishedAt) / 1000)
        )
    }
}
