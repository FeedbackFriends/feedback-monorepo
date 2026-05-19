# Project: [Lets Grow iOS]

## Quick Reference
- **Platform**: iOS 26+ 
- **Language**: Swift 6.2
- **UI Framework**: SwiftUI
- **Architecture**: The composable architecture (TCA)
- **Minimum Deployment**: iOS 26.0
- **Package Manager**: Swift Package Manager

## XcodeBuildMCP Integration
**IMPORTANT**: This project uses XcodeBuildMCP for all Xcode operations.
- Build: `mcp__xcodebuildmcp__build_sim_name_proj`
- Test: `mcp__xcodebuildmcp__test_sim_name_proj`
- Clean: `mcp__xcodebuildmcp__clean`

## Project Structure & Module Organization
- `App/` holds the app entry point, AppDelegate, and composition root.
- `Modules/Sources/` contains feature modules (TCA) plus shared layers like `Domain/`, `Adapters/`, `DesignSystem/`, `Utility/`, and `OpenAPI/`.
- `Modules/Tests/` contains unit, reducer, and snapshot tests.
- `Resources/` contains assets, localization, and launch assets.
- `PreviewApps/` hosts focused SwiftUI preview apps.

## Testing Guidelines
- Frameworks: Swift Testing, TCA `TestStore`, and `Maestro` for UI tests.
- Place unittests under `Modules/Tests/` mirroring source module names. Maestro lives in the .maestro folder.

## Naming

All SwiftUI views must use the `View` suffix.

The reducer associated with a view should use the same base name without the `View` suffix.

### Examples

| View | Reducer |

|---|---|

| `FocusListView` | `FocusList` |

| `SettingsView` | `Settings` |

| `ProfileView` | `Profile` | 

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
