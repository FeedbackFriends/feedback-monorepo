import Foundation

public struct SuggestionOutcome: Equatable, Sendable, Identifiable {
    public enum Outcome: String, Equatable, Sendable { case continued = "Continue", adjust = "Adjust", stop = "Stop" }
    public let id: String
    public let trialID: String
    public let outcome: Outcome
    public let explanation: String
    public let publishedAt: Date

    public init(id: String, trialID: String, outcome: Outcome, explanation: String, publishedAt: Date) {
        self.id = id
        self.trialID = trialID
        self.outcome = outcome
        self.explanation = explanation
        self.publishedAt = publishedAt
    }
}
