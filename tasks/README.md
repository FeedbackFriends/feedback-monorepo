# LetsGrow tasks

All upcoming LetsGrow work lives here, with one Markdown file per task. GitHub Issues and GitHub Projects are not used for task management.

The flow is **refine task → save the task plan here → implement the task**. The saved file is the handoff between sessions or agents.

Use [$lg-create-task](../.agents/skills/lg-create-task/SKILL.md) to capture or update a task. That skill defines the required structure, status lifecycle, filenames, and when a large task needs phases. Its [template](../.agents/skills/lg-create-task/assets/task.md) is the single source for task structure.

Task filenames start with `ios-`, `backend-`, `web-`, `tooling-`, or `docs-`; use `shared-` for cross-platform work. The lifecycle skills work across iOS, backend, and web. See the [shared task workflow](../docs/agents/task-workflow.md) for platform routing.

For example:

```text
$lg-refine Let owners duplicate an activity's question setup.
# Produces tasks/ios-duplicate-activity.md.
$lg-implement tasks/ios-duplicate-activity.md
```

Refinement always saves a task file, including a draft when questions remain. Implementation reads and maintains that same file, including phase progress, acceptance checkboxes, verification evidence, a Human review section focused on architectural decisions and a linked reading path, and the next action. A `ready` task should be usable by an agent that has never seen the original conversation.

Find upcoming work by reading task frontmatter: `draft`, `ready`, `in-progress`, or `blocked`. Completed tasks remain here as `done` with their verification results. This README is guidance; each other Markdown file in this directory represents one task. Do not maintain a duplicate backlog in this file.
