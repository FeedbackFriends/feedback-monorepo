# iOS architecture

The app uses modular SwiftUI features with The Composable Architecture (TCA). Each feature contains its reducer, observable state, actions, and views. Features compose through parent/child reducers, delegate actions, and shared state.

## Layers and data flow

- **Features** render product screens and own their state transitions and effects.
- **Domain** defines app-facing models and service dependencies.
- **Adapters** implement those services using the backend API and external SDKs.
- **DesignSystem** owns shared visual primitives, styles, and semantic tokens.
- **OpenAPI** contains the generated transport client; adapters translate transport types into Domain models.

A feature calls a Domain service through TCA dependencies. The adapter performs the external operation and returns Domain values. `APIClientCache` coordinates successful API mutations with the shared `Bootstrap` observed by the authenticated feature tree.

## Composition and navigation

[`AppDelegate`](../../ios-app/App/AppDelegate.swift) creates the root store and supplies live dependencies. [`RootFeature`](../../ios-app/Modules/Sources/RootFeature/RootFeature.swift) coordinates authentication and root navigation. Child features compose through scoped reducers and destination state; delegate actions communicate upward. `RootFeature` passes the same shared `Bootstrap` through the logged-in tree.

Read the [architecture and state rules](../../ios-app/AGENTS.md#ios-architecture-and-state) for module boundaries, account/team authority, and shared-state invariants. The same policy owns [Swift implementation](../../ios-app/AGENTS.md#writing-swift-in-letsgrow) and [test requirements](../../ios-app/AGENTS.md#ios-testing-and-linting).

## API contract

The backend generates `contracts/openapi/feedback-api.yaml`, which feeds the committed Swift sources under `ios-app/Modules/Sources/OpenAPI/GeneratedSources/`. Follow the [shared contract flow](../../AGENTS.md#api-contract) and [iOS integration rules](../../ios-app/AGENTS.md#ios-api-integration); regeneration is performed from the monorepo root.

For machine setup and manual development, see [iOS development](development.md).
