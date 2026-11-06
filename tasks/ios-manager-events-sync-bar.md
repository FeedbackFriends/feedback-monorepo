---
status: in-progress
areas: [ios]
created: 2026-01-13
updated: 2026-11-06
---

# Manager events sync bar

## Problem and outcome

Provide a clear syncing bar and a one-time success indication without changing sync scheduling or the rest of the list/header.

## Scope

- In scope: sync presentation, foreground/background lifecycle behavior, and relevant tests.
- Out of scope: networking/scheduling changes and unrelated header/list redesign.

## Context

Current-code audit 2026-11-06: ManagerEventsView and SyncStatus no longer exist. ActivityListView is the owner list; TabbarLifecycle polls getBootstrapUpdate every 10 seconds and receives cache updates separately through sessionChangedListener. TabbarView already forwards foreground/background actions, which are currently no-ops. The historical design below describes intent only; the current implementation decisions supersede its symbol names.

### Manager Events Sync Bar Design

### Overview
Replace the current 2pt sync line in `ManagerEventsView` with a thicker, more expressive loading bar. The bar is invisible when idle, animates a small blue block left-to-right during syncing, and shows a one-time green success flash the first time data is loaded after app launch (or after the app returns from background).

### Goals
- Provide a clearer sense of active syncing without adding visual noise.
- Keep the bar invisible when idle.
- Show a one-time success confirmation after the first sync completes.

### Non-Goals
- Redesign the rest of the header or the list.
- Change sync scheduling or networking behavior.

### UX Behavior
- **Syncing:** A 4pt rounded bar appears. A small `themeBlue` block sweeps left-to-right across a subtle track.
- **Success (first load only):** After the first successful sync in a session, the bar fills with `themeSuccess` for a short moment, then fades out.
- **Idle:** The bar is invisible.

### State + Data Flow
- `TabbarLifecycle` continues to set `syncStatus.isSyncing` during polling and updates `syncStatus.lastUpdatedAt` on session changes.
- `ManagerEventsView` reads `syncStatus` and manages local animation state:
  - Tracks `lastUpdatedAt` transitions from `nil` -> non-`nil` to detect the first successful sync.
  - Shows the green success bar once, then hides it.
- When the app enters background, `syncStatus.lastUpdatedAt` is reset to `nil` (and `isSyncing` set to `false`). This enables the “first load” behavior again on return.

### Implementation Notes
- Replace the current rectangle line with a `GeometryReader`-driven bar using `RoundedRectangle` and a 4pt height.
- Animate the blue block with a linear, repeating animation while `isSyncing` is true.
- Fade the success bar in and out with `easeInOut` animations.
- Wire `TabbarView`’s `scenePhase` to send `.enterBackground` and `.enterForeground` actions to `TabbarLifecycle`.
- Initialize `SyncStatus` without a default `lastUpdatedAt` so the first update is detected correctly.

### Error Handling
No behavioral changes to error handling. If syncing fails, the bar simply stops when `isSyncing` resets.

### Testing
- Add a `TestStore` test for `TabbarLifecycle` to ensure `.enterBackground` resets `syncStatus.lastUpdatedAt` and `isSyncing`.
- Optional: add a snapshot or view test for `ManagerEventsView` if/when snapshot coverage exists for EventsFeature.

## Decisions and open questions

- Confirmed: original desired syncing/first-success/idle behavior is preserved.
- Assumptions: no completion evidence was present in the original design.
- Confirmed implementation mapping: ActivityListView renders a shared 4pt SyncIndicatorView; TabbarLifecycle owns transient presentation phase, foreground state, active request ID and first-success latch. TabbarView passes presentation values, without copying Bootstrap data.
- Assumption: the first successful existing 10-second poll (including an unchanged/204 response) counts as the first confirmation; no extra startup/foreground request is added. Listener updates from unrelated mutations do not fake a successful poll.
- Background clears the active presentation/request ID and success latch, cancels only the presentation timer, and ignores late results. Existing polling/network scheduling remains unchanged. Success display lasts 800ms; Reduce Motion uses a static blue bar.
- Unresolved: None.
- Execution constraints: use current iOS/native Xcode, design tokens, localization, and visual review guidance.

