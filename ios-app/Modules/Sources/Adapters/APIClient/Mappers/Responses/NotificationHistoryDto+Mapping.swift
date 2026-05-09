import Foundation
import Domain
import OpenAPI

public extension NotificationHistoryItem {
    init(_ dto: Components.Schemas.NotificationHistoryItem) {
        self.init(
            id: UUID(uuidString: dto.id)!,
            date: dto.date,
            eventTitle: dto.eventTitle,
            eventId: UUID(uuidString: dto.eventId)!,
            newFeedbackCount: Int(dto.newFeedbackCount),
            seenByManager: dto.seenByManager
        )
    }
}

public extension NotificationHistory {
    init(_ dto: Components.Schemas.NotificationHistoryDto) {
        self.init(
            items: dto.items.map(NotificationHistoryItem.init),
            unseenTotal: Int(dto.unseenTotal)
        )
    }
}
