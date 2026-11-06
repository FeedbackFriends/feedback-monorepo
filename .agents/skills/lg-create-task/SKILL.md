---
name: lg-create-task
description: Create or update a LetsGrow task as a self-contained Markdown plan in the root tasks/ directory. Use for capturing upcoming work, writing a refined plan, or preparing a handoff to another agent; large tasks have ordered phases in the same file.
---

# Create a LetsGrow task

Root `tasks/` is LetsGrow's task backlog and implementation handoff. Do not use GitHub Issues or GitHub Projects for task management. This skill applies across iOS, backend, web, and tooling; read the owning app guidance when inspecting its implementation.

## Locate or create the file

Inspect `tasks/` for an existing matching task before creating one. Update the same file throughout refinement and implementation rather than creating competing plans. Use a descriptive English kebab-case filename, with an owning-area prefix: `ios-`, `backend-`, `web-`, `tooling-`, or `docs-`, for example `tasks/ios-duplicate-activity.md`. Use `shared-` for tasks spanning multiple product surfaces and list every affected area in frontmatter. Prefixes describe ownership; do not split one coherent cross-platform task just to give every platform a file. If an unrelated task already has that name, choose a more specific name without overwriting it. Keep one task per Markdown file; phases stay inside that task file.

Use [the task template](assets/task.md) as the canonical structure. `tasks/README.md` is the entry point, not a separate task list to synchronize. Do not put new task plans under `docs/plans/` or leave the only plan in chat. Existing technical documentation can be linked as context without copying it into the task.

## Fill the structure

Preserve the template's frontmatter keys and top-level sections. Replace placeholders with known facts; use `None` or explicit `Unresolved: ...` where appropriate. Do not invent decisions or mark unchecked work complete. Keep detail proportional to the work so a small fix remains a short task.

- `status`: `draft`, `ready`, `in-progress`, or `blocked`. Completed tasks are removed rather than stored with a terminal status.
- `areas`: one or more of `ios`, `backend`, `web`, `tooling`, `docs`.
- `created` and `updated`: ISO dates (`YYYY-MM-DD`); preserve `created` on updates.
- Problem/outcome and scope describe observable behavior and explicit exclusions.
- Context includes repository-relative code/docs/test paths, current behavior, relevant architecture/API flow, and prerequisites. Another agent must be able to understand it without the originating chat.
- Decisions distinguish confirmed choices, implementation assumptions, and unresolved material questions. Put dependencies and execution constraints here, including permitted environment/account/fixture actions when relevant. A proposed reset or production mutation in a plan is not authorization to execute it.
- Acceptance criteria use stable `AC-1`, `AC-2`, etc. identifiers and observable results.
- Implementation plan names the affected modules/files and uses checkboxes for meaningful deliverables. For large work spanning independently verifiable steps, use ordered `### Phase 1 — ...` subsections, each with its outcome, dependencies, implementation items, and verification. Keep a coherent small task as one checklist; do not add ceremonial phases.
- Verification maps acceptance IDs to preconditions, action/check, and expected result. Include important failure/role cases, test commands or native-tool checks, environment/data needs, and relevant visual review. Record actual results separately from planned checks.
- Human review starts as `Not implemented yet`. Implementation fills it using the [human review guide](../../../docs/agents/human-review.md), with decisions, rationale/tradeoffs, source reading path, and verification limits. It explains the change for a human; it is not a review approval record.
- Handoff records completed work, verification evidence/artifacts, remaining blockers, and the exact next action. Initial results should say `Not run`.

## Lifecycle and handoff

Use `draft` for captured ideas or plans with material unknowns. Use `ready` when scope, decisions, acceptance, and verification are actionable. Implementation sets `in-progress`; use `blocked` when a dependency prevents further meaningful progress and record what unblocks it. When all acceptance criteria and required verification are satisfied, prepare the final human-review explanation and actual verification results, then delete the task file. `tasks/` contains unfinished work only: do not keep a `done` file or move it to a completed/archive directory. A completed phase does not finish a task with remaining scope; retain that file and its next action.

Before deletion, move any still-needed architectural or usage documentation into its existing documentation home and update live references to the task so they do not become broken links. Keep the final response self-contained with decisions, source reading links, evidence, and limits rather than linking to the removed file. Git history preserves previously committed task plans. Deletion is part of completing the task and does not require another confirmation; it does not authorize a Git commit or push.

For unfinished work, save the file and return its path and readiness. For completed work, report completion and removal instead. Creating/refining a task does not start implementation unless the user already requested it. If implementation is authorized and the task is ready, continue without another approval gate. Update status, checkboxes, evidence, and handoff as work progresses so another agent can resume accurately. Do not overwrite unrelated concurrent edits to a task.
