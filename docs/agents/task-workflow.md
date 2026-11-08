# Todo, grill, implement

Root [todos.md](../../todos.md) is the single backlog. Each item is one checkbox with one or two short, nontechnical lines describing a problem or desired outcome. Preserve list order unless the user asks to reprioritize. Add items only on explicit user request; ordinary implementation, investigation, refinement, and cleanup requests do not add backlog work.

| Step | Skill | Result |
| --- | --- | --- |
| Capture a requested todo | [lg-add-todo](../../.agents/skills/lg-add-todo/SKILL.md) | A short item in `todos.md` |
| Grill the idea with the user | [lg-refine](../../.agents/skills/lg-refine/SKILL.md) | Requirements, architecture, acceptance, and open questions settled in the conversation |
| Implement the agreed change | [lg-implement](../../.agents/skills/lg-implement/SKILL.md) | Working change, automated verification, and human review handoff |

Keep detailed plans, technical decisions, progress, and evidence in the conversation. Create no separate task files, status frontmatter, or task templates. A clear direct implementation request can proceed without adding a todo; grill material gaps before dependent work. Refinement alone does not authorize implementation. When implementation is already authorized, proceed once material choices are settled without another approval gate.

## Implementation completion

Run relevant automated tests and required lint/build checks before handoff. Passing checks complete the agent’s implementation work; the human performs manual testing. Pending manual journeys or visual review do not keep an implemented task open. Run manual/runtime checks only when explicitly requested, following the platform guides. Report failed or unavailable automated checks rather than claiming success. This policy applies to older task plans as well.

## Platform guidance and verification

Read the owning `AGENTS.md` before editing. For multi-platform tasks, inspect each affected surface and verify the boundary between them.

| Area | Guidance | Implementation and verification |
| --- | --- | --- |
| iOS | [iOS policy](../../ios-app/AGENTS.md), [feature workflow](../../ios-app/Docs/agents/feature-workflow.md) | [Swift guidance](../../ios-app/Docs/agents/swift.md); native Xcode builds/tests; changed-line Swift lint |
| Backend/scheduler | [Backend policy](../../backend/AGENTS.md), [validation](../../backend/docs/agents/validation.md), [persistence](../../backend/docs/agents/persistence.md) | Kotlin services/DAOs, incremental migrations, relevant Gradle module/API/persistence tests; warnings fail the build |
| Web | [Web policy](../../web/AGENTS.md), [validation](../../web/docs/agents/validation.md) | Existing UI/auth/data boundaries, npm lint/build and affected automated Playwright tests |
| Shared contract | [API guidance](api-contract.md) | Backend source → root artifact generation → handwritten consumers; producer and consumer verification |
| Runtime/deployment | [Runtime guide](runtime-and-deployment.md), [Coolify skill](../../.agents/skills/lg-coolify-operate/SKILL.md) | Environment preparation and service health; deployment only when authorized |
| Tooling/docs | [Repository scope](repository-scope.md) | Relevant helper regression tests or skill metadata/link/task-routing validation |

Tests should detect the behavior that can regress. Distinguish a compilation pass, passing behavioral tests, service health, app launch, a live acceptance journey, and fresh visual evidence. Planned verification is not a result. A documentation-only task does not require a running app or database.

## Handoff and completion

Follow [human review](../../.agents/skills/lg-implement/SKILL.md#prepare-the-human-review) in the final response: explain the behavior, consequential decisions, reading path, actual verification, limitations, and any remaining next action. Remove the corresponding todo only when its entire outcome and required automated checks are complete and the handoff is prepared. Partial progress leaves the short item in place; do not turn it into a progress log. Preserve enduring knowledge in its owning guide. GitHub Issues and Projects are not used for task management.
