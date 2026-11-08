# Notifications

The app uses Firebase Cloud Messaging. [AppDelegate](../../ios-app/App/AppDelegate.swift) handles registration/token callbacks; [entitlements](../../ios-app/App/Entitlements.entitlements) enable push. Firebase configuration comes from Info.plist and local `App/Config/secrets.xcconfig`; see [configuration](CONFIGURATION.md).

The [localization guide](localization.md#notification-and-system-string-packaging) owns APNs keys, string arguments, and linked main-app resources. Preserve that contract when changing payloads.

Use [lg-ios-test-notifications](../../.agents/skills/lg-ios-test-notifications/SKILL.md) for notification verification. The [backend-dependent runner](../../ios-app/.maestro/notifications/README.md) documents setup, data cleanup, and delivery limits. Simulator injection verifies presentation/navigation, not production FCM/APNs transport or device provisioning. A [sample payload](push_notifications/new_feedback_received.apns) remains available for manual inspection; local agent simulator operations follow [native Xcode policy](agents/simulator.md).
