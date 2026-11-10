import Foundation

public struct SuggestionDecision: Equatable, Sendable, Identifiable {
    public enum Status: String, Equatable, Sendable {
        case reviewing, planned, deferred, declined
    }

    public let id: String
    public let revision: Int
    public let status: Status
    public let explanation: String
    public let responsibleName: String
    /// A calendar date represented at midnight UTC; format in UTC to preserve the day.
    public let followUpDate: Date?
    public let publishedAt: Date

    public init(id: String, revision: Int, status: Status, explanation: String, responsibleName: String,
                followUpDate: Date?, publishedAt: Date) {
        self.id = id
        self.revision = revision
        self.status = status
        self.explanation = explanation
        self.responsibleName = responsibleName
        self.followUpDate = followUpDate
        self.publishedAt = publishedAt
    }
}
