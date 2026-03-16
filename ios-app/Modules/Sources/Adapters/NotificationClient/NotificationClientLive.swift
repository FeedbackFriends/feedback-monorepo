import UserNotifications
import Domain

extension NotificationClient {
    public static let live = Self(
        shouldPromptForAuthorization: { role in
            if role == nil {
                return false
            }
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            switch settings.authorizationStatus {
            case .notDetermined:
                return true
            default:
                return false
            }
        },
        requestAuthorization: {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [
                .alert,
                .badge,
                .sound
            ])
        },
        scheduleLocalNotification: { title, body, userInfo, presentAfterDelayInSeconds, id in
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.userInfo = userInfo
            content.badge = 1
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: TimeInterval(presentAfterDelayInSeconds), repeats: false
            )
            UNUserNotificationCenter.current().add(
                .init(
                    identifier: id,
                    content: content,
                    trigger: trigger
                )
            )
        },
        removeLocalPendingNotificationRequests: { ids in
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        }
    )
}
