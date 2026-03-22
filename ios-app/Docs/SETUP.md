# Setup & Running

This guide walks you through installing dependencies, selecting schemes, and running/testing the app.

## Requirements

- Swift 6.2
- Xcode 26
- iOS 26
- Optional: SwiftLint (`brew install swiftlint`)

## Clone and open

```bash
git clone https://github.com/FeedbackFriends/feedback-ios.git
open Xcode_project/Feedback.xcodeproj
```

## Schemes

- Feedback Debug — default dev environment
- Feedback Localhost — targets a locally running backend
- Feedback Mock — uses mock adapters instead of live services
- Feedback Prod — production configuration

Switch schemes in the Xcode toolbar.

## Running

1. Select a simulator or a connected device.
2. Choose the scheme.
3. Build & Run.

## Testing

Run tests from Xcode or via command line:

```bash
xcodebuild \
  -project Xcode_project/Feedback.xcodeproj \
  -scheme "Feedback Debug" \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  test
```

## Notes

- OpenAPI client code is committed under `Modules/Sources/OpenAPI/GeneratedSources/`.
- Regenerate the committed backend contract and both generated clients from the monorepo root with `./scripts/generate-api-artifacts.sh`.
- Some features depend on Firebase (Auth, Messaging); ensure you have a valid `GoogleService-Info.plist` for non‑mock schemes.