## Acceptance criteria

- [ ] AC-1: Active sync has a visible loading bar and idle state hides it.
- [ ] AC-2: The first successful sync after launch/foreground gives one success indication.
- [ ] AC-3: Failure/lifecycle behavior preserves the existing sync semantics and relevant verification passes.

## Implementation plan

- [x] Confirm current source ownership and existing implementation before changing code.
- [x] Implement reducer/lifecycle and presentation changes using current APIs/tokens.
- [ ] Verify lifecycle/state tests, the live transition, Swift lint, and full visual review.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1, AC-2 | Deterministic sync state/clock | Reducer tests and native live foreground/sync journey | Correct loading/idle state and one-time success |
| AC-3 | Failure fixture and changed UI | Failure/lifecycle tests plus build/lint/catalog review | Existing failure behavior and accepted layout |

## Human review

TabbarLifecycle owns transient sync presentation around the existing sequential 10-second polling effect; cache listener updates still update the same Bootstrap. Each poll gets an ID so background/foreground transitions discard stale presentation completions. Background resets only presentation/latch and cancels its 800ms timer; network scheduling is unchanged. An unchanged/204 response is a successful poll, so success does not depend on new data or unrelated cache mutations.

TabbarView passes a phase to ActivityListView, which composes a 4pt SyncIndicatorView from DesignSystem. Idle reserves the same 4pt to avoid list jumps. Animated blue block uses TimelineView; Reduce Motion and debug snapshot fixtures use a static blue bar. No API, persistence or localization changes.

Reading path: `ios-app/Modules/Sources/TabbarFeature/TabbarLifecycle.swift` → `ios-app/Modules/Tests/AppTests/ReducerTests/Tabbar/TabbarLifecycleTests.swift` → `ios-app/Modules/Sources/TabbarFeature/TabbarView.swift` → `ios-app/Modules/Sources/ActivityFeature/Activities/ActivityList/ActivityListView.swift` → `ios-app/Modules/Sources/DesignSystem/ReusableViews/SyncIndicatorView.swift`. Existing TCA/shared Bootstrap boundaries are retained; moving historical ManagerEventsView intent to ActivityListView and counting the first successful existing poll are implementation decisions.

## Handoff

- Completed: Historical symbols reconciled; lifecycle-owned sync phase, request correlation, one-time foreground success and reset implemented. Existing polling interval and network call order retained. Shared indicator supports Reduce Motion; activity-list active-sync snapshot added.
- Verification results: 2026-11-06 Feedback Localhost / LetsGrow Manager iOS 27.2: buildForTesting passed; UnitTests discovery includes 218 enabled tests across AppTests/InsightsTests. TabbarLifecycleTests: 3 passed, 0 failed, testing failure before success, repeated success, 800ms timeout, timer cancellation on background, late response rejection after foreground and anonymous suppression. SwiftLint --base HEAD: 0 violations in 6 files. ScreenSnapshots capture: 1 passed; 59 PNGs published; 47 hashes retained from reviewed profile capture and 12 changed/new images reviewed. Findings/hashes `screenshots/review/sync-findings.json`, gallery `screenshots/index.html`; baselines preserved.
- Blockers: Native live animation/foreground journey remains blocked by the Xcode session-state inconsistency recorded in `tasks/ios-text-input-full-surface-focus.md`. Snapshots prove fixture layout, not movement; manual check added to `tasks/ios-physical-device-verification.md`.
- Next action: Restore native DeviceInteraction, launch the new build, wait for existing polls, verify blue motion/first green success/idle and background reset plus Reduce Motion; complete remaining required verification before deleting this task.
