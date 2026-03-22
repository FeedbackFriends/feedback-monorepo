# Architecture

The app uses a **TCA-based modular architecture** where features are self-contained modules that can compose together.

## How It Works

**TCA Feature Modules** are the primary architectural unit. Each feature contains:
- `@Reducer` for state management and business logic
- `@ObservableState` for the feature's data
- SwiftUI views that bind to the store
- Actions that represent user interactions and system events

**Features compose in two ways**:
1. **Parent-Child**: Features embed child features (e.g., `TabbarFeature` contains `EventsFeature`)
2. **Shared State**: Features share data via TCA's `@Shared` mechanism (e.g., `Session` is shared across many features)

**Domain Services** provide interfaces that features use to interact with external systems:
- Defined as protocols in the `Domain` module
- Injected via TCA's `@Dependency` system
- Implemented by `Adapters` module using real APIs/SDKs

**The flow**: Feature needs data → calls Domain service → Adapter implements service → talks to external API/Firebase/etc.

## Feature Composition Patterns

**Parent-Child Features**: Some features contain other features as children:
```swift
// TabbarFeature contains multiple child features
TabbarFeature.State(
    enterCode: EnterCode.State(),
    managerEvents: ManagerEvents.State(),
    moreSection: MoreSection.State(),
    // ...
)
```

**Shared State**: Features share data using `@Shared`:
```swift
// Session is shared across many features
@ObservableState
public struct State {
    @Shared public var session: Session
}
```

**Feature Communication**: Features communicate via:
1. **Direct embedding** (parent controls child state)
2. **Delegate actions** (child notifies parent of events)
3. **Shared state changes** (multiple features react to same state)

## TCA Conventions

- `@Reducer` defines a feature module’s logic and effects
- `@ObservableState` holds state
- `@Dependency` reads injected services
- `Store` is constructed in the app composition root and passed into SwiftUI views

Example dependency injection (from the app composition root):

```54:67:Xcode_project/App/AppDelegate.swift
lazy var intialStore = Store(
    initialState: RootFeature.State()
) {
    RootFeature()._printChanges()
} withDependencies: {
    $0.webURLClient = .live(
        webBaseUrl: InfoPlistConfig.webBaseUrl,
        appStoreId: InfoPlistConfig.appStoreId
    )
    $0.systemClient = .live(supportEmail: InfoPlistConfig.supportEmail)
    $0.notificationClient = self.notificationClient
    $0.authClient = .live
    $0.apiClient = self.apiClient
}
```

Example reducer with dependency usage:

```78:86:Xcode_project/Modules/Sources/RootFeature/RootFeature.swift
@Dependency(\.apiClient) var apiClient
@Dependency(\.authClient) var authClient
@Dependency(\.mainQueue) var mainQueue
@Dependency(\.continuousClock) var clock

public var body: some ReducerOf<Self> {
    // child scopes + Reduce { state, action in ... }
}
```

## Navigation

- Features compose via child reducers (`Scope`) and `Destination` state.
- Root navigation is coordinated by `RootFeature`.

## Testing

- Reducer tests live in `Xcode_project/Modules/Tests/`.
- Prefer testing reducer logic with injected test dependencies.

## OpenAPI Client

- Spec and generated client live under `Modules/Sources/OpenAPI/`.
- Swift OpenAPI Generator plugin runs on build to produce client code.


