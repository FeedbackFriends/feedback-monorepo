# iOS App Guidelines

## Scope
Work in `ios-app/` for the native LetsGrow iOS app: SwiftUI screens, TCA reducers, domain services, adapters, generated Swift OpenAPI clients, Xcode project settings, app resources, and Maestro flows.

Keep work in this subtree focused on the iOS app. If the API contract changes, regenerate API artifacts from the monorepo root.

## Quick Reference
- Platform: iOS 26+
- Language: Swift 6.2
- UI: SwiftUI
- Architecture: The Composable Architecture
- Package manager: Swift Package Manager
- Main Xcode project: `Feedback.xcodeproj`
- Development scheme: `Feedback Localhost`

## Project Structure
- `App/`: app entry point, app delegate, configuration, and composition root.
- `Modules/Sources/`: feature modules plus shared layers.
- `Modules/Sources/RootFeature/`: root navigation and authenticated app composition.
- `Modules/Sources/TabbarFeature/`, `FocusFeature/`, `FeedbackFlowFeature/`, `EnterCodeFeature/`, `MoreFeature/`, `SignUpFeature/`: user-facing feature modules.
- `Modules/Sources/Domain/`: domain models, service interfaces, errors, and dependency boundaries.
- `Modules/Sources/Adapters/`: live implementations for API, auth, notification, logging, and system integrations.
- `Modules/Sources/DesignSystem/`: theme, styles, reusable views, resources, and view modifiers.
- `Modules/Sources/OpenAPI/GeneratedSources/`: generated Swift OpenAPI code. Do not hand-edit.
- `Modules/Tests/`: unit, reducer, and snapshot tests.
- `.maestro/`: mobile UI flows.
- `Docs/`: architecture, setup, configuration, notification docs, and screenshots.

## Xcode And Build Tools
Use XcodeBuildMCP for Xcode operations when available:

- build: `mcp__xcodebuildmcp__build_sim_name_proj`
- test: `mcp__xcodebuildmcp__test_sim_name_proj`
- clean: `mcp__xcodebuildmcp__clean`

Use the `Feedback Localhost` scheme for local development unless the user asks for another scheme.

## Architecture Rules
- Features are TCA modules. Keep state, actions, reducers, and views inside the owning feature.
- Domain services define app-facing boundaries. Features should depend on services through TCA dependencies, not SDKs or generated transport types.
- Adapters implement live behavior and contain external SDK/OpenAPI details.
- Generated OpenAPI types must not leak into reducers, views, or feature state.
- Use `Modules/Sources/Domain/AlertState+Extension.swift` when presenting errors with `AlertState(error:)`.

## App State
- Authenticated app state is held as a shared `Bootstrap` value.
- Feature state should name this shared value `@Shared var bootstrap: Bootstrap`.
- `RootFeature` creates and passes the same `Shared<Bootstrap>` through the logged-in feature tree.
- UI and reducers should derive account, role, activity, event, participant-event, and notification data directly from `bootstrap`.
- Manager-only screens and reducers should require `bootstrap.managerData`; missing manager data on a manager path is invalid state.
- `APIClientCache` bridges live API calls and shared app state updates. If a cache update cannot be applied to the current `Bootstrap`, throw an error instead of silently refetching or falling back.

## OpenAPI Way Of Working
- Treat `Modules/Sources/OpenAPI/GeneratedSources/Client.swift` and `Types.swift` as generated contract code only.
- Keep the handwritten app-facing API surface in `Modules/Sources/Domain/Services/ApiClient.swift`.
- `Modules/Sources/Adapters/APIClient/Live/` calls the generated `APIProtocol`, handles response cases, and coordinates auth, cache, and session side effects.
- `Modules/Sources/Adapters/APIClient/Mappers/` translates between generated OpenAPI schema types and Domain models.
- `Modules/Sources/Domain/Models/API/` is the preferred home for handwritten Domain models that closely mirror API request/response concepts.
- Do not mirror every generated schema into Domain. Add Domain equivalents only for concepts the app actually uses.
- Regenerate API artifacts from the monorepo root with `./scripts/generate-api-artifacts.sh`.

## Naming
- SwiftUI views must use the `View` suffix.
- The reducer associated with a view should use the same base name without `View`.

Examples:

| View | Reducer |
| --- | --- |
| `FocusListView` | `FocusList` |
| `SettingsView` | `Settings` |
| `ProfileView` | `Profile` |

## Testing And Linting
- Use Swift Testing, TCA `TestStore`, and snapshot tests for module behavior.
- Put tests under `Modules/Tests/`, mirroring source module names.
- Use Maestro for user-facing mobile journeys when appropriate.
- When changing Swift code, run `swiftlint lint --reporter xcode` before finishing.
- Fix SwiftLint warnings before the final response. Do not run auto-fix commands unless the user explicitly asks.
- Final responses for Swift code changes should include the lint command result.

## Domain And Product Language
- LetsGrow is Danish-first and focused on honest feedback after meetings, workshops, talks, training, and similar repeatable formats.
- Participants answer feedback without accounts.
- Owners plan in their existing calendar and invite a generated per-format LetsGrow email address.
- Preserve the code/API distinction between activity/format, event/session, and participant-event concepts. Check existing models and visible copy before naming new types or screens.

## Git Usage
- Only commit and push when the user explicitly asks.
- Never create or switch branches unless the user explicitly asks.
- When asked to commit and push, commit the intended changes and push the current branch.
