---
name: lg-implement
description: Implement a LetsGrow task from tasks/ across iOS, backend, web, or tooling while maintaining phase progress, acceptance criteria, verification evidence, and an architectural review handoff for the human. Direct implementation requests first get a proportionate saved task plan.
---

# Implement a LetsGrow task

Read [root policy](../../../AGENTS.md), the [task workflow](../../../docs/agents/task-workflow.md), and the specified `tasks/<prefix>-<slug>.md`. The task file is the execution plan. Follow [create-task](../lg-create-task/SKILL.md) for its structure and lifecycle. If the request exists only in chat or an older document, first save a proportionate task file. Use [refinement](../lg-refine/SKILL.md) for material gaps; a clear implementation request needs no extra planning approval.

## Establish the slice

Check readiness, dependencies, acceptance, verification, and handoff. Recheck code references against this checkout. Inspect Git status and preserve unrelated work. Do not create or switch branches without the user's instruction. Read the owning app's `AGENTS.md` before editing each subtree.

Implement the feature requirements and architectural direction settled in refinement. Inspect affected code, callers, and tests, validate the plan against the checkout, and resolve routine details such as affected files, exact API/data changes, migrations, and verification commands. Add technical steps and reading paths to the task. If material feature or architectural choices remain unresolved, return to refinement with the user before dependent implementation. Do not silently replace a refined architectural decision; explain new evidence and settle consequential departures with the user.

Set `in-progress` when starting. Follow phase dependency order; complete each phase's deliverables and checks before marking it complete. Continue through the authorized task without approval gates at phase boundaries. If only one phase is requested, stop there and record the next action.

## Implement in the owning surface

Use the task workflow's platform map:

- **iOS:** use [Swift guidance](../../../ios-app/Docs/agents/swift.md), existing TCA/Bootstrap and Domain/Adapters boundaries, localized UI, and existing DesignSystem/previews. Native Xcode MCP owns local app builds, tests, and simulator operations.
- **Backend/scheduler:** follow Kotlin architecture, service/persistence ownership, constructor injection, authorization, and migration guidance. Run Gradle from `backend/`; do not edit applied migrations or hide warnings/failures.
- **Web:** follow web architecture/UI/auth guidance and existing npm commands. Inspect the live affected flow when appropriate.
- **Cross-platform API:** change canonical backend source, regenerate through the root API script, and update handwritten consumers. Never patch generated clients manually. Keep server/client compatibility and deployment order explicit in the task.
- **Tooling/docs:** keep changes in their owning files and validate the actual helper behavior, references, and configuration affected.

Follow existing coding standards and established patterns by default; inspect their source rather than turning routine style choices into human decisions. Complete the requested behavior including failure handling and meaningful tests. Mechanical or low-impact edits do not need tests that merely repeat the implementation. Update docs made stale by the work; broader refactors belong only when necessary for the task.

## Verify and maintain the handoff

Use [verification](../lg-verify/SKILL.md), selecting the applicable platform checks and cross-surface acceptance scenario. Keep planned checks separate from actual results. Fix regressions caused by this work and rerun affected checks; report unrelated failures. When one tool or service is blocked, continue independent work without silently changing tools or environments.

Update the same task file as work progresses: completed deliverables/acceptance, actual commands/results/artifacts, changed decisions, blockers, and exact next action. Preserve `created` and refresh `updated` while work remains. Retain an accurate `in-progress` or `blocked` status for incomplete work. Once acceptance and required verification pass, prepare the final handoff and remove the task file following the create-task completion procedure; do not retain a `done` task.

## Prepare the human review

Follow the [human review guide](../../../docs/agents/human-review.md). Maintain a `## Human review` section while the task is unfinished. Include a self-contained `Human review` section in the final implementation/phase handoff; on full completion, preserve the review and evidence in that response before removing the task file. Explain the final behavior and data/control flow, consequential architectural decisions with rationale/tradeoffs, a short linked reading path through source/tests, and actual verification/limits. Distinguish implementation decisions from choices already settled in refinement, and identify any material departure from existing standards.

For changes that retain the existing architecture, identify the pattern and say so without inventing architectural choices. The agent still owns ordinary coding standards and correctness checks. Do not claim the human has reviewed the change merely because this section exists.

For incomplete work, finish with the task link/status, human review, verification evidence, and material limits. For completed work, report that the task file was removed and include the human review and actual verification results directly, with links to existing source/docs/artifacts rather than the deleted task. For iOS, include Swift lint and simulator outcomes and leave a successfully launched app available. Commit/push, deployment, or external PR updates require the applicable user authorization; task tracking stays local.
