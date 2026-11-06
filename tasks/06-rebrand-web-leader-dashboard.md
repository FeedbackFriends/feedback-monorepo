---
status: draft
areas: [web, backend]
created: 2026-11-06
updated: 2026-11-06
---

# Rebrand 06 — Web leader dashboard

## Problem and outcome

The web app becomes the leader's only workspace. Section 10 of `lets-grow-strategi-teamtrivsel.md` says the leader must quickly see four things:

- new suggestions
- themes with support
- decisions that still need an answer
- trials that need follow-up

The company overview must show process and results without becoming a tool for monitoring individual employees.

Outcome: a data-driven `/dashboard` replaces the static meeting-era pages (Profil, Sessions, "Fra møde til feedback", Spørgeskemaer). Leaders get timely signals about work that needs their attention.

## Rebrand series

Depends on **02–05**. It can be built incrementally as each lands. It must reach parity before task 07 (phase 2) removes the iOS manager features. The coming-soon landing page (01) is implemented; product direction is documented in [the rebrand strategy](../lets-grow-strategi-teamtrivsel.md).

## Scope

- In scope:
  - **Dashboard overview.** Four cards: new suggestions, most supported, awaiting a decision (with age), and trials due for follow-up.
  - **Navigation.** Rebuild the dashboard navigation in `web/src/components/auth/dashboard-nav.ts` around Overblik, Forslag, Det arbejder vi på, Resultater/historik, and Team.
  - **Process metrics.** The strategy's metrics from section 12:
    - share of suggestions with a decision and explanation
    - time to first meaningful response
    - share of trials with completed follow-up
  - **Leader notifications.** Email digest or web notifications for new suggestions and due follow-ups. The mechanism is to be decided.
  - **Responsive layout.** The leader UI must work on mobile web (see `web-mobile-navigation.md`).
- Out of scope:
  - A company or HR overview. Task 11 covers this.
  - English on web. Task 12 covers this.
  - Advanced reporting, exports, and integrations. The strategy defers these.

## Context

- Current behavior:
  - `/dashboard/*` lives in `web/src/app/dashboard/` and `web/src/components/auth/DashboardShell.tsx`. It is static copy plus Firebase user info.
  - `/dashboard/sessions`, `/dashboard/how-it-works`, and `/dashboard/surveys` describe the meeting and calendar model.
  - The backend has no outbound email. Push exists for iOS only.
- Reading path:
  - `web/AGENTS.md`
  - `web/docs/agents/architecture.md`, `ui.md`, `api-and-auth.md`, and `validation.md`
  - Strategy sections 10 and 12
- State/API flow and prerequisites:
  - The endpoints from 02–05.
  - A new aggregate endpoint for dashboard counts, if needed.

## Decisions and open questions

- Confirmed:
  - Web is for leaders only.
  - The UI is Danish-only for now (user, 2026-11-06).
- Assumptions:
  - Process metrics are team-level only, and no per-employee figures exist anywhere.
- Unresolved:
  - **Leader notification channel.** The options are a new outbound email integration, web push, or in-app indicators only.
  - **Response expectations.** Decide on a response expectation, such as "svar inden X dage", that drives "awaiting decision" highlighting. The strategy says to agree on this at onboarding.

## Acceptance criteria

- [ ] AC-1: A leader with team data sees the four overview cards with correct counts and links into the detail views.
- [ ] AC-2: The legacy meeting pages are removed from navigation and redirected or deleted.
- [ ] AC-3: The process metrics display for the team, and no individual employee data is shown.
- [ ] AC-4: The leader is notified of new suggestions and due follow-ups through the agreed channel.
- [ ] AC-5: The dashboard is usable at phone width.

## Implementation plan

### Phase 1 — Overview and navigation

- [ ] Rebuild the dashboard shell navigation and the overview page, with an aggregate endpoint if needed. Remove or redirect Sessions, How-it-works, and Surveys.

### Phase 2 — Metrics

- [ ] Add a backend metrics query and a web metrics section with empty states.

### Phase 3 — Leader notifications

- [ ] Implement the agreed channel, with scheduler jobs for digests or due reminders.

Verification for every phase: `npm run lint`, `npm run build`, Playwright journeys for each page with E2E auth and seeded data, and a responsive check at 390 px.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1 | Seeded team with suggestions and trials | Open `/dashboard` | Correct counts and links |
| AC-2 | Signed-in leader | Visit `/dashboard/sessions` | Redirected, or not found |
| AC-3 | Seeded history | Open metrics | Correct team ratios, and no names or IDs |
| AC-4 | New suggestion; trial due | Run the notification job | The leader receives the notification |
| AC-5 | Playwright mobile viewport | Navigate all pages | No horizontal scroll, and navigation works |

## Human review

Not implemented yet.

## Handoff

- Completed: None.
- Verification results: Not run.
- Blockers: Tasks 02–05, and the notification channel decision.
- Next action: After 03 lands, start phase 1 with the suggestions card, and extend as 04 and 05 land.
