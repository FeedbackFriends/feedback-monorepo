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
- Use `Modules/Sources/Domain/AlertState+Extension.swift` when presenting errors with `AlertState(error:)`.

#Schemes
- `Feedback Localhost` always use this when developing.

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

## Domain Language
- `Activity` is the canonical code and domain term. Use `Activity` in models, reducers, services, API mappers, tests, and type/file names.
- `Focus` is the user-facing UI name for an `Activity`. Use "focus" in visible copy when referring to this concept.
- `Event` is the canonical code and API domain term for an occurrence under an `Activity`.
- `Session` is the user-facing UI name for an `Event`, for now. Use "session" in visible copy when referring to this concept.
- One `Activity` has zero or more `Event`s.
- Avoid using "event" in visible copy for the manager-facing session detail flow.
- Do not confuse user-facing feedback sessions with technical bootstrap/auth session state already named `session` in code.

## Collaboration Notes
- When you learn something about the project that is likely to be useful again, such as overall app architecture, framework choices, conventions, or ways of working, suggest adding it to `AGENTS.md`.
- Do not update `AGENTS.md` for that kind of newly learned project knowledge without asking the user first.

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
- If OpenAPI and Domain drift, use the repo-local skill `openapi-domain-sync` to inventory the generated endpoint surface, current `APIClient`, and handwritten Domain model coverage before editing.

# Guide to the agent

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
