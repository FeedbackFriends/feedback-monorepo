import Foundation
import Logger

public enum Deeplink: Equatable, Sendable {
    case joinEvent(pinCodeInput: PinCodeInput)
    case managerEvent(id: UUID)
}

public extension Deeplink {
    init?(url: URL) {
        guard
            url.scheme == "letsgrow",
            let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { return nil }

        switch (comps.host, comps.queryItems) {
        case ("invite", let items?):
            if let pinCodeInput = items.first(where: { $0.name == "pin_code" })?.value {
                self = .joinEvent(pinCodeInput: .init(value: pinCodeInput))
                return
            }
            return nil
        default:
            return nil
        }
    }

    init?(notificationUserInfo userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String else {
            Logger.log(.error, "Failed to parse type from notification payload")
            return nil
        }

        switch type {
        case "FEEDBACK_RECEIVED":
            guard
                let eventIdString = userInfo["eventId"] as? String,
                let eventId = UUID(uuidString: eventIdString)
            else {
                Logger.log(.error, "Failed to parse eventId from notification payload")
                return nil
            }
            self = .managerEvent(id: eventId)
        default:
            Logger.log(.error, "Unexpected notification type \(type)")
            return nil
        }
    }
}
