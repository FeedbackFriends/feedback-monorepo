# Push notification samples

Use these `.apns` payloads to exercise the app’s push handling during development. The command below is for manual testing from the monorepo root; agent simulator work follows [the iOS harness policy](../../AGENTS.md).

## Send to a booted simulator

```bash
xcrun simctl push booted <your.bundle.id> ios-app/Docs/push_notifications/new_feedback_received.apns
```

Replace `<your.bundle.id>` with the actual bundle identifier.


