---
status: draft
areas: [backend, web, ios]
created: 2026-11-06
updated: 2026-11-06
---

# Rebrand 09 — Retire the meeting-feedback model

## Problem and outcome

Once leaders work on web (06) and employees work in the new iOS app (07), the meeting-feedback mechanism is dead weight. That covers activities, events, PIN codes, event questions and answer types, event feedback, the inbound Zoho mail poller, calendar invite parsing, and manager push.

Outcome: the backend, contract, web, and iOS contain only the improvement-loop model, and existing data is handled by an agreed migration.

## Rebrand series

Last in the series. Depends on **06** and **07**. The coming-soon landing page (01) is implemented; product direction is documented in [the rebrand strategy](../lets-grow-strategi-teamtrivsel.md).

## Scope

- In scope:
  - **Endpoints.** Remove the activity, event, PIN-join, feedback start/submit, notification-history, and legacy bootstrap fields, along with their services, DTOs, and mappings.
  - **Tables.** Drop the legacy tables through an incremental Liquibase changeset, after the data decision: `activity`, `activity_invite`, `event`, `event_participant`, `pin_code`, `question`, `feedback`, `new_feedback_notification`, `notification_history`, `mail_listener_state`, and `zoho_processed_message`.
  - **Scheduler and mail.** Remove `cleanUpPinsScheduler`, the feedback push scheduler, the `ZohoMailPollingService`, `ZohoMailClient`, the `lib/ical-parser` module, and the related config and env vars.
  - **Roles.** Remove the legacy `Manager` role and claim handling that 02 left for compatibility.
  - **Admin seeds.** Update the admin seed endpoints to seed teams, suggestions, and trials instead.
  - **Contract.** Regenerate and clean up the consumers on web and iOS.
  - **Docs.** Update runtime and deployment env docs: drop the Zoho variables and update `docs/agents/runtime-and-deployment.md`.
- Out of scope:
  - The support submission feature (product feedback and bug reports) stays.

## Context

- Current behavior:
  - Legacy tables in `backend/lib/persistence/.../table/`.
  - Changesets up to 0026 in `backend/lib/persistence/src/main/resources/db/changelog/`. Changeset 0025 reset pre-launch data, but App Store version 1.1.2 is live, so real data may exist now.
  - Scheduler jobs in `backend/apps/scheduler/.../service/ScheduleService.kt`.
  - Mail code in `ZohoMailPollingService.kt`, `mail/ZohoMailClient.kt`, and `lib/ical-parser/.../CalendarInviteParser.kt`.
  - The email address `NNNN@letsgrow.dk` is built in `ActivityMappings.kt`.
- Reading path:
  - `backend/docs/agents/persistence.md`
  - `docs/agents/api-contract.md`
  - `docs/agents/runtime-and-deployment.md`
  - `docs/agents/ci-cd.md`

## Decisions and open questions

- Confirmed: None.
- Assumptions:
  - The meeting-feedback model is fully replaced by the improvement loop. This depends on the open PIN-feedback question in `07-rebrand-ios-employee-app.md`.
  - Old iOS app versions in the field will break against removed endpoints. A minimum supported version or forced update message is needed before removal.
- Unresolved:
  - **Data handling.** Decide between export and archive, migration of anything useful, or deletion of legacy production data. Decide whether users must be informed under GDPR.
  - **Compatibility.** Decide whether to add a forced-update mechanism for old iOS versions, or a compatibility window.
  - **Deployment.** Decide the timing and rollback plan. Production changes need explicit authorization.

## Acceptance criteria

- [ ] AC-1: No legacy endpoints remain in `contracts/openapi/feedback-api.yaml`, and the web and iOS consumers compile without them.
- [ ] AC-2: The legacy tables are handled per the agreed data decision through an incremental changeset, and migration tests pass.
- [ ] AC-3: The scheduler and API start without the Zoho and mail configuration, and no legacy jobs run.
- [ ] AC-4: Old app versions get the agreed update experience instead of silent failures.
- [ ] AC-5: The runtime and deployment docs and the environment examples are updated.

## Implementation plan

### Phase 1 — Data and compatibility decision

- [ ] Agree on the data handling and the old-client strategy with the user. Ship the forced-update mechanism in an iOS release first.

### Phase 2 — Backend removal

- [ ] Remove the endpoints, services, scheduler jobs, mail and ical modules, and roles. Add a changeset, and update the admin seeds.

### Phase 3 — Consumers and docs

- [ ] Regenerate the artifacts, remove dead web and iOS code, and update the docs and env examples.

Verification: full backend Gradle tests (warnings fail the build), web lint, build, and E2E, iOS unit and snapshot plans, and a `./scripts/run` stack health check, but only with the user's permission, because it resets volumes.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1 | Regenerated contract | Search the contract for activity, event, or pin | None |
| AC-2 | Migration test DB | Apply the changesets on a copy with legacy data | The data is handled per the decision |
| AC-3 | Local stack | Start without the Zoho env | Services are healthy |
| AC-4 | Old app build | Launch against the new backend | The update prompt is shown |
| AC-5 | Docs | Review | No stale env vars |

## Human review

Not implemented yet.

## Handoff

- Completed: None.
- Verification results: Not run.
- Blockers: Tasks 06 and 07, and the data and compatibility decisions.
- Next action: Settle the data handling for production legacy data with the user.
