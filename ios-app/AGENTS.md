# Repository Guidelines

## Project Structure & Module Organization
- `App/` holds the app entry point, AppDelegate, and composition root.
- `Modules/Sources/` contains feature modules (TCA) plus shared layers like `Domain/`, `Adapters/`, `DesignSystem/`, `Utility/`, and `OpenAPI/`.
- `Modules/Tests/` contains unit, reducer, and snapshot tests.
- `Resources/` contains assets, localization, and launch assets.
- `PreviewApps/` hosts focused SwiftUI preview apps.

## Build, Test, and Development Commands
- Use the the xcode MCP to communicate with XCode, build app, run tests etc.
- Linting: `swiftlint lint` (uses `.swiftlint.yml`).

## Coding Style & Naming Conventions
- Swift 6.2, SwiftUI, and TCA patterns; follow Swift API Design Guidelines.
- Indentation: spaces only, Xcode default (4 spaces); no tabs.
- Types in `UpperCamelCase`, functions/properties in `lowerCamelCase`, enum cases in `lowerCamelCase`.
- SwiftLint is the source of truth: `.swiftlint.yml` (line length warn 200/error 250, function body warn 200/error 300, nesting type level 3). Tests under `Modules/Tests/` are excluded from linting.
- Keep reducers and dependencies scoped to their feature module; prefer `Domain` protocols with live adapters.
- When a function returning some View has any non-view statements (like let status = …) before the body, Swift can’t use the implicit return, so you must explicitly return the Button.

## Testing Guidelines
- Frameworks: XCTest, TCA `TestStore`, and `swift-snapshot-testing`.
- Place tests under `Modules/Tests/` mirroring source module names.
- Name tests descriptively (e.g., `testSubmitFeedbackHappyPath`).

## Commit & Pull Request Guidelines
- Commit messages are short and imperative (e.g., `Fix ci unit tests`, `Fix keyboard on join event`).
- PRs should be focused, with a clear description and linked issue if available.
- Add tests for reducer/business logic changes; include screenshots or screen recordings for UI changes.

## Collaboration Notes
- When you learn something about the project that is likely to be useful again, such as overall app architecture, framework choices, conventions, or ways of working, suggest adding it to `AGENTS.md`.
- Do not update `AGENTS.md` for that kind of newly learned project knowledge without asking the user first.

## Configuration & Secrets
- Runtime configuration comes from Info.plist keys (see `Docs/CONFIGURATION.md`).
- Non-mock schemes may require `GoogleService-Info.plist` for Firebase features.
- OpenAPI client code is committed under `Modules/Sources/OpenAPI/GeneratedSources/`; treat those generated files as repository-owned source files for builds, but never edit them by hand.
- The source of truth for regenerating the Swift OpenAPI client and types is the repo-root script `../scripts/generate-api-artifacts.sh` (run from the monorepo root `./scripts/generate-api-artifacts.sh`), which lives outside `ios-app/`. Do not wire normal app builds to regenerate these files inside Xcode.

## OpenAPI Way Of Working
- Treat `Modules/Sources/OpenAPI/GeneratedSources/Client.swift` and `Modules/Sources/OpenAPI/GeneratedSources/Types.swift` as generated contract code only. Never hand-edit generated files.
- Keep a single handwritten app-facing `APIClient` in `Modules/Sources/Domain/Services/ApiClient.swift`. It should represent the app-facing endpoint surface used by features.
- `Modules/Sources/Adapters/APIClient/Live/` is the live anti-corruption layer. It is responsible for calling the generated `APIProtocol`, handling `.ok` / `.internalServerError` / `.undocumented`, and coordinating auth, cache, and session side effects.
- `Modules/Sources/Adapters/APIClient/Mappers/` owns handwritten translation between generated OpenAPI schema types and Domain models.
- `Modules/Sources/Domain/Models/API/` is the preferred home for handwritten Domain models that closely mirror OpenAPI-backed data or request/response concepts consumed by the app.
- Keep foundational Domain types that are not primarily API-shaped in `Modules/Sources/Domain/Models/`.
- Do not leak generated `Components.Schemas.*`, `Operations.*`, generated response wrapper enums, or transport-layer helper types into reducers, features, or Domain services.
- Do not literally mirror all of `GeneratedSources/Types.swift` into `Domain`. Instead, create handwritten Domain equivalents only for schema concepts the app actually uses.
- When adding or updating endpoints, keep the flow: generated `Client` surface -> handwritten `Domain/APIClient` entry -> handwritten mapper code -> live adapter implementation.
- If OpenAPI and Domain drift, use the repo-local skill `openapi-domain-sync` under `.codex/skills/openapi-domain-sync/` to inventory the generated endpoint surface, current `APIClient`, and handwritten Domain model coverage before editing.
