import Foundation

public struct SendNotificationInput: Equatable, Sendable {
    public var fcmToken: String
    public var title: String
    public var newFeedback: Int
    public var eventId: UUID

    public init(
        fcmToken: String,
        title: String,
        newFeedback: Int,
        eventId: UUID
    ) {
        self.fcmToken = fcmToken
        self.title = title
        self.newFeedback = newFeedback
        self.eventId = eventId
    }
}
