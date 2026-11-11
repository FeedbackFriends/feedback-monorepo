import Foundation

public struct SuggestionTrial: Equatable, Sendable, Identifiable {
    public let id: String
    public let revision: Int
    public let decisionId: String
    public let change: String
    public let intendedBenefit: String
    public let responsibleName: String
    public let needsReassignment: Bool
    /// Calendar dates at midnight UTC; format in UTC to preserve the day.
    public let startDate: Date
    public let endDate: Date
    public let followUpDate: Date
    public let publishedAt: Date

    public init(id: String, revision: Int, decisionId: String, change: String, intendedBenefit: String,
                responsibleName: String, needsReassignment: Bool, startDate: Date, endDate: Date,
                followUpDate: Date, publishedAt: Date) {
        self.id = id
        self.revision = revision
        self.decisionId = decisionId
        self.change = change
        self.intendedBenefit = intendedBenefit
        self.responsibleName = responsibleName
        self.needsReassignment = needsReassignment
        self.startDate = startDate
        self.endDate = endDate
        self.followUpDate = followUpDate
        self.publishedAt = publishedAt
    }
}
