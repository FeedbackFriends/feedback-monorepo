---
status: draft
areas: [backend, web]
created: 2026-11-06
updated: 2026-11-06
---

# Rebrand 11 — HR overview role (future, low priority)

**Priority: low.** For now only team leaders and employees exist (user, 2026-11-06). Start this task only after the iOS and web rebrand has shipped and pilots ask for a company-level view.

## Problem and outcome

The strategy (sections 3 and 10 of `lets-grow-strategi-teamtrivsel.md`) describes HR and company management as roles that need an overview across teams. They support good processes without owning every improvement.

Outcome: an HR user signs in on web and sees an organization-wide overview of process and results across teams, such as suggestions with a decision, trials, and evaluations. The overview never monitors individual employees.

## Rebrand series

Depends on **02** (organization → team model) and **06** (leader dashboard and metrics). The coming-soon landing page (01) is implemented; product direction is documented in [the rebrand strategy](../docs/product/lets-grow-strategi-teamtrivsel.md).

## Scope

- In scope:
  - **Organization role.** An organization-level HR role, assigned by an existing leader or organization owner. Assignment is server-enforced.
  - **Cross-team overview.** Read-only on web, reusing the team metrics from 06 and aggregated per team.
  - **Anonymity.** The overview respects the minimum-threshold rules from 03.
- Out of scope:
  - HR acting on behalf of teams, such as deciding or creating trials.
  - Advanced HR modules. The strategy explicitly defers these.

## Context

- Task 02 models organization → team(s), so this role can be added without restructuring.
- Task 03 has an open question about who receives confidential messages. HR is one candidate once this role exists.

## Decisions and open questions

- Confirmed: deferred, low priority, and web only.
- Assumptions: None.
- Unresolved:
  - Who can grant the HR role, and whether a separate director role exists.
  - Whether HR receives confidential messages (see task 03).
  - Which cross-team figures are safe to show for small teams.
- Execution constraints: none until the task is prioritized.

## Acceptance criteria

- [ ] AC-1: Only an authorized user can grant the HR role, and the server enforces it.
- [ ] AC-2: An HR user sees a cross-team overview of process metrics, with no individual employee data.
- [ ] AC-3: An HR user cannot change team decisions or trials.

## Implementation plan

- [ ] Refine when prioritized.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1 | API tests | A non-authorized user grants HR | 403 |
| AC-2 | Seeded organization with two teams | HR opens the overview | Per-team aggregates, no identities |
| AC-3 | API tests | HR calls the decision and trial endpoints | 403 |

## Human review

Not implemented yet.

## Handoff

- Completed: None.
- Verification results: Not run.
- Blockers: Deferred until after the iOS and web rebrand ships.
- Next action: None until prioritized. Then run `$lg-refine todos/11-rebrand-hr-overview.md`.
