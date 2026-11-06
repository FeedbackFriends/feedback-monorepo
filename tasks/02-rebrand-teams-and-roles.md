---
status: ready
areas: [backend, web, ios]
created: 2026-11-06
updated: 2026-11-06
---

# Rebrand 02 — Teams, server-owned roles, and the platform split

**Priority: first product task, after or alongside 01.** Every later product task depends on a team entity and on roles the server controls. Neither exists today.

## Problem and outcome

LetsGrow is pivoting from "feedback after meetings" to "employee-driven improvements". The source is the strategy in `lets-grow-strategi-teamtrivsel.md`, "Fra feedback til forbedring". In the new model, employees belong to a fixed team. They suggest improvements anonymously, vote, and follow decisions in the **iOS app**. Leaders run the team from the **web app**.

Today all data hangs off a single manager account (manager → activity → event → question/feedback). There is no team or organization. A client can also give itself the `Manager` role: `POST /account` takes `requestedRole` and sets the Firebase custom claim with no authorization check.

Outcome:

- A leader signs in on web and creates their organization and team.
- The leader shares one team invite link.
- An employee opens the link in the iOS app and requests to join.
- The leader approves the request on web, and the employee becomes a team member.
- The server alone decides who is a leader and who is an employee. A client can no longer request a privileged role.

## Rebrand series

This is the first backend and app task. It can run in parallel with 01, the coming-soon landing page. See `01-rebrand-landing-coming-soon.md` for the series map.

## Scope

- In scope:
  - **Backend model.** Organization, team, and team membership, with roles for leader and employee.
  - **Server-owned roles.** `requestedRole` stops being trusted. A user becomes a leader by creating an organization on web, or later by being promoted by another leader. A user becomes an employee when a leader approves their join request.
  - **Team invites.** One shared, server-generated invite link (with code) per team, which a leader can rotate.
  - **Join request.** Opening the link creates a pending join request. Repeating it is idempotent. A pending member has no access to team content.
  - **Leader approval.** The leader sees pending requests on web and approves or rejects them.
  - **Web leader onboarding.** Google sign-in, create organization and team, see and copy or share the invite link, approve or reject pending requests, see the member count, and remove members.
  - **Web invite landing.** Rework `/invite/[id]` so it opens the iOS app for a team invite.
  - **iOS employee join.** A deep link or code entry sends a join request. The app shows a waiting state until approval, then the team name.
  - **Authorization helpers.** Team-scoped checks such as "is leader of team" and "is member of team", for later tasks to use.
- Out of scope:
  - Suggestions, votes, decisions, trials, and dashboards. Tasks 03–06 cover these.
  - Removing the iOS manager features. Task 07 covers this.
  - Deleting activities, events, PINs, and the mail listener. Task 09 covers this.
  - Visual rebrand and marketing copy. Task 08 covers this.
  - Personal email invites.
  - An HR or director role. Task 11 covers this.
  - English on web. Task 12 covers this.

## Context

- Current behavior:
  - Role enum `backend/lib/model/src/main/kotlin/dk/example/feedback/model/enumerations/Role.kt` has only `Manager`. The role comes from a Firebase custom claim and is mapped to an authority in `backend/apps/api/src/main/kotlin/dk/example/feedback/config/SecurityConfig.kt`.
  - `backend/apps/api/src/main/kotlin/dk/example/feedback/controller/AccountController.kt` (around line 40) calls `firebaseService.setRole(...)` with the client-supplied role. The call lands in `backend/lib/firebase/.../FirebaseServiceImpl.kt` (around line 109).
  - `service/AuthorizationService.kt` offers only `requireSelf`, `requireActivityManager`, and `requireEventManager`.
  - Participants are Firebase anonymous users. The account row has no name or email (`service/AccountService.kt`).
  - Invitations exist only for activities (`activity_invite`, `EventRepo.joinInvitedEventsForEmail`).
  - `GET /bootstrap` returns role, account, participant events, and, for managers, activities and analytics.
  - iOS:
    - `ios-app/Modules/Sources/RootFeature/RootFeature.swift` signs in anonymously and calls `createAccount(nil)`.
    - Apple/Google sign-in links the credential and calls `createAccount(.manager)`.
    - `Domain/Models/Role.swift` has only `manager`, and `nil` means anonymous.
    - Deep link `letsgrow://invite?pin_code=…` is parsed in `Domain/Deeplink/Deeplink.swift`. The app has no universal links.
  - Web:
    - Google sign-in through Firebase (`web/src/lib/auth/`, `web/src/components/auth/`).
    - The dashboard pages are static, and no page calls the backend yet. `web/src/lib/api/client.ts` exists but is unused by pages.
    - `web/src/app/invite/[id]/page.tsx` shows a PIN and an App Store link.
