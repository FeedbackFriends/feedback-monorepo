---
name: lg-implement
description: Implement an agreed LetsGrow change across iOS, backend, web, or tooling, verify it, and prepare a human review handoff. Keep plans in the conversation and todos.md simple.
---

# Implement a LetsGrow change

Read [root policy](../../../AGENTS.md) and the [task workflow](../../../docs/shared/agents/task-workflow.md). Use the agreed conversation plan and selected `todos.md` item, if any. Create no task files. Add todos only when explicitly requested. Use [refinement](../lg-refine/SKILL.md) to grill material requirements or architectural gaps; a clear direct implementation request needs no extra planning approval.

## Establish the slice

Check readiness, dependencies, acceptance, verification, and handoff. Recheck code references against this checkout. Inspect Git status and preserve unrelated work. Do not create or switch branches without the user's instruction. Read the owning app's `AGENTS.md` before editing each subtree.

Implement the feature requirements and architectural direction settled in refinement. Inspect affected code, callers, and tests, validate the plan against the checkout, and resolve routine details such as affected files, exact API/data changes, migrations, and verification commands. Keep technical steps and reading paths in the conversation. If material feature or architectural choices remain unresolved, return to refinement with the user before dependent implementation. Do not silently replace a refined architectural decision; explain new evidence and settle consequential departures with the user.

Follow phase dependency order; complete each phase's deliverables and checks before marking it complete. Continue through the authorized task without approval gates at phase boundaries. If only one phase is requested, stop there and record the next action.

## Implement in the owning surface

Use the task workflow's platform map:

- **iOS:** use [Swift guidance](../../../docs/ios/agents/swift.md), existing TCA/Bootstrap and Domain/Adapters boundaries, localized UI, and existing DesignSystem/previews. Native Xcode MCP owns local app builds, tests, and simulator operations.
- **Backend/scheduler:** follow Kotlin architecture, service/persistence ownership, constructor injection, authorization, and migration guidance. Run Gradle from `backend/`; do not edit applied migrations or hide warnings/failures.
- **Web:** follow web architecture/UI/auth guidance and existing npm commands. Run relevant automated tests and required lint/build checks.
- **Cross-platform API:** change canonical backend source, regenerate through the root API script, and update handwritten consumers. Never patch generated clients manually. Keep server/client compatibility and deployment order explicit in the conversation.
- **Tooling/docs:** keep changes in their owning files and validate the actual helper behavior, references, and configuration affected.

Follow existing coding standards and established patterns by default; inspect their source rather than turning routine style choices into human decisions. Complete the requested behavior including failure handling and meaningful tests. Mechanical or low-impact edits do not need tests that merely repeat the implementation. Update docs made stale by the work; broader refactors belong only when necessary for the task.

## Verify and maintain the handoff

Run the relevant automated tests and required lint/build checks at the end of implementation. Use the smallest sufficient checks for the affected behavior, including both sides of changed contracts. Fix regressions caused by this work and rerun affected checks; report unrelated failures or unavailable checks. Once these checks pass, implementation is ready for handoff. The human owns manual testing, live journeys, simulator interaction, and visual review; list useful manual checks without running them unless explicitly requested. Pending human testing does not block completion or removal of the corresponding todo. Keep planned checks separate from actual results.

Report completed work, actual verification, changed decisions, blockers, and the next action in the conversation. Keep `todos.md` short. Remove the corresponding item only when its entire outcome and required automated checks are complete and the final handoff is prepared; partial progress leaves the item in place.

## Prepare the human review

Give a self-contained handoff in the final response, scaled to the change:

- **Behavior and flow:** explain what changed and how the affected request, action, or data moves through the system. Use a before/after example when helpful.
- **Architecture:** explain consequential ownership, boundary, dependency, state, contract, compatibility, or rollout decisions and their rationale/tradeoffs. Distinguish implementation decisions from choices settled in refinement. For unchanged architecture, identify the existing pattern without inventing alternatives.
- **Reading path:** link to the few source symbols/files and tests that make those decisions reviewable, explaining what each shows.
- **Verification and limits:** report actual automated results, material risks, remaining work, and useful human manual checks. For incomplete work, state the exact next action.

The agent owns correctness, existing coding standards, and required automated checks; the human assesses architectural judgement and performs manual testing. Explain any deliberate departure from existing conventions and resolve routine violations before handoff. Settle material open requirements or architectural choices with the user before dependent implementation.

Keep plans and evidence in the conversation and enduring knowledge in its owning guide. The handoff records the author's explanation and evidence; it does not imply human approval or add an approval gate.

For iOS, report relevant automated test, build, and Swift lint results. Launch the app only when requested. Commit/push, deployment, and external PR updates require their applicable authorization.
