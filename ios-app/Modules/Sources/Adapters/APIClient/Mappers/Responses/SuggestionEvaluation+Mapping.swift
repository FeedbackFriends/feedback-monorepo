import Domain
import Foundation
import OpenAPI

extension SuggestionEvaluation {
    init(_ dto: Components.Schemas.SuggestionEvaluation) {
        self.init(id: dto.id, trialID: dto.trialId,
                  closesAt: Date(timeIntervalSince1970: Double(dto.closesAt) / 1000),
                  closed: dto.closed, eligible: dto.eligible,
                  myAnswer: dto.myAnswer.map { EvaluationAnswer(rawValue: $0.rawValue)! },
                  summary: dto.summary.map { Summary(rawValue: $0.rawValue)! })
    }
}
