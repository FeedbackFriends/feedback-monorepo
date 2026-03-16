# Repository Guidelines

## Project Structure & Module Organization
- `Xcode_project/App/` holds the app entry point, AppDelegate, and composition root.
- `Xcode_project/Modules/Sources/` contains feature modules (TCA) plus shared layers like `Domain/`, `Adapters/`, `DesignSystem/`, `Utility/`, and `OpenAPI/`.
- `Xcode_project/Modules/Tests/` contains unit, reducer, and snapshot tests.
- `Xcode_project/Resources/` contains assets, localization, and launch assets.
- `Xcode_project/PreviewApps/` hosts focused SwiftUI preview apps.

## Build, Test, and Development Commands
- Use the the MCP xcodebuildmcp to communicate with XCode 
- Linting: `swiftlint lint` (uses `Xcode_project/.swiftlint.yml`).

## Coding Style & Naming Conventions
- Swift 6.2, SwiftUI, and TCA patterns; follow Swift API Design Guidelines.
- Indentation: spaces only, Xcode default (4 spaces); no tabs.
- Types in `UpperCamelCase`, functions/properties in `lowerCamelCase`, enum cases in `lowerCamelCase`.
- SwiftLint is the source of truth: `Xcode_project/.swiftlint.yml` (line length warn 200/error 250, function body warn 200/error 300, nesting type level 3). Tests under `Xcode_project/Modules/Tests/` are excluded from linting.
- Keep reducers and dependencies scoped to their feature module; prefer `Domain` protocols with live adapters.
- When a function returning some View has any non-view statements (like let status = …) before the body, Swift can’t use the implicit return, so you must explicitly return the Button.

## Testing Guidelines
- Frameworks: XCTest, TCA `TestStore`, and `swift-snapshot-testing`.
- Place tests under `Xcode_project/Modules/Tests/` mirroring source module names.
- Name tests descriptively (e.g., `testSubmitFeedbackHappyPath`).

## Commit & Pull Request Guidelines
- Commit messages are short and imperative (e.g., `Fix ci unit tests`, `Fix keyboard on join event`).
- PRs should be focused, with a clear description and linked issue if available.
- Add tests for reducer/business logic changes; include screenshots or screen recordings for UI changes.

## Configuration & Secrets
- Runtime configuration comes from Info.plist keys (see `Docs/CONFIGURATION.md`).
- Non-mock schemes may require `GoogleService-Info.plist` for Firebase features.
- OpenAPI client code is generated during builds; avoid manual edits in `Xcode_project/Modules/Sources/OpenAPI/`.

