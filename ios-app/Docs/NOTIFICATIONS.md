# Notifications

The app uses Firebase Cloud Messaging (FCM) for push notifications.

## Setup

1. Ensure `GoogleService-Info.plist` is present under `Xcode_project/`.
2. Push entitlement is enabled in `Xcode_project/App/Entitlements.entitlements`.
3. The app registers for push in `AppDelegate` and links the FCM token to the backend when available.

## Local testing

Use the provided sample payloads in `Docs/push_notifications/` to test on a booted simulator or device:

```bash
xcrun simctl push booted <your.bundle.id> Docs/push_notifications/new_feedback_received.apns
```

## Code references

- Entitlements: `Xcode_project/App/Entitlements.entitlements`
- App delegate registration and token handling: `Xcode_project/App/AppDelegate.swift`


