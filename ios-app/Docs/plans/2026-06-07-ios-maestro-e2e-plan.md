# iOS Maestro E2E Plan

Date: 2026-06-07

## Goal

Build a reliable Maestro end-to-end suite for the iOS app against the local Docker backend.

The suite should prove the LetsGrow product loop from a user's perspective:

1. A manager creates an Activity.
2. The manager creates an Event for that Activity.
3. A participant gives feedback for the Event.
4. The manager sees the resulting feedback.
5. Manager-owned Activity and Event data can be edited and deleted.

## Test Strategy

Use this operating rule:

> Reset backend state, seed deterministic data, clear app state, and test the target behavior through the UI.

The tests should not create every prerequisite through the UI. UI setup is only appropriate when the setup itself is the behavior being tested.

## Repository Ownership

The E2E suite spans three surfaces:

- `ios-app/`: Maestro flows, iOS accessibility identifiers, local app configuration, and documentation.
- `backend/`: test admin endpoints, deterministic seed data, and reset behavior.
- root scripts and Docker Compose: local stack startup, health checks, app build/install, and suite orchestration.

The backend remains the source of truth for API shape. If test helpers change the API contract, regenerate artifacts from the root with `./scripts/generate-api-artifacts.sh`.

## Existing Foundation

Already available:

- `./scripts/e2e` starts the local Docker stack, waits for API health, builds `Feedback Localhost`, installs the app, and runs Maestro.
- `ios-app/.maestro/flows/manager-create-activity-event.yaml` covers a first manager flow.
- Backend admin endpoints exist for script-only reset, seed, and login:
  - `POST /admin/reset`
  - `POST /admin/seed-manager-empty`
  - `POST /admin/seed-manager-with-data`
  - `POST /admin/seed-participant-empty`
  - `POST /admin/seed-participant-with-data`
  - `POST /admin/login`
- Local Compose enables test admin endpoints and database reset.
- Backend admin endpoints are hidden from the public/mobile OpenAPI contract.
- The iOS app has launch-argument custom-token login support, but does not call seed/reset/admin endpoints.
- Several Activity and Event screens already expose accessibility identifiers.

## Main Risks

- Flows become slow and brittle if too much state is created through the UI.
- Participant feedback must not accidentally become an account-based flow. Participants should remain account-free where the product supports it.
- Shared seeded state can make delete tests leak into later tests.
- Copy-based selectors will be fragile as Danish UI copy changes.
- Current test terminology mixes Focus, Activity, Event, and Session. Tests should use Activity and Event in filenames and documentation, while accepting existing UI copy where needed.
- Firebase-dependent custom-token login means local E2E still depends on valid Firebase configuration unless a backend test-auth alternative is introduced.

## Target Suite Shape

Preferred structure:

```txt
ios-app/.maestro/
  README.md
  flows/
    debug-auth-seed-manager.yaml
    manager-create-activity-event.yaml
  shared/
    launch-clear.yaml
    login-manager-token.yaml
    login-participant-token.yaml
  flows/
    participant-give-feedback-by-pin.yaml
    manager-sees-feedback.yaml
    manager-edit-activity.yaml
    manager-edit-event.yaml
    manager-delete-event.yaml
    manager-delete-activity.yaml
  scenarios/
    full-feedback-loop.yaml
```

Preferred root command shape:

```bash
./scripts/e2e manager-create-activity-event
./scripts/e2e participant-give-feedback-by-pin
./scripts/e2e full-feedback-loop
./scripts/e2e all
```

Each flow should be runnable in isolation.

## Phase 1: Stabilize The Harness

Deliverables:

- Update `./scripts/e2e` so it can run a named flow, scenario, or all flows.
- Add a reset-and-seed helper that calls backend admin endpoints before each flow.
- Prefer launch-argument custom-token login for most tests.
- Keep one explicit debug-auth UI smoke flow that signs in with an injected token.
- Use `clearState: true` and `clearKeychain: true` for flow isolation.
- Add a consistent screenshot/output location for failed Maestro runs.

Current status:

- `./scripts/e2e` can run named flows, direct paths, scenarios, and `all`.
- `./scripts/e2e-admin` resets and seeds local backend state through admin endpoints.
- `manager-create-activity-event` uses script seed plus E2E launch-argument token login.
- `debug-auth-seed-manager` is the only debug authentication sheet smoke flow, and it uses the injected custom token.
- Maestro debug and output artifacts are routed to `ios-app/.build/maestro/`.

