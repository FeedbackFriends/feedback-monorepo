---
name: lg-refine
description: Refine a LetsGrow idea or existing task across iOS, backend, web, or tooling into a code-grounded Markdown plan saved in tasks/. Resolves scope, ownership, API/data dependencies, acceptance criteria, verification, and phases for large tasks.
---

# Refine a LetsGrow task

Read [root policy](../../../AGENTS.md), [task workflow](../../../docs/agents/task-workflow.md), and [create-task](../lg-create-task/SKILL.md). Always save or update a prefixed Markdown task under root `tasks/`. Refinement alone does not authorize implementation.

## Ground the proposal

Read the supplied task, or inspect `tasks/` for matching work before creating one. Determine the affected areas from the behavior and code, then read each owning app's `AGENTS.md` through the task workflow's platform map. Inspect the affected implementation, its nearest maintained sibling, tests, and relevant callers. Trace cross-platform dependencies rather than assuming that a UI change belongs only to its client.

Use [domain guidance](../lg-domain/SKILL.md) for product language, access roles, and Activity/Event/ParticipantEvent semantics. For API changes, follow backend source → generated contract/clients → handwritten adapters → consuming features. An unknown bug cause belongs in [investigation](../lg-investigate/SKILL.md).

## Settle material decisions

Look up facts before asking. State reasonable implementation assumptions. Ask only product choices or constraints that would materially change the result, with a recommendation grounded in the existing code. Group independent questions using the session's question tool when available; continue independent exploration while answers are pending.

Explore the branches relevant to this task:

- Target user, observable outcome, owner/anonymous access, and feedback privacy.
- Module/service ownership, source of truth, state or persistence changes, API compatibility, and generated artifacts.
- Success, empty/invalid input, failures, duplicate or concurrent work, cancellation, and recovery.
- For clients: navigation, entry points, existing UI components, localized copy, accessibility, and presentation.
- For backend/scheduler: authorization, transactions, migrations, idempotency, job timing, and integration failures.
- Smallest meaningful tests and runtime checks, including environment, accounts, fixtures, and any required cross-platform journey.

For iOS, consult [architecture/state](../../../ios-app/Docs/agents/architecture.md), [product language](../../../ios-app/Docs/agents/product-language.md), and the [iOS feature workflow](../../../ios-app/Docs/agents/feature-workflow.md). For backend and web, use their owning architecture/API/persistence/validation guides. Load only guidance relevant to the actual task.

## Save a usable handoff

Use the create-task template and naming rules, for example `tasks/ios-duplicate-activity.md` or `tasks/backend-session-validation.md`; multi-platform tasks use `shared-`. Include current behavior, repository-relative reading paths, affected files, decisions, acceptance criteria, implementation steps, and verification/data needs so another agent can start without this chat. Large tasks use ordered phases in the same file with dependencies, deliverables, and verification.

Persist decisions as they settle. Keep `draft` with explicit material open questions and a precise next action; set `ready` when actionable. Save partial refinement before pausing for answers. Do not leave the only plan in chat or under a docs directory.

Finish with the task link, readiness, and remaining decisions. If implementation is already authorized, continue through [implementation](../lg-implement/SKILL.md) using the saved task once material questions are settled, without another approval gate.
