import Domain
import Foundation
import OpenAPI

public extension Components.Schemas.SendNotificationInput {
    init(_ input: SendNotificationInput) {
        self.init(
            fcmToken: input.fcmToken,
            title: input.title,
            newFeedback: Int32(input.newFeedback),
            eventId: input.eventId.uuidString
        )
    }
}
