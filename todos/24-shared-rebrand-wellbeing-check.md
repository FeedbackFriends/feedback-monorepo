---
status: draft
areas: [backend, ios, web]
created: 2026-11-06
updated: 2026-11-08
---

# Optional team well-being check (future, low priority)

**Priority: low.** This is not part of the first launch (user, 2026-11-06). Build the core improvement loop first (02–07). Start this task only if pilot customers ask for it.

## Problem and outcome

The strategy treats well-being as the result of the product, not the main feature: "Færre målinger. Flere synlige forbedringer." (`lets-grow-strategi-teamtrivsel.md`, sections 1 and 9). It still allows a short, optional well-being check: "Eventuelt månedligt med 2–3 spørgsmål, hvis teamet har et klart formål".

Outcome:

- A leader can turn on a short well-being check for their team.
- Employees answer two or three questions in the iOS app, roughly monthly.
- The leader sees team-level results on web, and only when enough people have answered.
- A low result leads naturally to the improvement loop, for example a prompt to suggest or prioritize an improvement, instead of becoming a dashboard of scores.

## Rebrand series (historical IDs)

The numeric references in this section and older planning notes are original rebrand IDs, not current backlog priorities. Current priority is the filename prefix. Rebrand 01 (coming-soon landing page) and 02 (teams/memberships) are already completed.

Depends on **02** (teams), **03** (anonymity model and thresholds), **06** (web leader dashboard), and **07** (iOS employee app). The coming-soon landing page (01) is implemented; product direction is documented in [the rebrand strategy](../docs/product/lets-grow-strategi-teamtrivsel.md).

## Scope

- In scope:
  - **Opt-in per team.** The check is off by default, and the leader turns it on and off on web.
  - **Fixed questions.** Two or three questions, for example "Hvordan har din arbejdsdag været den seneste måned?". Leaders cannot build their own surveys.
  - **Rhythm.** About monthly, with one push when a check opens. No extra reminders just to get people to open the app (strategy, section 9).
  - **Anonymous answers.** One answer per member per round, enforced on the server without exposing identity. Team results are shown only above the minimum threshold from 03.
  - **Link to the loop.** The results view on web and iOS points to suggestions and trials, for example "Hvad kunne gøre det bedre?".
- Out of scope:
  - Survey builders, custom questions, and benchmarks against other companies.
  - Individual scores or trends per employee.
  - Automatic conclusions about employees.

## Context

- Priority: 24 of 25. Keep optional measurement behind the improvement loop and evidence of pilot demand.

- Task 05 builds trial evaluations: one question, anonymous answers, and thresholded aggregates. Reuse that answer model and its components where possible, instead of a second survey system.
- The old event-scoped feedback model is removed in 09, so do not build on it.
- Reading path: strategy sections 1, 9, 11, and 15 ("Surveytræthed", meaning survey fatigue).

## Decisions and open questions

- Confirmed (user, 2026-11-06):
  - Low priority, and not in the first launch.
  - Results are team-level only, and the check stays a supporting feature.
- Assumptions:
  - The check reuses the evaluation answer components and anonymity rules from 03 and 05.
- Unresolved:
  - The exact questions and the answer scale.
  - Whether the rhythm is fixed (monthly) or chosen by the leader.
  - Whether results are shown to employees too, or only to the leader.
- Execution constraints: none until the task is prioritized.

## Acceptance criteria

- [ ] AC-1: A leader turns the check on and off for a team, and it is off by default.
- [ ] AC-2: When a round opens, members get one push and can answer once in the iOS app.
- [ ] AC-3: The leader sees team-level results only above the minimum threshold, and no individual answers are ever exposed.
- [ ] AC-4: The results view links to the suggestion and trial flow.

## Implementation plan

- [ ] Refine when prioritized.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1 | Leader with a team | Toggle the check | No rounds while off; a round opens when on |
| AC-2 | Open round | A member answers twice | One answer is stored |
| AC-3 | Team below and above the threshold | Open the results | Hidden below the threshold; aggregates only above it |
| AC-4 | Results view | Follow the link | Opens the suggestion flow |

## Human review

Not implemented yet.

## Handoff

- Completed: None.
- Verification results: Not run.
- Blockers: Deferred until the core loop has shipped and pilots ask for it.
- Next action: None until prioritized. Then run `$lg-refine todos/24-shared-rebrand-wellbeing-check.md`.
