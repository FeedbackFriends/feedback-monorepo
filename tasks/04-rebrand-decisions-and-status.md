---
status: draft
areas: [backend, web, ios]
created: 2026-11-06
updated: 2026-11-06
---

# Rebrand 04 — Leader decisions and suggestion status

## Problem and outcome

Step 3 of the strategy is "Beslut og begrund" (decide and justify), in section 6.3 of `lets-grow-strategi-teamtrivsel.md`. Every suggestion needs an understandable status and an answer, including "no" or "not now".

Outcome:

- On web, the leader sets a suggestion's status, writes a justification, and names a responsible person and a date when the team will hear more.
- Employees see the status and the answer on iOS. They get a short push notification when something relevant changes.

## Rebrand series

Depends on **03**. Feeds 05 (trials), 06, and 07. The coming-soon landing page (01) is implemented; product direction is documented in [the rebrand strategy](../docs/product/lets-grow-strategi-teamtrivsel.md).

## Scope

- In scope:
  - The status model from the strategy:
    - Modtaget (received)
    - Under vurdering (under review)
    - Planlagt til afprøvning (planned for a trial)
    - Afprøves (being trialled)
    - Afsluttet med resultat (closed with a result)
    - Ikke nu / gennemføres ikke (not now / will not be done), which requires a justification
  - A decision record on each status change, with justification text, the responsible person, the next-update date, and a timestamp.
  - A status history per suggestion.
  - A web leader action to change status and write the decision.
  - An iOS status display and decision history on a suggestion.
  - A push to the team's employees on a status change. It goes only on relevant changes, never as a reminder to open the app (strategy, section 9).
- Out of scope:
  - Trial setup details (05).
  - Leader-side notifications (06).
  - Response-time service-level targets and reporting (06).

## Context

- Current behavior:
  - Push is APNs-only through FCM in `backend/lib/firebase/.../FirebaseServiceImpl.kt`. It uses localization keys that live in iOS `Localization/AppBundleResources/Localizable.xcstrings`.
  - A queue table plus `pushNotificationScheduler` (every 5 s) in `backend/apps/scheduler/.../service/ScheduleService.kt` drives the "feedback received" pushes to managers.
  - iOS `Domain/Deeplink/Deeplink.swift` routes `FEEDBACK_RECEIVED` notifications.
- Reading path:
  - Strategy sections 6.3 and 9.
  - The scheduler and push code above.
  - `ios-app/Docs/NOTIFICATIONS.md`.
- State/API flow and prerequisites:
  - The suggestions from 03.
  - The leader role from 02.

## Decisions and open questions

- Confirmed: the status names and the need for a justification come from the strategy.
- Assumptions:
  - Statuses can move freely, but closing statuses require text.
  - "Planlagt til afprøvning" and "Afprøves" are set automatically when a trial is created or started (05).
  - Push goes to all team members, and the payload carries no identity.
- Unresolved:
  - Decide whether the "responsible person" is a free-text name or a team member reference. Leaders are web users, and employees are anonymous iOS users.
  - Decide whether employees can opt out of status pushes per suggestion, or only those they wrote or supported.
- Execution constraints: same as task 02.

## Acceptance criteria

- [ ] AC-1: The leader changes a status on web, and closing statuses are rejected without a justification.
- [ ] AC-2: Every change is stored in an ordered history with the justification, the responsible person, the next-update date, and a timestamp.
- [ ] AC-3: Employees see the current status, the latest answer, and the history on iOS.
- [ ] AC-4: A status change sends one push to team members, and the push deep-links to the suggestion. Push copy is localized in Danish and English.
- [ ] AC-5: Only the team leader can change status.

## Implementation plan

### Phase 1 — Backend

- [ ] Add a changeset with a status column and a `suggestion_decision` history table. Add services and endpoints with leader authorization.
- [ ] Add a status-change notification queue and scheduler job, following the existing queue → push → history pattern.
- [ ] Verification: API tests for AC-1, AC-2, and AC-5, plus a scheduler test for AC-4.

### Phase 2 — Web and iOS

- [ ] Regenerate the artifacts.
- [ ] Web: a decision dialog or panel on the suggestion detail.
- [ ] iOS: a status badge, an answer, a history view, a new deep-link case, and push strings.
- [ ] Verification: lint, build, and Playwright on web. Reducer tests, deep-link parser tests, and catalog fixtures on iOS.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1 | Suggestion, leader | Set "Gennemføres ikke" without text | Rejected with a validation error |
| AC-2 | Several changes | Read the history | Ordered, with complete fields |
| AC-3 | iOS member | Open the suggestion | The status and answer are shown |
| AC-4 | Device with FCM, or a scheduler test | Change the status | One push arrives, and tapping it opens the suggestion |
| AC-5 | API tests | An employee calls the status endpoint | 403 |

## Human review

Not implemented yet.

## Handoff

- Completed: None.
- Verification results: Not run.
- Blockers: Task 03.
- Next action: After 03, confirm the "responsible person" representation, then implement phase 1.
