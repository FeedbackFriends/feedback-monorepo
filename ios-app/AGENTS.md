# LetsGrow iOS

Native LetsGrow iOS app using SwiftUI and The Composable Architecture, targeting iOS 26+ with Swift 6.2 and Xcode 27.

Use Swift Package Manager. The main project is `Feedback.xcodeproj`; the development scheme is `Feedback Localhost`.

- Never create or switch branches unless the user explicitly asks.
- When asked to commit and push, commit the intended changes and push the current branch.
- Use native Xcode MCP for Xcode/simulator operations and discover Apple's available built-in guidance dynamically; read the simulator guide before build, test, launch, or verification work.

## Reference material

Follow the [root delivery workflow](../AGENTS.md#delivery-workflow). For human setup and local testing, see [iOS development](../docs/ios/development.md); for the architecture explanation, see [architecture](../docs/ios/app-architecture.md). Product behavior lives in the [feature overview](../docs/ios/features/overview.md), terminology and string ownership in [localization](../docs/ios/localization.md).

## iOS architecture and state

### Project Structure

- `App/`: app entry point, app delegate, configuration, and composition root.
- `Modules/Sources/`: feature modules plus shared layers.
- `Modules/Sources/RootFeature/`: root navigation and authenticated app composition.
- `Modules/Sources/TabbarFeature/`, `ActivityFeature/`, `FeedbackFlowFeature/`, `EnterCodeFeature/`, `MoreFeature/`, `SignUpFeature/`: user-facing feature modules.
- `Modules/Sources/Domain/`: domain models, service interfaces, errors, and dependency boundaries.
- `Modules/Sources/Adapters/`: live implementations for API, auth, notification, logging, and system integrations.
- `Modules/Sources/DesignSystem/`: theme, styles, reusable views, resources, and view modifiers.
- `Modules/Sources/OpenAPI/GeneratedSources/`: generated Swift OpenAPI code. Do not hand-edit.
- `Modules/Tests/`: unit, reducer, and snapshot tests.
- `.maestro/`: mobile UI flows.
- `../docs/ios/`: architecture, setup, configuration, notification docs, and screenshots.

### Architecture Rules

- Declare `@Dependency` only in reducers, never in SwiftUI views. Views read reducer state or receive explicit values; reducers own clocks, services, and effects.
- Features are TCA modules. Keep state, actions, reducers, and views inside the owning feature.
- Domain services define app-facing boundaries. Features should depend on services through TCA dependencies, not SDKs or generated transport types.
- Adapters implement live behavior and contain external SDK/OpenAPI details.
- Generated OpenAPI types must not leak into reducers, views, or feature state.
- Use `Modules/Sources/Domain/AlertState+Extension.swift` when presenting errors with `AlertState(error:)`.

### App State

- Authenticated app state is held as a shared `Bootstrap` value.
- Account access has two states: signed-in owners (`Role.manager`) and anonymous feedback users (`role == nil`). There is no participant account role or owner-mode toggle. Session participation (`ParticipantEvent`) is independent of account access.
- Apple/Google login restores existing legacy access without requesting Manager privileges. Anonymous employee identities are not linked to Google/Apple accounts. Team leadership is authorized by backend ownership/assignments, separate from legacy Manager claims.
- The tab bar contains `Giv feedback` and either legacy `Aktiviteter` (Manager) or `Mit team` (employees). Employee membership uses `Bootstrap.teamContext`, Domain models and the API adapter. Fetch on team-screen launch, foreground and manual refresh; no employee polling. Approved employees open suggestions from Mit team; `TeamSuggestions` owns the feed, draft, support, withdrawal and reporting requests. Membership changes clear its protected state. Employee participation is iOS-only; there is no employee web flow. Legacy activity sign-in remains in the profile. Owner feedback notifications open the session in the activity navigation stack.
- Feature state should name this shared value `@Shared var bootstrap: Bootstrap`.
- `RootFeature` creates and passes the same `Shared<Bootstrap>` through the logged-in feature tree.
- UI and reducers should derive account, role, activity, event, participant-event, and notification data directly from `bootstrap`.
- Manager-only screens and reducers should require `bootstrap.managerData`; missing manager data on a manager path is invalid state.
- `APIClientCache` bridges live API calls and shared app state updates. If a cache update cannot be applied to the current `Bootstrap`, throw an error instead of silently refetching or falling back.

## iOS API integration

### OpenAPI Way Of Working

- Treat `Modules/Sources/OpenAPI/GeneratedSources/Client.swift` and `Types.swift` as generated contract code only.
- Keep the handwritten app-facing API surface in `Modules/Sources/Domain/Services/ApiClient.swift`.
- `Modules/Sources/Adapters/APIClient/Live/` calls the generated `APIProtocol`, handles response cases, and coordinates auth, cache, and session side effects.
- `Modules/Sources/Adapters/APIClient/Mappers/` translates between generated OpenAPI schema types and Domain models.
- `Modules/Sources/Domain/Models/API/` is the preferred home for handwritten Domain models that closely mirror API request/response concepts.
- Do not mirror every generated schema into Domain. Add Domain equivalents only for concepts the app actually uses.
- Regenerate API artifacts from the monorepo root with `./scripts/shared/generate-api-artifacts.sh`.

## Writing Swift in LetsGrow

Read the owning feature and its nearest maintained sibling before choosing a pattern. The toolchain and dependency versions live in [iOS policy](AGENTS.md) and [Package.swift](Modules/Package.swift). Use those and resolved packages rather than examples from another app or a different TCA release.

Use Apple's current guidance exposed by native Xcode MCP for unfamiliar or version-sensitive APIs. Installed SwiftUI/concurrency skills may supplement these repository rules when relevant. For handwritten Domain/adapters that need reconciliation with generated APIs, use the [sync workflow](../.agents/skills/lg-ios-sync-api/SKILL.md).

### Choose the owner before the type

The [architecture guide](AGENTS.md#ios-architecture-and-state) owns module boundaries, shared Bootstrap, access roles, and dependency placement. A new screen generally extends its existing feature target. A new target needs a distinct responsibility, manifest dependencies, test-plan integration when adding tests, and successful Xcode discovery; creating folders alone does not wire a module into the app.

Follow the existing `@Reducer`, `@ObservableState`, `Action`, `Reduce`, and scoped-child patterns. Keep temporary edits and request/presentation state in the reducer that owns them. Read shared data from the same Bootstrap passed through the tree; do not add a second writable list that needs manual synchronization. Snapshot values used to initialize a form are deliberately temporary and need a clear save/discard boundary.

Views render state and send actions. Reusable presentational views take values/bindings/actions as appropriate. Avoid introducing a parallel ObservableObject/view-model architecture or a second dependency container. See [UI conventions](AGENTS.md#ios-naming-and-forms) for naming and submission guards.

### Effects and Swift concurrency

When changing asynchronous behavior, identify the effect's owner, lifetime, input snapshot, completion action, and cancellation conditions. Inspect the installed TCA API and sibling behavior rather than adding a generic task wrapper.

- Capture the immutable IDs/inputs needed before entering `.run`; return state changes through actions. Do not hold mutable reducer state across an await.
- Connect view-lifetime effects to their task where appropriate. For repeatable search/load/timer work, decide whether a new request cancels the old one, whether responses can arrive out of order, and what happens when the destination disappears or the account changes. Add cancellation IDs only where the lifetime requires them.
- Handle cancellation deliberately. An expected cancellation should not become a user-facing network error; a cancelled request must not leave a screen permanently in flight. Confirm the current error-mapping path before changing it.
- Preserve actor isolation at SDK/UI boundaries. Do not add `Task.detached`, `nonisolated(unsafe)`, or `@unchecked Sendable` solely to suppress a compiler diagnostic; establish the actual ownership/isolation instead.
- Use injected clocks and deterministic test time for delays and debouncing. Presentation completion callbacks govern sheet dismissal/navigation; arbitrary sleeps are not a presentation contract.

For deeper concurrency/API questions, consult current Apple guidance and installed concurrency skills when available. This page describes LetsGrow's effect design questions rather than pinning evolving Swift syntax.

### APIs, errors, and shared state

The [API guide](AGENTS.md#ios-api-integration) owns generated-to-Domain mapping and the generation path. Features use Domain services; adapters own generated OpenAPI and external SDK types. An API mutation is incomplete until the shared state observed by all affected screens reflects its outcome. Check create/update/delete behavior and IDs against `APIClientCache`, including the account/session state that existed when the request started.

Surface errors through the existing Domain error/alert mapping. Keep diagnostics separate from localized customer copy. Avoid silently swallowing mapping/cache failures or inventing refetch/retry fallbacks that hide invalid state.

### UI, localization, and fixtures

Read the [design-system guide](AGENTS.md#letsgrow-ios-design-system) before SwiftUI edits. Reuse the current components and semantic tokens. Preserve keyboard behavior, focus, accessibility labels, hit areas, disabled/loading behavior, and native sheet/alert semantics when replacing controls.

Follow [product language](AGENTS.md#ios-domain-and-product-language) and its localization references. App-owned copy uses typed Localization resources with Danish/English translations, parameter/plural semantics, and locale-aware formatting. User-authored session titles, questions, comments, URLs, and PINs remain data.

Build deterministic previews using injected dependencies and explicit shared state. Only meaningful catalog variants need `// Screenshot:` markers; follow [visual review](../.agents/skills/lg-ios-capture-screenshots/SKILL.md#visual-review) for catalog capture and baseline acceptance. A view preview must not trigger a live login or backend mutation.

### Source examples to inspect

These are reading paths, not code templates; confirm their current behavior before reuse.

| Concern | Source and tests |
| --- | --- |
| Form state, validation, create/edit effects | [ManageActivity](Modules/Sources/ActivityFeature/Activities/ManageActivity/ManageActivity.swift), [tests](Modules/Tests/AppTests/ReducerTests/FocusFeature/ManageActivityTests.swift) |
| Shared activity state and destination composition | [ActivityDetail](Modules/Sources/ActivityFeature/Activities/ActivityDetail/ActivityDetail.swift), [tests](Modules/Tests/AppTests/ReducerTests/FocusFeature/ActivityDetailTests.swift) |
| Navigation-aware success timing | [SuccessConfirmation tests](Modules/Tests/AppTests/ReducerTests/FocusFeature/SuccessConfirmationTests.swift), [UI rules](AGENTS.md#ios-naming-and-forms) |
| API-to-Bootstrap mutations | [APIClientCache tests](Modules/Tests/AppTests/APIClientLiveTests/APIClientCacheMutationTests.swift) |

Follow [testing](AGENTS.md#ios-testing-and-linting) and the [implementation workflow](../AGENTS.md#delivery-workflow) to finish. Test behavior that can regress: a rejected second submission, response arriving after navigation, cache updates visible to a sibling screen, or an error returning the form to a usable state. Avoid asserting incidental reducer structure.

## LetsGrow iOS Design System

Use `Modules/Sources/DesignSystem/` as the source of truth. Prefer reusing existing tokens, styles, and reusable views before introducing new UI primitives.

### Applying the design system

1. Inspect the relevant tokens, styles, or reusable views in [DesignSystem](Modules/Sources/DesignSystem).
2. Inspect the exact source files you plan to use or change before making UI edits.
3. Reuse existing `Color`, `Font`, button style, reusable view, and modifier APIs where they fit.
4. Add new DesignSystem code only when the existing surface clearly does not cover the need.

### Rules

- Use only semantic colors exposed from `Resources/Colors/Colors.swift`, such as `Color.theme...` and UIKit bridges defined there. Do not use SwiftUI/UIKit system colors or raw palette colors in app UI, including `.secondarySystemBackground`, `.systemGray`, `.secondary`, `.tertiary`, `.green`, `Color.gray`, `Color.black`, `Color.white`, or `UIColor.white`.
- Use the DesignSystem public text-style modifiers. Direct font calls belong inside DesignSystem font/style infrastructure; do not introduce ad hoc font families.
- Prefer existing button styles from `Styles/ButtonStyles/` over custom inline button styling.
- Prefer existing reusable views from `ReusableViews/` for common empty, error, banner, close, picker, and event-info UI.
- Use `Theme.cornerRadius`, `Theme.padding`, and `Constants.maxWidthForLargeDevices` instead of duplicating those layout constants.
- Use `.isLoading(...)` when working with loading-aware button styles.
- Keep app-facing UI code free of raw asset names when `Image` helpers already exist in `Resources/Images/Images.swift`.
- When extending the design system, put new code in the matching DesignSystem subfolder and follow the established API shape.

### Source map

| Need | Owner under `Modules/Sources/DesignSystem/` |
| --- | --- |
| Semantic colors and layout tokens | `Resources/Colors/Colors.swift`, `DomainColors.swift`, `Constants.swift` |
| Typography | `Styles/OtherStyles/TextStyles.swift`, `Resources/Fonts/` |
| Icons and asset helpers | `Resources/Images/Images.swift` |
| Loading/pressed button behavior | `Styles/ButtonStyles/`; supply `.isLoading(...)` with a stable label |
| Empty/error states, banners, close controls, inputs | `ReusableViews/` and `FirstResponderField.swift` |
| Shared modifiers and UIKit appearance | `ViewModifiers/` and `AppTheme/` |

Keep font sizing inside the typography/icon infrastructure. Text styles set their foreground; apply a semantic foreground override afterward when state or sentiment needs it. Keep one-off layouts and product copy in features. Add shared primitives only when existing composition does not fit.

## iOS naming and forms

### Naming

- SwiftUI views must use the `View` suffix.
- The reducer associated with a view should use the same base name without `View`.

Examples:

| View | Reducer |
| --- | --- |
| `FocusListView` | `FocusList` |
| `SettingsView` | `Settings` |
| `ProfileView` | `Profile` |

### Form Validation

- Disable Continue/Next/Create/Save actions until all required inputs are valid, and while submission is in flight.
- Do not enable invalid form actions just to show missing-field errors after tapping. Mark required fields clearly and preserve optional fields as optional.
- Apply the same validation guard in reducers or submission handlers so keyboard/programmatic actions cannot bypass it. Keep API and network error reporting.

### Reusable UI

Use the shared `DesignSystem` components before adding local styling:

- `.surfaceCard(padding:)` owns card padding, surface color, rounded clipping, and hit shape. Apply it to the content inside a button; keep navigation and actions in the feature.
- `PillTagView` owns metadata pills and status badges. Use `.metadata` for labels and counts, `.badge` for unread counts, and `.compactBadge` for compact new-status labels. Its content builder supports labels with icons.
- `CircleIconView` owns resizable icons with circular backgrounds. Features supply the image and semantic colors.
- `ContentSectionView` groups a section header, optional trailing action, and vertically stacked content.
- `PinCodeTextFieldView` owns PIN entry appearance, number keyboard, focus binding, and input validation. Features own submission, request state, and focus synchronization.
- `InlineActionButtonStyle` gives add/edit actions inside cards a green icon and label, supporting typography, and a leading, full-width 44-point tap area. Use it for “Tilføj spørgsmål”, “Rediger spørgsmål”, and “Rediger aktivitet”.
- `TextInputView` owns labeled text field cards, spacing, typography, and light/dark input colors. Use it for activity names and question text; features supply focus bindings, content, and line limits.
- Use `.successMessage(_:isPresented:)` for transient success confirmations. It presents the shared `SuccessMessageView` as a glass overlay at the top of the content, below navigation controls. Features own visibility, timers, and navigation; the component never dismisses a screen or dims its background.

Keep domain-aware compositions such as `FeedbackTypeTagView` and session cards in their feature. Compose them from shared primitives rather than duplicating their visual styling. SwiftUI `Form`, `Section`, `Label`, and `ContentUnavailableView` remain suitable native building blocks.

For activity/session mutations, the destination owns `SuccessConfirmation`. Queue the message when navigating, then start its timer from completed navigation (`onNavigationTransitionCompleted`) or sheet `onDismiss`. Close delete confirmation sheets before delegating navigation. Chain sheet dismissal and navigation through callbacks, never fixed sleeps.

## iOS domain and product language

Read the shared [brand and product strategy](../docs/shared/product/lets-grow-strategi-teamtrivsel.md) for product direction, audience, roles, and positioning. It supersedes the former meeting-feedback product guidance. Preserve the strategy's distinction between confirmed direction and hypotheses awaiting validation.

### Strategy and current implementation

The intended product centers on employee-driven improvements: suggest, vote, decide, try, and follow up. Use the strategy when designing new product behavior and copy.

Existing code/API names such as `Activity`, `Event`, and `ParticipantEvent` describe the current implementation. Inspect the owning models and task's migration scope before renaming types or changing contracts; the strategy document does not itself migrate those models.

### Localization

Use the [localization guide](../docs/ios/localization.md) for module ownership, typed strings, Danish terminology, formatting, notification contracts, and verification limits.

## iOS testing and linting

- Use Swift Testing, TCA `TestStore`, and snapshot tests for module behavior.
- Put tests in the existing owning target under `Modules/Tests/`. Current unit/reducer suites are grouped in `AppTests` and `InsightsTests`; do not create one test target per screen by default. For a new test target, update the package/project and selected test plan and confirm discovery through native Xcode MCP.
- Use Maestro for user-facing mobile journeys when appropriate.
- When changing Swift code, run `python3 scripts/ios/lint-swift-changes.py --base <merge-base>` from the monorepo root before finishing. Use the merge base with the task's target branch (normally `origin/main`); use `HEAD` for a check of uncommitted changes only.
- Fix lint violations on added or modified lines. Existing violations on untouched lines are not a gate; do not expand the task to clean them up. The script honors `.swiftlint.yml` exclusions and never modifies files. Do not run auto-fix commands unless the user explicitly asks.
- Final responses for Swift code changes should include the lint command result.

GitHub Actions uses command-line Xcode tools on its isolated macOS runner for the `iOS` workflow. This CI exception does not change the native Xcode MCP requirement for local agent work. Explicitly requested Maestro flows remain governed by [the Maestro flow guidance](.maestro/README.md) and may reset local fixture data.

## Xcode and simulator workflows

### Xcode And Simulator Harness

Setup and configuration ownership are documented in [the harness overview](../docs/ios/development.md#setup-and-tooling). Loaded Apple guidance owns device-interaction mechanics, SwiftUI API guidance, test modernization, and profiling; current MCP descriptions own tool names and arguments. This guide and the repository skills own LetsGrow schemes, accounts, fixtures, architecture, verification scope, and snapshot approval; [testing](AGENTS.md#ios-testing-and-linting) owns test and lint policy.

- Screenshot capture uses the app-hosted Point-Free SnapshotTesting target and the separate `ScreenSnapshots` plan. Its full-catalog scope, alert readiness checks and visual review workflow are documented in [the screenshots documentation](../docs/ios/screenshots/README.md). Use native Xcode MCP to build and run it.
- For screen and state screenshots, follow [the screenshot skill](../.agents/skills/lg-ios-capture-screenshots/SKILL.md). Captures use native Xcode MCP and publish original-size PNG files under `screenshots/current/`. Approved baselines live under root `docs/ios/screenshots/catalog/`.

- Use the native Xcode MCP server (`mcp__xcode`) for all interaction with Xcode and simulators: workspace discovery, scheme/destination selection, builds, tests, launch arguments, install/run, UI interaction, screenshots, logs, and debugging.
- Discover Apple's current built-in skills and instructions through the capabilities exposed in the session and Xcode's tool responses. Read relevant guidance when available; do not hard-code Apple's skill names, installation paths, or versions in repository instructions. If referenced guidance is unavailable, use current native tool descriptions when sufficient; report a blocker only when the required capability, permission, or operational information is missing. Follow the [Apple skills setup](../docs/ios/development.md#apple-skills-setup) to restore missing guidance. Repository and higher-priority session instructions take precedence over Apple guidance, including requests to use subagents. Delegate only when authorized by the user or applicable repository instructions; otherwise perform the work directly.
- Use `Feedback Localhost` for local development and testing unless the user explicitly asks for another scheme. Match the workspace to the current checkout’s absolute `Feedback.xcodeproj` path. Keep the active eligible simulator by default; if none is active, select an eligible simulator and report it. Never implicitly select a physical device. An explicitly requested production launch uses `Feedback Production` (Release); tests still use Localhost, then reselect Production before its build/run.
- Do not substitute XcodeBuildMCP, `xcodebuild`, `xcrun simctl`, AppleScript, computer-use automation, or Maestro for these Xcode/simulator operations. If native Xcode MCP is unavailable or fails, report the exact blocker instead of silently switching tools. Existing explicitly requested Maestro test flows remain separate from this harness.
- Apple-guided profiling may use the `xctrace` CLI. This exception covers profiling, not replacement build, launch, or simulator-control commands. File edits, SwiftLint, API generation scripts, and local backend HTTP requests may also use normal filesystem/shell tools.

### Shared launch setup

Use current native MCP tools to discover this checkout's absolute `Feedback.xcodeproj` path, open it if absent, and select the requested scheme and eligible simulator. If opening times out, list workspaces again before reporting a blocker. Use identifiers from the current session. Keep the active eligible simulator unless the user requests another; never implicitly select a physical device.

When interaction or per-launch arguments/environment are needed, use Apple's workspace-backed device-session lifecycle and current tool descriptions. Build/install/run through that session once; close it in cleanup even on failure, leaving a successfully launched app running. Ordinary launch-only requests may use the native project run operation instead. Follow the owning skill for account inputs and observable success criteria.

### Simulator Verification

- Honor build-only and launch-only requests without requiring the full verification sequence. After implementation, build and run tests relevant to the change using the [verification matrix](AGENTS.md#choose-verification-by-the-change); shared behavior or test-harness changes require all unit tests. Run changed-line Swift lint when Swift files changed, and hand off changed user-facing behavior for human manual testing. Run simulator interaction and visual checks only when explicitly requested, following the [completion policy](../AGENTS.md#implementation-completion).
- Unit tests use `Feedback Localhost` and the `UnitTests` plan. Confirm enabled test discovery includes both `AppTests` and `InsightsTests`, inspecting the full list when truncated. Missing plans, targets, or zero discovered tests are blockers; preserve the intended scheme rather than switching to hide configuration failures. Select tests using discovered identifiers; a suite identifier can cover Swift test names the native tool rejects individually.
- Choose one launch route per build: ordinary run or interactive install/run. Repeated launches can create extra Device Hub windows. Authenticated localhost checks use [the local run skill](../.agents/skills/lg-ios-run-local/SKILL.md); production login uses the normal app UI.
- For live verification, pair actions with observable expected results. Base taps on the latest hierarchy and inspect screenshots for layout. Close device-interaction sessions even on failure, leaving a successfully launched app available for manual testing. An error alert makes the check failed or inconclusive; launch success alone is not UI verification.
- Retrieve focused build errors or runtime logs on failure. Report the exact blocked operation and continue independent checks where possible. Do not automate Xcode permission dialogs.

Report scheme/simulator, build, test counts and targets, Swift lint, launch, login, live UI steps/results, and relevant blockers/artifact paths separately. Mark omitted checks `not run` with a reason; distinguish passed, failed, blocked, and inconclusive results. If the app cannot be launched, state why.

### Simulator Login

Use [lg-ios-run-local](../.agents/skills/lg-ios-run-local/SKILL.md) for local launch and authentication on one employee simulator. Add `login-only` to use an already running backend without preparing services or data. The skill owns explicit test-account overrides and token handling. Login alone must not reset or reseed test data.

## Feature development

### Choose verification by the change

Use the smallest combination that can detect the actual regression. The [simulator guide](AGENTS.md#xcode-and-simulator-workflows) owns project-specific execution rules and result reporting; [testing](AGENTS.md#ios-testing-and-linting) owns lint and test policy. Implementation finishes with relevant automated tests, build and lint checks, applicable agent review, and material findings resolved. Human manual testing and [visual review](../.agents/skills/lg-ios-capture-screenshots/SKILL.md#visual-review) follow handoff; the runtime paths below are guidance for explicitly requested testing, not implementation completion gates.

| Change | Behavioral evidence | Runtime/data needs |
| --- | --- | --- |
| Reducer or validation | Relevant TestStore tests: state transitions, effects, rejected invalid/duplicate actions, failure recovery | Injected dependencies; no live backend required for unit tests |
| Domain mapper or API/cache mutation | Relevant mapper/adapter/cache tests, then affected live path | Localhost and existing fixture unless preparation requested |
| SwiftUI layout, components, or copy | Build, complete screenshot catalog/review; interact with changed controls and native presentation | Stable preview fixtures plus a live simulator; check affected language/long-content layouts |
| Auth, role, root or navigation state | Reducer tests plus owner and anonymous entry/transition paths that changed | One employee simulator; leader journeys use web |
| Session/PIN/feedback journey | Relevant reducers; legacy PIN feedback paths only when affected | One employee simulator, reachable session, explicitly requested product mutations |
| Notification or deep-link routing | Parsing/routing tests plus the affected native path; notification runner when requested | Follow the [notification skill](../.agents/skills/lg-ios-test-notifications/SKILL.md); do not equate a routing test with delivered push |
| Contract changes | Regenerate clients; relevant backend, mapper and feature tests; affected live path | Backend guidance and [API generation](../AGENTS.md#api-contract) |
| Documentation/skills only | Skill validation, local link checks, scenario walkthroughs for routing and permissions | No app build, backend reset, or simulator launch needed |

A build proves compilation. A discovered and passing test proves the behavior it asserts. A fresh snapshot proves its fixture layout. A successful live journey proves the observed path on the selected backend/account. Record each separately.

Prefer deterministic injected test data for unusual errors, times, and edge cases rather than adding live fixture endpoints solely for reducer tests. Local launch/login does not authorize seeding, resets, or feedback submissions; follow [lg-ios-run-local](../.agents/skills/lg-ios-run-local/SKILL.md) for account and data options.
