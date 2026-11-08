# LetsGrow todos

All upcoming LetsGrow work lives here, with one Markdown file per task. GitHub Issues and GitHub Projects are not used for task management.

The flow is **create a nontechnical draft task → refine feature requirements and overall architecture with the user → implement the task**. The saved file is the handoff between sessions or agents.

Use [$lg-create-task](../.agents/skills/lg-create-task/SKILL.md) to capture or update a task. That skill defines the required structure, status lifecycle, filenames, and when a large task needs phases. Its [template](../.agents/skills/lg-create-task/assets/task.md) is the single source for task structure.

Task filenames start with a two-digit priority followed by their area, for example `02-shared-platform-consolidation.md`. Sort filenames ascending: `01` is the highest priority. Completed task files are removed, so gaps are expected; the lowest remaining number is next. Preserve the area after the number (`ios-`, `web-`, `backend-`, `android-`, `shared-`, `tooling-`, or `docs-`). The lifecycle skills work across iOS, backend, and web. See the [shared task workflow](../docs/agents/task-workflow.md) for platform routing.

For example:

```text
$lg-create-task Let owners duplicate an activity's question setup.
# Captures todos/ios-duplicate-activity.md as a nontechnical draft.
$lg-refine todos/ios-duplicate-activity.md
$lg-implement todos/ios-duplicate-activity.md
```

Refinement always saves a task file, including a draft when questions remain. Implementation reads and maintains that same file, including phase progress, acceptance checkboxes, verification evidence, a Human review section focused on architectural decisions and a linked reading path, and the next action. A `ready` task should be usable by an agent that has never seen the original conversation.

Find upcoming work by reading task frontmatter: `draft`, `ready`, `in-progress`, or `blocked`. Delete the task file once all acceptance criteria and required verification are satisfied. Include the architectural review and actual results in the final response before removal; retain enduring documentation in its normal docs home and fix references to the removed task. Completed tasks are not archived under another folder. A completed phase with work remaining stays here. This README is guidance; each other Markdown file in this directory represents one task. Do not maintain a duplicate backlog in this file.

## Priority order

The numbered filenames are the single source of priority; do not maintain a second task list here. The current order was set on 2026-11-08: finish authentication and establish platform foundations, deliver the core improvement loop and its web/native workspaces, close relevant usability/support work and release checks, finish public launch materials, retire Zoho and the old meeting model, then consider platform expansion and optional features.

Priority does not override prerequisites, task readiness or authorization. A blocked task stays high priority while independent work can continue. Platform consolidation can be refined early without prematurely cutting over production. Existing implemented polish tasks should be reviewed for closure or relevance, rather than expanded on surfaces scheduled for retirement. Required automated checks remain part of every implementation even though the broad legacy Maestro-suite task is deferred.

Older rebrand task numbers in historical notes are not priority numbers. Completed rebrand 01/02 remain historical context; current priority lives in each filename. When adding or reprioritizing tasks, retain area ownership and repair incoming links.
