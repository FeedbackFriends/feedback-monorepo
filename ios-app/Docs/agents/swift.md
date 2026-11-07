# Writing Swift in LetsGrow

Read the owning feature and its nearest maintained sibling before choosing a pattern. The toolchain and dependency versions live in [iOS policy](../../AGENTS.md) and [Package.swift](../../Modules/Package.swift). Use those and resolved packages rather than examples from another app or a different TCA release.

Use Apple's current guidance exposed by native Xcode MCP for unfamiliar or version-sensitive APIs. Installed SwiftUI/concurrency skills may supplement these repository rules when relevant. For handwritten Domain/adapters that need reconciliation with generated APIs, use the [sync workflow](../../../.agents/skills/lg-ios-sync-openapi/SKILL.md).

## Choose the owner before the type

The [architecture guide](architecture.md) owns module boundaries, shared Bootstrap, access roles, and dependency placement. A new screen generally extends its existing feature target. A new target needs a distinct responsibility, manifest dependencies, test-plan integration when adding tests, and successful Xcode discovery; creating folders alone does not wire a module into the app.

Follow the existing `@Reducer`, `@ObservableState`, `Action`, `Reduce`, and scoped-child patterns. Keep temporary edits and request/presentation state in the reducer that owns them. Read shared data from the same Bootstrap passed through the tree; do not add a second writable list that needs manual synchronization. Snapshot values used to initialize a form are deliberately temporary and need a clear save/discard boundary.

Views render state and send actions. Reusable presentational views take values/bindings/actions as appropriate. Avoid introducing a parallel ObservableObject/view-model architecture or a second dependency container. See [UI conventions](ui.md) for naming and submission guards.

## Effects and Swift concurrency

When changing asynchronous behavior, identify the effect's owner, lifetime, input snapshot, completion action, and cancellation conditions. Inspect the installed TCA API and sibling behavior rather than adding a generic task wrapper.

- Capture the immutable IDs/inputs needed before entering `.run`; return state changes through actions. Do not hold mutable reducer state across an await.
- Connect view-lifetime effects to their task where appropriate. For repeatable search/load/timer work, decide whether a new request cancels the old one, whether responses can arrive out of order, and what happens when the destination disappears or the account changes. Add cancellation IDs only where the lifetime requires them.
- Handle cancellation deliberately. An expected cancellation should not become a user-facing network error; a cancelled request must not leave a screen permanently in flight. Confirm the current error-mapping path before changing it.
- Preserve actor isolation at SDK/UI boundaries. Do not add `Task.detached`, `nonisolated(unsafe)`, or `@unchecked Sendable` solely to suppress a compiler diagnostic; establish the actual ownership/isolation instead.
- Use injected clocks and deterministic test time for delays and debouncing. Presentation completion callbacks govern sheet dismissal/navigation; arbitrary sleeps are not a presentation contract.

For deeper concurrency/API questions, consult current Apple guidance and installed concurrency skills when available. This page describes LetsGrow's effect design questions rather than pinning evolving Swift syntax.

## APIs, errors, and shared state

The [API guide](api-contract.md) owns generated-to-Domain mapping and the generation path. Features use Domain services; adapters own generated OpenAPI and external SDK types. An API mutation is incomplete until the shared state observed by all affected screens reflects its outcome. Check create/update/delete behavior and IDs against `APIClientCache`, including the account/session state that existed when the request started.

Surface errors through the existing Domain error/alert mapping. Keep diagnostics separate from localized customer copy. Avoid silently swallowing mapping/cache failures or inventing refetch/retry fallbacks that hide invalid state.

## UI, localization, and fixtures

Read the [design-system guide](design-system.md) before SwiftUI edits. Reuse the current components and semantic tokens. Preserve keyboard behavior, focus, accessibility labels, hit areas, disabled/loading behavior, and native sheet/alert semantics when replacing controls.

Follow [product language](product-language.md) and its localization references. App-owned copy uses typed Localization resources with Danish/English translations, parameter/plural semantics, and locale-aware formatting. User-authored session titles, questions, comments, URLs, and PINs remain data.

Build deterministic previews using injected dependencies and explicit shared state. Only meaningful catalog variants need `// Screenshot:` markers; follow [visual review](visual-review.md) for catalog capture and baseline acceptance. A view preview must not trigger a live login or backend mutation.

## Source examples to inspect

These are reading paths, not code templates; confirm their current behavior before reuse.

| Concern | Source and tests |
| --- | --- |
| Form state, validation, create/edit effects | [ManageActivity](../../Modules/Sources/ActivityFeature/Activities/ManageActivity/ManageActivity.swift), [tests](../../Modules/Tests/AppTests/ReducerTests/FocusFeature/ManageActivityTests.swift) |
| Shared activity state and destination composition | [ActivityDetail](../../Modules/Sources/ActivityFeature/Activities/ActivityDetail/ActivityDetail.swift), [tests](../../Modules/Tests/AppTests/ReducerTests/FocusFeature/ActivityDetailTests.swift) |
| Navigation-aware success timing | [SuccessConfirmation tests](../../Modules/Tests/AppTests/ReducerTests/FocusFeature/SuccessConfirmationTests.swift), [UI rules](ui.md) |
| API-to-Bootstrap mutations | [APIClientCache tests](../../Modules/Tests/AppTests/APIClientLiveTests/APIClientCacheMutationTests.swift) |

Follow [testing](testing.md) and the [verification workflow](../../../.agents/skills/lg-verify/SKILL.md) to finish. Test behavior that can regress: a rejected second submission, response arriving after navigation, cache updates visible to a sibling screen, or an error returning the form to a usable state. Avoid asserting incidental reducer structure.
