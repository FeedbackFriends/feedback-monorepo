---
name: lg-refine
description: Grill a LetsGrow idea or todo with the user to settle requirements and architecture before implementation. Keep the detailed plan in the conversation and todos.md simple.
---

# Grill a LetsGrow idea

Read [root policy](../../../AGENTS.md) and the [task workflow](../../../docs/agents/task-workflow.md). Refinement does not add a todo or create a task file. Keep the selected backlog item short and nontechnical.

## Understand the need

Read the selected item in root `todos.md`, or establish the request from the conversation. Establish the current problem, target users, desired behavior, affected product surfaces, and scope. Use available product documentation and [domain guidance](../../../docs/product/lets-grow-strategi-teamtrivsel.md) where relevant. Inspect relevant code and architecture documentation to ground questions in existing responsibilities, boundaries, data flows, and constraints. Read the owning app guidance before exploring its implementation.

For customer interviews, public copy, or first-use journeys, use the relevant [community skill and product constraints](../../../docs/skills.md#choosing-complementary-skills). Research supplies evidence; refinement still owns the requirements and architecture discussed with the user.

## Grill requirements and architecture

Actively challenge ambiguous requirements and assumptions with the user. Look up repository facts before asking; do not ask the user to supply facts the code can answer. Ask focused questions in small rounds, following up on answers until consequential decisions are clear. Use the session's question tool when available and continue independent investigation while answers are pending. Do not silently settle material choices while waiting for the user's answer.

Start with concrete feature scenarios: who does what, when, with which permissions, what success looks like, and what happens in relevant failure or edge cases. Challenge scope, exclusions, dependencies, and acceptance criteria with examples that expose ambiguity.

Put most technical discussion into overall architecture: ownership of behavior and data, boundaries between app/backend/components, sources of truth, data flow, contracts and integrations, and compatibility or rollout implications. Present plausible alternatives, recommend a direction, and explain the tradeoffs so the user can make an informed choice. Use existing patterns by default; do not invent architectural alternatives for routine changes.

Resolve technical details during refinement when they affect requirements, architectural feasibility, or a consequential contract. Leave routine file-level edits, exact implementation code, and test commands to implementation. Do not turn refinement into a line-by-line coding interview. Record confirmed decisions separately from proposals, assumptions, and unanswered questions.

## Hand off to implementation

Summarize the agreed outcome, scope, acceptance criteria, architectural decisions and tradeoffs, relevant source references, and remaining questions in the conversation. Keep confirmed decisions distinct from proposals. For larger work, outline phases with observable outcomes and dependencies.

When material requirements and architectural choices are settled, the plan is ready for [implementation](../lg-implement/SKILL.md). If implementation is already authorized, continue without another approval gate; otherwise hand off the plan. Refinement alone does not authorize code changes. Do not expand `todos.md` into a specification or create separate task files.
