---
status: draft
areas: [backend, web, ios]
created: 2026-11-06
updated: 2026-11-06
---

# Rebrand 05 — Improvement trials, evaluation, and history

## Problem and outcome

Steps 4 and 5 of the strategy are "Afprøv en lille forbedring" (try a small improvement) and "Følg op og del resultatet" (follow up and share the result), in sections 6.4 and 6.5 of `lets-grow-strategi-teamtrivsel.md`.

Outcome:

- From a suggestion, the leader creates a bounded trial with:
  - the improvement
  - the concrete change
  - a duration
  - a responsible person
  - a purpose
  - a follow-up date
- At follow-up, employees answer a short evaluation, such as "Har mødefri formiddage gjort din arbejdsdag bedre?", with an optional comment.
- The leader closes the trial with continue, adjust, or stop. The result appears in the team's improvement history.

## Rebrand series

Depends on **04**. Feeds 06 and 07. The coming-soon landing page (01) is implemented; product direction is documented in [the rebrand strategy](../docs/product/lets-grow-strategi-teamtrivsel.md).

## Scope

- In scope:
  - A trial model linked to a suggestion, with a cap of active trials per team. The strategy suggests one or two.
  - An evaluation round at the follow-up date: a single question with an answer scale and an optional comment. Answers are anonymous, and results show aggregates only with the minimum threshold from 03.
  - A scheduled push to members when an evaluation opens. A leader reminder belongs in 06.
  - A trial close-out with outcome and learning text. The suggestion status then moves to "Afsluttet med resultat".
  - An improvement history per team, listing decisions and results.
  - A web leader UI to create, start, and close trials and view the evaluation. An iOS employee UI for "Det arbejder vi på" (what we are working on), evaluation answers, and "Resultater" (results).
- Out of scope:
  - Generic survey builders, monthly well-being checks, and quarterly reviews. The strategy calls these supporting features and defers them.

## Context

- Current behavior:
  - The current feedback flow (`ios-app/Modules/Sources/FeedbackFlowFeature/`) implements emoji, 0–10, thumbs, opinion, and comment answer types bound to PIN and event sessions.
  - The backend `FeedbackType` and `feedback` table are event-scoped.
- Reading path:
  - Strategy sections 6.4, 6.5, 9, and 11.
  - The `FeedbackFlowFeature` answer components.
  - The emoji controls extracted to DesignSystem in the product-feedback task. See git history for "submit product feedback and bug reports inside the app".
- State/API flow and prerequisites:
  - The decisions and status from 04.
  - The scheduler.

## Decisions and open questions

- Confirmed:
  - Trials are bounded, with an owner and a follow-up date.
  - The outcome is continue, adjust, or stop.
  - A failed trial is still a valid result.
- Assumptions:
  - Reuse the existing answer UI components on iOS, decoupled from events. Use a new evaluation persistence model rather than the event-scoped `feedback` table, so legacy removal in 09 stays clean.
  - The evaluation window stays open for a fixed number of days. One answer per member is enforced server-side and stored without exposure.
- Unresolved:
  - Decide whether the active-trial cap is a hard limit or a warning.
  - Choose the evaluation answer scale: better, same, or worse; 5-point; or emoji.
  - Decide whether "adjust" restarts the same trial or creates a new linked trial.
- Execution constraints: same as task 02.

## Acceptance criteria

- [ ] AC-1: The leader creates a trial from a suggestion with all required fields, and the suggestion status updates.
- [ ] AC-2: The active-trial cap is enforced according to the agreed rule.
- [ ] AC-3: At the follow-up date, members get one push and can answer once. Results show as aggregates respecting the threshold.
- [ ] AC-4: The leader closes the trial with an outcome and learning text. The trial then appears in the team history on both web and iOS.
- [ ] AC-5: iOS shows the active trials with owner, next step, and follow-up date ("Det arbejder vi på").

## Implementation plan

### Phase 1 — Backend trial and evaluation model

- [ ] Add a changeset with `trial`, `trial_evaluation_answer`, and the outcome fields. Add services, endpoints, a cap rule, and a scheduler job that opens evaluations.
- [ ] Verification: API and scheduler tests for AC-1 to AC-4.

### Phase 2 — Web leader trial management

- [ ] Add a create-trial form prefilled from the suggestion, a trial detail with live evaluation aggregates, a close-out form, and a history page.

### Phase 3 — iOS employee trial and evaluation

- [ ] Add an active trials list, an evaluation answer flow that reuses the decoupled answer components, results and history, and push and deep-link handling.
- [ ] Verification: reducer tests, catalog fixtures, and a live simulator journey.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1 | Suggestion under review | Create a trial on web | The trial exists, and the status is "Planlagt til afprøvning" or "Afprøves" |
| AC-2 | Team at the cap | Create another trial | Blocked or warned according to the decision |
| AC-3 | Follow-up date reached (time-controlled test) | Members answer twice | One answer each, and aggregates are thresholded |
| AC-4 | Evaluated trial | Close as "fortsæt" (continue) | The history shows the result on web and iOS |
| AC-5 | Active trial | Open the iOS home | The trial is listed with owner and date |

## Human review

Not implemented yet.

## Handoff

- Completed: None.
- Verification results: Not run.
- Blockers: Task 04.
- Next action: After 04, settle the evaluation scale and the cap rule, then implement phase 1.