Acceptance criteria:

- One command can run a single named flow.
- A failed flow does not poison the next run.
- Running the same flow twice starts from the same backend and app state.

## Phase 2: Add Stable Selectors

Add accessibility identifiers where Maestro currently has to rely on visible text or fragile hierarchy.

High priority:

- Enter PIN input and submit button.
- Feedback flow next, previous, submit, success overlay, and comment fields.
- Feedback controls for emoji, rating, thumbs, opinion, and comment-only questions.
- Activity row buttons with deterministic identifiers.
- Event row buttons with deterministic identifiers.
- Activity and Event delete confirmation buttons.
- Manager feedback summary, feedback count, rating, and comment rows.

Selector naming should use current domain language:

```txt
activity_list_add_button
activity_form_title_input
activity_form_submit_button
activity_row_<stable-id-or-slug>
event_form_save_button
event_detail_delete_button
feedback_pin_input
feedback_pin_submit_button
feedback_flow_next_button
feedback_flow_submit_button
feedback_success_overlay
```

Existing IDs do not need to be renamed immediately if that creates churn. New IDs should use Activity/Event terminology.

## Phase 3: Prove The Full Product Loop

Start with one high-value scenario:

```txt
reset backend
seed manager empty
login manager
create Activity
create Event
capture or read Event PIN/invite
clear app state
enter PIN as participant
submit feedback
clear app state
login manager
open Activity/Event
verify feedback is visible
```

This scenario validates the core LetsGrow loop:

- manager setup works
- Event feedback entry works
- feedback submission reaches the backend
- manager-visible feedback updates correctly

Acceptance criteria:

- The scenario runs through Maestro against local Docker.
- The manager sees feedback submitted earlier in the same scenario.
- The flow does not depend on random generated data.

## Phase 4: Add Manager CRUD Coverage

Add independent flows:

- `manager-create-activity-event.yaml`
- `manager-edit-activity.yaml`
- `manager-edit-event.yaml`
- `manager-delete-event.yaml`
- `manager-delete-activity.yaml`

Rules:

- Delete flows use throwaway seeded data.
- Edit flows verify persistence after app relaunch.
- Create flows verify both immediate UI update and backend-backed state after relaunch.

## Phase 5: Add Participant Coverage

Add independent participant flows:

- Enter PIN and start feedback.
- Complete all supported feedback question types.
- Submit feedback and verify completion.
- Join Event where appropriate.
- Handle invalid or expired PIN.

Rules:

- Do not require participant account creation unless a specific authenticated participant flow is being tested.
- Keep participant copy assertions focused on meaningful product outcomes.

## Phase 6: CI And Release Integration

Keep local execution first. Once stable:

- Add a small smoke subset to CI.
- Keep the full iOS Maestro suite manual or nightly unless runtime is low enough.
- Document required local and CI prerequisites:
  - simulator runtime
  - Maestro CLI
  - Docker
  - Firebase configuration or test-auth replacement
  - ports and backend URLs

Recommended CI subset:

- manager create Activity/Event
- participant give feedback by PIN
- manager sees feedback

## First Implementation Slice

The first slice should be small:

1. Rename or add a new Maestro flow using Activity/Event terminology. Done in `ios-app/.maestro/flows/manager-create-activity-event.yaml`.
2. Update `./scripts/e2e` to run a supplied flow path/name. Done for named flows, direct paths, scenarios, and `all`.
3. Add backend reset/seed and token auto-login for normal flows. Done through `./scripts/e2e-admin` and Maestro `launchApp.arguments`.
4. Keep debug authentication in a dedicated smoke flow. Done in `ios-app/.maestro/flows/debug-auth-seed-manager.yaml`.
5. Add missing selectors for the feedback PIN entry and feedback submit path.
6. Create a `full-feedback-loop` scenario that proves manager setup, participant feedback, and manager visibility.

Do not start with all CRUD flows. The full feedback loop is the highest-value confidence test.

## Open Decisions

- Should E2E use real Firebase custom-token login, or should we introduce a stricter local-only test-auth mode?
- Should backend seed endpoints return stable Event PINs and entity IDs for Maestro, or should flows discover them through the UI?
- Should reset happen before every flow, before every scenario, or both?
- Should delete tests run in the default local suite, or only in an explicit destructive suite?
- Should the product-visible term be Activity/Event everywhere, or should tests keep matching existing user-facing Session copy?
