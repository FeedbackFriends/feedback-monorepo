---
status: draft
areas: [ios]
created: 2026-11-06
updated: 2026-11-08
---

# iOS as the employee-only app

## Problem and outcome

The iOS app today mixes two users:

- the anonymous participant, who enters a PIN and gives meeting feedback
- the manager, who works in the whole `ActivityFeature`: activities, sessions, questions, insights, and invites

After the rebrand, iOS is only for employees. Per section 10 of `lets-grow-strategi-teamtrivsel.md`, the home screen answers three questions: what can I suggest, which ideas can I support, and what is happening with the improvements we are working on.

Outcome: a reworked root and tab structure with four areas:

- **Forslag**: suggest and support
- **Det arbejder vi på**: active trials
- **Resultater**: history
- **Dit input**: open evaluations and the confidential message entry

Every manager surface is removed. The PIN and meeting feedback entry is retired together with 09.

## Rebrand series (historical IDs)

The numeric references in this section and older planning notes are original rebrand IDs, not current backlog priorities. Current priority is the filename prefix. Rebrand 01 (coming-soon landing page) and 02 (teams/memberships) are already completed.

Depends on **02–05** for the features. The manager removal must wait until **06** gives leaders parity on web. The coming-soon landing page (01) is implemented; product direction is documented in [the rebrand strategy](../docs/product/lets-grow-strategi-teamtrivsel.md).

## Scope

- In scope:
  - **Tabs and root.** New tab and root structure, with the team join state from 02 for users who are not yet members.
  - **Manager removal.** Remove the manager UI and state:
    - `ActivityFeature`, except anything reused
    - the manager branches in `TabbarFeature` (`managerUnseenResponses` badge, sync indicator, `validateSelectedTab`, manager notification prompt)
    - the `FEEDBACK_RECEIVED` and `.managerEvent` deep links
    - the `Role.manager` paths
    - the sign-up screen copy "Dine aktiviteter"
  - **Notification permission.** Show the prompt to employees, since they now receive status and evaluation pushes.
  - **Clean-up.** Remove dead modules, fixtures, snapshot screens, and baselines. Update `screen-catalog.json` and `Docs/screenshots/catalog/`.
  - **Tooling.** Update the Maestro flows under `.maestro/`, which are manager-centric. Fix the stale `EventsFeature` references in `PreviewApps/` and `AppMock/`.
  - **Localization.** Clean up orphaned keys in `AppStrings.xcstrings` and APNs keys in `Localizable.xcstrings`.
- Out of scope:
  - Visual identity, such as the icon, colors, and App Store copy. Task 08 covers these.
  - Backend endpoint removal. Task 09 covers this.

## Context

- Priority: 07 of 25. Deliver the employee experience; manager removal waits for web parity.

- Current behavior:
  - Tabs in `ios-app/Modules/Sources/TabbarFeature/TabbarView.swift`. The `.feedback` tab shows `EnterCodeView`. The `.activities` tab shows `ActivityListView` for managers and `SignUpView` otherwise.
  - Role and session state: `Domain/Models/Role.swift`, `Bootstrap.account`, and `managerData`.
  - Tests:
    - `Modules/Tests/AppTests/FocusFeature/*` for ActivityDetail, EventDetail, ManageActivity, ManageEvent, ManagerEvents, and UnseenResponseBadge
    - `ScreenSnapshotTests` with 38 Activity catalog screens
- Reading path:
  - `ios-app/AGENTS.md` and `ios-app/Docs/agents/feature-workflow.md`
  - `ios-app/Docs/localization.md`
  - `docs/agents/ios-workflows.md`
- Existing tasks affected by this rebrand. Review them before starting, and do not delete them without the user's confirmation:
  - `16-ios-manager-events-sync-bar.md`, `15-ios-answer-type-picker-and-icons.md`, and `25-shared-ios-maestro-e2e.md`, whose flows are manager-centric.
  - Possibly `14-ios-confirmation-polish.md` and `12-ios-profile-and-navigation-polish.md`.

## Decisions and open questions

- Confirmed: iOS is for employees only.
- Assumptions:
  - Reuse the decoupled answer components and DesignSystem from the current feedback flow.
  - The current localization branch (`feat/ios-danish-english-localization`) merges before this work begins.
- Unresolved:
  - Decide whether meeting PIN feedback stays as an employee feature, or is fully retired with 09.
  - Decide whether existing managers who sign in on iOS are told to move to web with a message and a link.

## Acceptance criteria

- [ ] AC-1: A new user is prompted to join a team. After joining, they see the four areas.
- [ ] AC-2: No manager UI, state, deep link, or strings remain in the app. Build and lint pass with the removed modules.
- [ ] AC-3: The snapshot catalog and baselines match the new screens, with no stale manager baselines.
- [ ] AC-4: Employees receive the notification permission prompt at a meaningful moment, and pushes from 04 and 05 route correctly.
- [ ] AC-5: All new strings exist in Danish and English, and the localization validators pass.
- [ ] AC-6: A user with a legacy manager account sees the agreed message and is not stuck.

## Implementation plan

### Phase 1 — New employee shell

- [ ] Add the tabs and root for the four areas, wired to features from 03–05. Show the joined team in the profile.

### Phase 2 — Manager removal

- [ ] Delete the manager modules and branches, tests, fixtures, deep links, and strings. Update `Modules/Package.swift`, root `Package.swift`, `PreviewApps`, and `AppMock`.

### Phase 3 — Catalog, E2E, and verification

- [ ] Regenerate and review the screen catalog, and update the Maestro flows.
- [ ] Run the unit and snapshot test plans and the localization validators. Run a live simulator journey covering join → suggest → support → see status.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1 | Fresh simulator, local stack | Launch, then join with a code | The four-area home appears |
| AC-2 | Repository | Build, lint, and search for `manager`/`Activity` in Sources | Clean build, and only intentional matches remain |
| AC-3 | Snapshot plan | Run the catalog review | All baselines are current |
| AC-4 | Device or simulator push test | Change a suggestion's status | The push opens the suggestion |
| AC-5 | Scripts | Run `validate-localization.py` and `check-localized-copy.py` | Both pass |
| AC-6 | Seeded legacy manager | Sign in | The message is shown, and the app is not broken |

## Human review

Not implemented yet.

## Handoff

- Completed: None.
- Verification results: Not run.
- Blockers: Tasks 02–06.
- Next action: Phase 1 can start once 03 lands. Phase 2 waits for 06 to reach parity.
