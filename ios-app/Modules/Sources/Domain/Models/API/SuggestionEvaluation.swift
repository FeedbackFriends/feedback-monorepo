import Foundation

public enum EvaluationAnswer: String, Equatable, Sendable, CaseIterable, Identifiable {
    case better = "Better", unchanged = "Unchanged", worse = "Worse", cannotAssess = "CannotAssess"
    public var id: Self { self }
}
public struct SuggestionEvaluation: Equatable, Sendable, Identifiable {
    public enum Summary: String, Equatable, Sendable {
        case improved = "Improved", mixed = "Mixed", notImproved = "NotImproved", insufficientResponses = "InsufficientResponses"
    }
    public let id: String
    public let trialID: String
    public let closesAt: Date
    public let closed: Bool
    public let eligible: Bool
    public let myAnswer: EvaluationAnswer?
    public let summary: Summary?

    public init(id: String, trialID: String, closesAt: Date, closed: Bool, eligible: Bool, myAnswer: EvaluationAnswer?, summary: Summary?) {
        self.id = id
        self.trialID = trialID
        self.closesAt = closesAt
        self.closed = closed
        self.eligible = eligible
        self.myAnswer = myAnswer
        self.summary = summary
    }
}
