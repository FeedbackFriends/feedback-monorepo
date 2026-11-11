import Domain
import OpenAPI

extension Suggestion {
    init(_ dto: Components.Schemas.Suggestion) throws {
        self.init(
            id: dto.id, problem: dto.problem, impact: dto.impact, solution: dto.solution,
            hasFiveSupporters: dto.hasFiveSupporters, supportedByMe: dto.supportedByMe, mine: dto.mine,
            decisions: try dto.decisions.map(SuggestionDecision.init),
            trials: try dto.trials.map(SuggestionTrial.init),
            evaluations: dto.evaluations.map(SuggestionEvaluation.init),
            outcomes: dto.outcomes.map(SuggestionOutcome.init)
        )
    }
}
