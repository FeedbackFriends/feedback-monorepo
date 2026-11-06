---
status: draft
areas: [android]
created: 2026-11-06
updated: 2026-11-06
---

# Rebrand 10 — Android employee app (future, very low priority)

**Priority: very low.** Do not start until the iOS and web rebrand (tasks 01–09) has shipped and pilots show a need. The launch covers iOS and web only.

## Problem and outcome

Employees without an iPhone cannot take part in the improvement loop. Section 11 of `lets-grow-strategi-teamtrivsel.md` says companies must be able to include the whole team.

Outcome: an Android app gives employees the same experience as the iOS employee app:

- join a team
- suggest and support improvements
- follow decisions and trials
- answer evaluations
- receive pushes

## Rebrand series

This task follows the series and depends on **02–07**, which define the employee feature set and the API. See `01-rebrand-landing-coming-soon.md` for the series map.

## Scope

- In scope:
  - **Feature parity.** An Android client matching the iOS employee feature set at the time this task starts.
  - **Shared contract.** It uses the shared OpenAPI contract and Firebase auth (anonymous employees).
  - **Push.** FCM push for Android. Today the backend builds APNs-only payloads in `backend/lib/firebase/.../FirebaseServiceImpl.kt`.
  - **Store listing.** A Play Store listing.
- Out of scope:
  - Any leader functionality. Leaders use web only.
  - A web participation path for employees. The user decided against it on 2026-11-06.

## Context

- Current behavior:
  - The repository has no Android code. The `areas` list in the task template has no `android` value yet.
  - `scripts/generate-api-artifacts.sh` generates only TypeScript and Swift clients.
  - Push localization keys live in the iOS string catalogs.
- Reading path:
  - `docs/agents/api-contract.md`
  - `docs/agents/repository-scope.md`
  - `ios-app/` as the reference for the employee feature set after task 07

## Decisions and open questions

- Confirmed:
  - The app is for employees only.
  - It is deferred until after the iOS and web launch (user, 2026-11-06).
- Assumptions: None.
- Unresolved:
  - **Technology.** Choose between native Kotlin/Compose, Kotlin Multiplatform shared with the backend models, or a cross-platform framework.
  - **Repository layout.** Decide where the app lives, for example `android-app/`. Update the root `AGENTS.md`, the repository scope, and the area list.
  - **Push localization.** Decide how push localization works across platforms. Today the keys are iOS-only.
- Execution constraints: none until the task is prioritized.

## Acceptance criteria

- [ ] AC-1: An Android employee can join a team and complete the full loop, the same as on iOS: suggest, support, see the status, and evaluate a trial.
- [ ] AC-2: Android devices receive status and evaluation pushes and route to the right screen.
- [ ] AC-3: The Android client is generated from the shared contract through the root generation script.

## Implementation plan

- [ ] Refine when prioritized: the technology choice, the repository layout, and the push payload changes.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1 | Android emulator, local stack, a team from task 02 | Run through the full loop | Same results as iOS |
| AC-2 | Device or emulator with FCM | Change a suggestion's status | The push arrives and opens the suggestion |
| AC-3 | Repository | Run `./scripts/generate-api-artifacts.sh` | The Android client is regenerated |

## Human review

Not implemented yet.

## Handoff

- Completed: None.
- Verification results: Not run.
- Blockers: Deferred until after the iOS and web rebrand ships.
- Next action: None until prioritized. Then run `$lg-refine tasks/10-rebrand-android-app.md`.