- Reading path:
  - Strategy: `lets-grow-strategi-teamtrivsel.md`, sections 3, 10, and 11.
  - Backend guidance: `backend/AGENTS.md`, `backend/docs/agents/persistence.md`, `backend/docs/agents/architecture.md`.
  - Contract guidance: `docs/agents/api-contract.md`.
  - Web guidance: `web/AGENTS.md`, `web/docs/agents/api-and-auth.md`.
  - iOS guidance: `ios-app/AGENTS.md`, `ios-app/Docs/agents/feature-workflow.md`.
  - Liquibase changelog: `backend/lib/persistence/src/main/resources/db/changelog/db.changelog-master.yaml`. The latest changeset is 0026.
- State/API flow and prerequisites:
  - Backend source → `./scripts/generate-api-artifacts.sh` → web and iOS consumers.
  - Web must start calling the backend with the Firebase ID token for the first time.

## Decisions and open questions

- Confirmed:
  - The iOS app is for employees only, and the web app is for leaders only (user, 2026-11-06).
  - The improvement loop is Foreslå → Stem → Beslut → Afprøv → Følg op (strategy).
  - **Invites (user, 2026-11-06).** One shared team link, and the leader approves each join request afterwards. No email invites.
  - **Roles (user, 2026-11-06).** Only team leaders and employees for now. An HR overview role comes later as a low-priority task (`11-rebrand-hr-overview.md`).
  - **Removed employees (user, 2026-11-06).** Their suggestions and votes stay as they are. Removal only deletes the membership, so they lose access. Do not add special handling such as re-counting votes, hiding content, or reassigning authorship. Keep it simple to maintain.
  - **Web language (user, 2026-11-06).** The leader UI stays Danish-only for now. Switching between Danish and English on web is a low-priority task (`12-rebrand-web-language-switch.md`).
  - The launch covers iOS and web only. Employees take part through iOS only, and there is no web participation path for employees. An Android app is a separate future task with very low priority (`10-rebrand-android-app.md`) (user, 2026-11-06).
- Assumptions:
  - **Hierarchy.** The MVP hierarchy is organization → team(s), so task 11 can add an HR overview later without a migration. A leader belongs to one organization and may lead one or more teams. An employee belongs to one team.
  - **Rejoining.** A removed employee can request to join again through the link, and the leader must approve them again. A rejected request can be repeated. No ban list.
  - **Role storage.** Roles are stored in the database (membership role) as the source of truth. The Firebase claim is either derived from the database or dropped in favor of database lookups per request.
  - **Leader accounts.** Leaders use Google sign-in on web. Employees keep Firebase anonymous auth on iOS so their identity stays minimal. Account linking on iOS stays optional for device changes, but it never grants the leader role.
  - **Legacy compatibility.** Existing `Manager` accounts keep working through the legacy activity/event endpoints until task 09. New iOS sign-ins never receive `Manager`. The iOS Apple/Google sign-in screen stops requesting `.manager` in this task. Existing manager sessions keep their claim.
- Unresolved: None. The choice between team context in bootstrap and a dedicated `GET /me` is an implementation decision. Explain it in the human review.
- Execution constraints:
  - No production data mutation, deployment, or `./scripts/run` volume reset is authorized by this plan.
  - Do not commit or push unless asked.

## Acceptance criteria

- [ ] AC-1: `POST /account` (or its replacement) no longer grants any role from client input. A client that requests `Manager` does not receive it.
- [ ] AC-2: A signed-in web user can create an organization and team and becomes that team's leader, enforced by the server.
- [ ] AC-3: The leader sees the invite link on web and can rotate it. Rotating invalidates the old link.
- [ ] AC-4: An iOS user who opens the invite link or enters the code gets a pending join request and a waiting state. Repeating it does not create a duplicate. An invalid or rotated code shows a clear error.
- [ ] AC-8: The leader sees pending requests on web and approves or rejects them. Only approved members can access team content. A rejected user sees a clear message.
- [ ] AC-5: The leader can see the member count and remove a member. The removed member loses team access, and their earlier content stays unchanged.
- [ ] AC-6: Team-scoped authorization rejects non-members and non-leaders on every new endpoint, and API tests cover it.
- [ ] AC-7: Existing manager accounts can still use the legacy activity and event flows until task 09. New iOS users never become managers.

