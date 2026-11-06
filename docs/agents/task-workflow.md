# Task workflow

Upcoming LetsGrow work lives in root [tasks/](../../tasks/README.md), one Markdown file per task. The flow is **refine → save task plan → implement**. GitHub Issues and Projects are not task-management tools for this repository.

| Work | Skill | Saved result |
| --- | --- | --- |
| Capture or format a task | [$lg-create-task](../../.agents/skills/lg-create-task/SKILL.md) | Prefixed task file using the canonical template |
| Resolve scope and decisions | [$lg-refine](../../.agents/skills/lg-refine/SKILL.md) | Code-grounded task with acceptance, verification, and phases when large |
| Execute the plan | [$lg-implement](../../.agents/skills/lg-implement/SKILL.md) | Same file updated with implementation progress and evidence |
| Verify outcomes | [$lg-verify](../../.agents/skills/lg-verify/SKILL.md) | Acceptance evidence and remaining checks |
| Review changes | [$lg-review](../../.agents/skills/lg-review/SKILL.md) | Concrete findings; task capture only when requested |
| Diagnose a bug | [$lg-investigate](../../.agents/skills/lg-investigate/SKILL.md) | Evidence, cause/confidence, and a local task when follow-up is requested |

The shared skills select the owning platform guidance; platform-specific tools stay in their specialized skills. A direct implementation request still saves a proportionate plan before code changes, without another approval ceremony. See [create-task](../../.agents/skills/lg-create-task/SKILL.md) for the single definition of task structure, filenames, phases, statuses, and completion rules.

## Platform guidance and verification

Read the owning `AGENTS.md` before editing. For multi-platform tasks, inspect each affected surface and verify the boundary between them; the filename prefix does not limit scope.

| Area | Guidance | Implementation and verification |
| --- | --- | --- |
| iOS | [iOS policy](../../ios-app/AGENTS.md), [feature workflow](../../ios-app/Docs/agents/feature-workflow.md) | [Swift skill](../../.agents/skills/lg-ios-swift/SKILL.md); native Xcode builds/tests/live journeys; changed-line Swift lint; full-catalog review for UI changes |
| Backend/scheduler | [Backend policy](../../backend/AGENTS.md), [validation](../../backend/docs/agents/validation.md), [persistence](../../backend/docs/agents/persistence.md) | Kotlin services/DAOs, incremental migrations, relevant Gradle module/API/persistence tests; warnings fail the build |
| Web | [Web policy](../../web/AGENTS.md), [validation](../../web/docs/agents/validation.md) | Existing UI/auth/data boundaries, npm lint/build and affected Playwright journeys, responsive checks for visual work |
| Shared contract | [API guidance](api-contract.md) | Backend source → root artifact generation → handwritten consumers; producer and consumer verification |
| Runtime/deployment | [Runtime guide](runtime-and-deployment.md), [Coolify skill](../../.agents/skills/lg-coolify-operations/SKILL.md) | Environment preparation and service health; deployment only when authorized |
| Tooling/docs | [Repository scope](repository-scope.md) | Relevant helper regression tests or skill metadata/link/task-routing validation |

Tests should detect the behavior that can regress. Distinguish a compilation pass, passing behavioral tests, service health, app launch, a live acceptance journey, and fresh visual evidence. Planned verification is not a result. A documentation-only task does not require a running app or database.

## Agent handoff

A ready task includes repository-relative reading paths, current behavior, scope, decisions, dependencies, acceptance criteria, implementation steps/phases, and checks. The next agent reads that file first and rechecks its references against the current checkout. Implementation updates the same file with actual results, the exact next action, and a [human review section](human-review.md) that explains architectural decisions, tradeoffs, a source reading path, and verification limits. A concise version appears in the implementation output. Existing coding standards are the default; the agent handles routine convention and correctness checks. A phase boundary is a checkpoint, not an extra approval gate; honor an explicitly requested phase-only scope.

```text
$lg-refine Add validation to the session API.
# Saves tasks/backend-session-validation.md.
$lg-implement tasks/backend-session-validation.md

$lg-refine Let owners duplicate an activity's question setup in iOS.
# Saves tasks/ios-duplicate-activity.md.
$lg-implement tasks/ios-duplicate-activity.md
```
