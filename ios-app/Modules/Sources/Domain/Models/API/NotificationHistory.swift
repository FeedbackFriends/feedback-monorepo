import Foundation

public struct NotificationHistory: Equatable, Sendable {
    public var items: [NotificationHistoryItem]
    public var unseenTotal: Int
    public init(items: [NotificationHistoryItem], unseenTotal: Int) {
        self.items = items
        self.unseenTotal = unseenTotal
    }
}

public struct NotificationHistoryItem: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let date: Date
    public let eventTitle: String
    public let eventId: UUID
    public let newFeedbackCount: Int
    public var seenByManager: Bool
    public init(
        id: UUID,
        date: Date,
        eventTitle: String,
        eventId: UUID,
        newFeedbackCount: Int,
        seenByManager: Bool
    ) {
        self.id = id
        self.date = date
        self.eventTitle = eventTitle
        self.eventId = eventId
        self.newFeedbackCount = newFeedbackCount
        self.seenByManager = seenByManager
    }
}
