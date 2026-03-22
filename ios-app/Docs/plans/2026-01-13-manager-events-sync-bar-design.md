# Manager Events Sync Bar Design

## Overview
Replace the current 2pt sync line in `ManagerEventsView` with a thicker, more expressive loading bar. The bar is invisible when idle, animates a small blue block left-to-right during syncing, and shows a one-time green success flash the first time data is loaded after app launch (or after the app returns from background).

## Goals
- Provide a clearer sense of active syncing without adding visual noise.
- Keep the bar invisible when idle.
- Show a one-time success confirmation after the first sync completes.

## Non-Goals
- Redesign the rest of the header or the list.
- Change sync scheduling or networking behavior.

## UX Behavior
- **Syncing:** A 4pt rounded bar appears. A small `themeBlue` block sweeps left-to-right across a subtle track.
- **Success (first load only):** After the first successful sync in a session, the bar fills with `themeSuccess` for a short moment, then fades out.
- **Idle:** The bar is invisible.

## State + Data Flow
- `TabbarLifecycle` continues to set `syncStatus.isSyncing` during polling and updates `syncStatus.lastUpdatedAt` on session changes.
- `ManagerEventsView` reads `syncStatus` and manages local animation state:
  - Tracks `lastUpdatedAt` transitions from `nil` -> non-`nil` to detect the first successful sync.
  - Shows the green success bar once, then hides it.
- When the app enters background, `syncStatus.lastUpdatedAt` is reset to `nil` (and `isSyncing` set to `false`). This enables the “first load” behavior again on return.

## Implementation Notes
- Replace the current rectangle line with a `GeometryReader`-driven bar using `RoundedRectangle` and a 4pt height.
- Animate the blue block with a linear, repeating animation while `isSyncing` is true.
- Fade the success bar in and out with `easeInOut` animations.
- Wire `TabbarView`’s `scenePhase` to send `.enterBackground` and `.enterForeground` actions to `TabbarLifecycle`.
- Initialize `SyncStatus` without a default `lastUpdatedAt` so the first update is detected correctly.

## Error Handling
No behavioral changes to error handling. If syncing fails, the bar simply stops when `isSyncing` resets.

## Testing
- Add a `TestStore` test for `TabbarLifecycle` to ensure `.enterBackground` resets `syncStatus.lastUpdatedAt` and `isSyncing`.
- Optional: add a snapshot or view test for `ManagerEventsView` if/when snapshot coverage exists for EventsFeature.
