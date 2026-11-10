import Foundation

public struct Suggestion: Equatable, Sendable, Identifiable {
    public let id: String
    public let problem: String
    public let impact: String
    public let solution: String?
    public let hasFiveSupporters: Bool
    public let supportedByMe: Bool
    public let mine: Bool
    public let decisions: [SuggestionDecision]

    public init(id: String, problem: String, impact: String, solution: String?, hasFiveSupporters: Bool, supportedByMe: Bool, mine: Bool, decisions: [SuggestionDecision] = []) {
        self.id = id
        self.problem = problem
        self.impact = impact
        self.solution = solution
        self.hasFiveSupporters = hasFiveSupporters
        self.supportedByMe = supportedByMe
        self.mine = mine
        self.decisions = decisions
    }
}
