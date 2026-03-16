import Foundation

public struct Activity: Equatable, Sendable {
    public var items: [ActivityItems]
    public var unseenTotal: Int
    public init(items: [ActivityItems], unseenTotal: Int) {
        self.items = items
        self.unseenTotal = unseenTotal
    }
}

public struct ActivityItems: Equatable, Sendable, Identifiable {
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
