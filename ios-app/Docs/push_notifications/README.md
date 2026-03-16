# Push notification samples

Use these `.apns` payloads to exercise the app’s push handling during development.

## Send to a booted simulator

```bash
xcrun simctl push booted <your.bundle.id> Docs/push_notifications/new_feedback_received.apns
```

Replace `<your.bundle.id>` with the actual bundle identifier.


