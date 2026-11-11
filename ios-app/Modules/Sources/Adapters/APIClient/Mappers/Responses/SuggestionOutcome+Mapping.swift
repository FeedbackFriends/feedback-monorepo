import Domain
import Foundation
import OpenAPI

extension SuggestionOutcome {
    init(_ dto: Components.Schemas.SuggestionOutcome) {
        self.init(id: dto.id, trialID: dto.trialId, outcome: Outcome(rawValue: dto.outcome.rawValue)!,
                  explanation: dto.explanation, publishedAt: Date(timeIntervalSince1970: Double(dto.publishedAt) / 1000))
    }
}