## Implementation plan

### Phase 1 — Backend: organization, team, membership, and roles

Outcome: persisted teams and server-owned roles. Dependencies: none.

- [ ] Add an incremental Liquibase changeset with `organization`, `team`, `team_membership` (account, team, role, status pending/active, requested_at, approved_at), and `team_invite` (code, team, created_by, revoked_at). Rejecting or removing deletes the membership row.
- [ ] Add tables, DAOs, repos, and services following existing patterns in `backend/lib/persistence` and `backend/apps/api`.
- [ ] Replace client-requested roles in `AccountController`/`AccountService`. Keep existing `Manager` claims readable for the legacy flows.
- [ ] Add team-scoped checks to `AuthorizationService`.
- [ ] Add endpoints: create organization and team, get my teams and memberships, rotate invite, request to join by code, list pending requests, approve, reject, list member count, and remove member.
- [ ] Add team context to bootstrap for iOS, or add a dedicated `GET /me` for web. Choose one and explain the choice in the human review.
- [ ] Verification: API and persistence tests for role escalation (AC-1), join-request idempotency, rotated codes, pending members denied access, approval and rejection, and non-member and non-leader rejection.

### Phase 2 — Contract and web leader onboarding

Outcome: a leader can set up a team on web. Depends on phase 1.

- [ ] Run `./scripts/generate-api-artifacts.sh`. Never hand-edit the generated files.
- [ ] Wire authenticated backend calls from web through `web/src/lib/api/client.ts` with the Firebase ID token.
- [ ] Add a first-run flow (create organization and team) and a team page (invite link with copy and share, rotate, pending requests with approve and reject, member count, remove).
- [ ] Rework `/invite/[id]` for team invites: open the app through the deep link, with an App Store fallback.
- [ ] Verification: `npm run lint`, `npm run build`, and Playwright journeys for first-run setup and the invite page with E2E auth.

### Phase 3 — iOS employee join

Outcome: an employee joins a team from iOS. Depends on phase 2.

- [ ] Add a team-invite deep link case next to the PIN case in `Deeplink.swift`, and a code entry for joining a team.
- [ ] Add Domain models for team and membership, and a live adapter. Generated types stay out of feature state.
- [ ] Stop requesting `.manager` on iOS sign-in, and remove the "Opret dig og få feedback på dine egne aktiviteter" manager sign-up promise.
- [ ] Define what the `.activities` tab shows for non-managers after this change. Today it shows `SignUpView`, which would loop, because sign-in no longer grants the manager role. Replace it with a "Ledere bruger LetsGrow på web" message that links to the web app, or hide the tab. Existing manager sessions keep the activities UI until task 07.
- [ ] Show a waiting-for-approval state, then the joined team name. Show a clear message when rejected and a clear error for invalid codes. Add the strings to `AppStrings.xcstrings` in Danish and English.
- [ ] Verification: reducer tests for the join request, the waiting state, approval, rejection, the invalid-code error, and idempotent repeats. Add catalog fixtures for the new screens.

### Phase 4 — End-to-end verification

- [ ] Create a team on web, request to join from the iOS simulator through the invite link, approve it on web, and confirm the iOS app shows the team. Confirm that removing the member blocks access.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1 | API test context | Create an account with `requestedRole=Manager` | No Manager role is granted, and the account has no leader membership |
| AC-2 | Web E2E auth | Complete the first-run setup | The team exists, and the user is its leader on the server |
| AC-3 | Leader with a team | Rotate the invite, then request with the old code | The old code is rejected, and the new code works |
| AC-4 | iOS simulator, local stack | Open the invite deep link twice, then try an invalid code | One pending request and a waiting state; the invalid code shows an error |
| AC-5 | Team with a member | The leader removes the member | Member calls to team endpoints return 403, and their content is unchanged |
| AC-6 | API tests | Call each new endpoint as a non-member and as a non-leader | The calls are rejected |
| AC-7 | Seeded legacy manager | Use the existing activity and event endpoints | They are unchanged |
| AC-8 | Pending request | Call team endpoints while pending, then approve, then call again; separately reject | Pending gets 403, approved gets access, rejected sees a message |

## Human review

Not implemented yet. Implementation will record the change and flow, the architectural decisions and tradeoffs, a linked reading path, and verification limits here.

## Handoff

- Completed: None.
- Verification results: Not run.
- Blockers: None.
- Next action: Start phase 1 with the Liquibase changeset and the `requestedRole` fix (`$lg-implement tasks/02-rebrand-teams-and-roles.md`).
