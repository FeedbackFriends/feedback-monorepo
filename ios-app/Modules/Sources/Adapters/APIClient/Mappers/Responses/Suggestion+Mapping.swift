import Domain
import OpenAPI

extension Suggestion {
    init(_ dto: Components.Schemas.Suggestion) {
        self.init(
            id: dto.id, problem: dto.problem, impact: dto.impact, solution: dto.solution,
            supportCount: Int(dto.supportCount), supportedByMe: dto.supportedByMe, mine: dto.mine
        )
    }
}
