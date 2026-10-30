# iOS architecture and state

Paths are relative to `ios-app/` unless stated otherwise.

## Project Structure

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
- `Docs/`: architecture, setup, configuration, notification docs, and screenshots.

## Architecture Rules

- Declare `@Dependency` only in reducers, never in SwiftUI views. Views read reducer state or receive explicit values; reducers own clocks, services, and effects.
- Features are TCA modules. Keep state, actions, reducers, and views inside the owning feature.
- Domain services define app-facing boundaries. Features should depend on services through TCA dependencies, not SDKs or generated transport types.
- Adapters implement live behavior and contain external SDK/OpenAPI details.
- Generated OpenAPI types must not leak into reducers, views, or feature state.
- Use `Modules/Sources/Domain/AlertState+Extension.swift` when presenting errors with `AlertState(error:)`.

## App State

- Authenticated app state is held as a shared `Bootstrap` value.
- Account access has two states: signed-in owners (`Role.manager`) and anonymous feedback users (`role == nil`). There is no participant account role or owner-mode toggle. Session participation (`ParticipantEvent`) is independent of account access.
- Apple/Google login always creates or restores owner access. Anonymous users can continue giving feedback with a PIN without signing up.
- The tab bar contains `Giv feedback` and `Aktiviteter`. Owner feedback notifications open the session in the activity navigation stack; anonymous users see sign-in on `Aktiviteter`.
- Feature state should name this shared value `@Shared var bootstrap: Bootstrap`.
- `RootFeature` creates and passes the same `Shared<Bootstrap>` through the logged-in feature tree.
- UI and reducers should derive account, role, activity, event, participant-event, and notification data directly from `bootstrap`.
- Manager-only screens and reducers should require `bootstrap.managerData`; missing manager data on a manager path is invalid state.
- `APIClientCache` bridges live API calls and shared app state updates. If a cache update cannot be applied to the current `Bootstrap`, throw an error instead of silently refetching or falling back.
