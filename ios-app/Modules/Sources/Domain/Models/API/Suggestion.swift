import Foundation

public struct Suggestion: Equatable, Sendable, Identifiable {
    public let id: String
    public let problem: String
    public let impact: String
    public let solution: String?
    public let supportCount: Int
    public let supportedByMe: Bool
    public let mine: Bool

    public init(id: String, problem: String, impact: String, solution: String?, supportCount: Int, supportedByMe: Bool, mine: Bool) {
        self.id = id
        self.problem = problem
        self.impact = impact
        self.solution = solution
        self.supportCount = supportCount
        self.supportedByMe = supportedByMe
        self.mine = mine
    }
}
