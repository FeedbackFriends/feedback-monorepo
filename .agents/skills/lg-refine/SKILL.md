---
name: lg-refine
description: Refine a LetsGrow idea or existing task across iOS, backend, web, or tooling through a focused grilling on specific feature requirements and technical choices, especially overall architecture. Saves decisions, acceptance criteria, and an implementation handoff in the same task file.
---

# Refine a LetsGrow task

Read [root policy](../../../AGENTS.md), [task workflow](../../../docs/agents/task-workflow.md), and [create-task](../lg-create-task/SKILL.md). Always save or update a prefixed Markdown task under root `tasks/`. Refinement alone does not authorize implementation.

## Understand the need

Read the supplied task, or inspect `tasks/` for matching work before creating one. Establish the current problem, target users, desired behavior, affected product surfaces, and scope. Use available product documentation and [domain guidance](../lg-domain/SKILL.md) where relevant. Inspect relevant code and architecture documentation to ground questions in existing responsibilities, boundaries, data flows, and constraints. Read the owning app guidance before exploring its implementation.

## Grill requirements and architecture

Actively challenge ambiguous requirements and assumptions with the user. Look up repository facts before asking; do not ask the user to supply facts the code can answer. Ask focused questions in small rounds, following up on answers until consequential decisions are clear. Use the session's question tool when available and continue independent investigation while answers are pending. Do not silently settle material choices while waiting for the user's answer.

Start with concrete feature scenarios: who does what, when, with which permissions, what success looks like, and what happens in relevant failure or edge cases. Challenge scope, exclusions, dependencies, and acceptance criteria with examples that expose ambiguity.

Put most technical discussion into overall architecture: ownership of behavior and data, boundaries between app/backend/components, sources of truth, data flow, contracts and integrations, and compatibility or rollout implications. Present plausible alternatives, recommend a direction, and explain the tradeoffs so the user can make an informed choice. Use existing patterns by default; do not invent architectural alternatives for routine changes.

Resolve technical details during refinement when they affect requirements, architectural feasibility, or a consequential contract. Leave routine file-level edits, exact implementation code, and test commands to implementation. Do not turn refinement into a line-by-line coding interview. Record confirmed decisions separately from proposals, assumptions, and unanswered questions.

## Save a usable handoff

Use the create-task template and naming rules, for example `tasks/ios-duplicate-activity.md` or `tasks/backend-session-validation.md`; multi-platform tasks use `shared-`. Include the problem, current and desired behavior, scope, detailed feature requirements, product and architectural decisions with rationale/tradeoffs, acceptance criteria, and observable checks so another agent can understand the task without this chat. Large tasks use ordered phases with outcomes and dependencies in the same file. Include relevant architecture/code references from refinement; implementation adds detailed technical steps and verification commands.

Persist decisions as they settle. Keep `draft` with explicit material open questions and a precise next action; set `ready` when feature requirements and consequential architectural choices are settled and the plan is actionable. Routine coding details do not block readiness. Save partial refinement before pausing for answers. Do not leave the only plan in chat or under a docs directory.

Finish with the task link, readiness, and remaining decisions. If implementation is already authorized, continue through [implementation](../lg-implement/SKILL.md) using the saved task once material questions are settled, without another approval gate.
