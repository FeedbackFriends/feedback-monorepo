# Plan, build, review, hand off

One builder owns delivery; a fresh reviewer independently challenges substantive changes before the human handoff. Use [lg-deliver](../../../.agents/skills/lg-deliver/SKILL.md) for implementation requests. Natural-language requests follow the same workflow.

## 1. Agree on the outcome

Inspect the affected code, callers, tests, and owning guidance before choosing an implementation. State the observable outcome, scope, constraints, acceptance checks, and consequential decisions in the conversation. A clear fix needs only a few sentences; larger or ambiguous work needs a short plan with observable increments. Use [lg-plan](../../../.agents/skills/lg-plan/SKILL.md) when product requirements or architecture need discussion.

Resolve material product, public-contract, security, data, billing, and hard-to-reverse choices with the user before dependent work. The builder owns routine implementation details. An implementation request authorizes continuing through verification, review, and fixes without another phase approval. Refinement alone does not authorize implementation.

## 2. Build and verify

The builder implements the agreed outcome in small increments, using relevant platform skills and existing patterns. Preserve unrelated work, update guidance made stale by the change, and keep broader refactors within scope. Run relevant automated tests and required lint/build checks. Fix failures introduced by the change; report unrelated failures or unavailable checks with their limits.

Completion of this stage requires an implemented outcome and actual verification evidence, ready for independent review.

## 3. Review independently

For substantive changes, start a fresh read-only reviewer agent or session. This workflow explicitly requests delegation for that review. Give it the agreed requirements, constraints, relevant guidance, review base, exact changed-file scope, and verification evidence. Let it inspect the implementation independently; the builder's conclusions are claims to verify. When the workspace contains unrelated changes, provide the task's delta against its starting state and enough surrounding context to assess it.

The reviewer applies [code review](#code-review), checks acceptance coverage, and examines correctness, security, compatibility, data integrity, complexity, and meaningful test gaps. Return ranked concrete findings, checks performed, and residual uncertainty. A review with no findings is evidence of review, not a correctness guarantee.

Typos and trivial mechanical changes with no behavior or policy impact may use a distinct builder self-review instead. Substantive code, architecture, workflow, permission, and contract changes require a fresh reviewer. If a fresh reviewer is unavailable, perform self-review, report the limitation, and leave independent review outstanding rather than claiming it occurred.

## 4. Resolve findings

The builder fixes valid findings, documents evidence for disagreements, and reruns checks affected by the fixes. The reviewer checks corrections and any new risks they introduce. Close each material finding as fixed or explain the unresolved issue in the handoff. Escalate a persistent material disagreement to the human with alternatives and evidence; avoid repeating unchanged review arguments. Finish when required checks pass and material findings are resolved, or clearly report what prevents completion.

## Implementation completion

Implementation is complete after automated verification, the applicable review, and resolution of material findings. The human performs manual testing after handoff. Pending manual journeys, simulator interaction, or visual review do not keep implementation open. Run manual/runtime and visual checks only when explicitly requested, following platform guides. This completion policy takes precedence over older verification plans. Failed or unavailable required checks and outstanding independent review remain explicit open points.

## Platform guidance and verification

Read the owning `AGENTS.md` before editing. For multi-platform tasks, inspect each affected surface and verify the boundary between them.

| Area | Guidance | Implementation and verification |
| --- | --- | --- |
| iOS | [iOS policy](../../../ios-app/AGENTS.md), [feature workflow](../../ios/agents/feature-workflow.md) | [Swift guidance](../../ios/agents/swift.md); native Xcode builds/tests; changed-line Swift lint |
| Backend/scheduler | [Backend policy](../../../backend/AGENTS.md), [validation](../../backend/agents/validation.md), [persistence](../../backend/agents/persistence.md) | Kotlin services/DAOs, incremental migrations, relevant Gradle module/API/persistence tests; warnings fail the build |
| Web | [Web policy](../../../web/AGENTS.md), [validation](../../web/agents/validation.md) | Existing UI/auth/data boundaries, npm lint/build and affected automated Playwright tests |
| Shared contract | [API guidance](api-contract.md) | Backend source → root artifact generation → handwritten consumers; producer and consumer verification |
| Runtime/deployment | [Runtime guide](runtime-and-deployment.md), [Coolify skill](../../../.agents/skills/lg-coolify-operate/SKILL.md) | Environment preparation and service health; deployment only when authorized |
| Tooling/docs | [Repository scope](repository-scope.md) | Relevant helper regression tests or skill metadata/link/task-routing validation |

Tests should detect the behavior that can regress. Distinguish a compilation pass, passing behavioral tests, service health, app launch, a live acceptance journey, and fresh visual evidence. Planned verification is not a result. A documentation-only task does not require a running app or database.

## Prepare the human review

Give a brief, self-contained handoff using these headings, scaled to the change:

- **Implemented:** Resulting behavior, with before/after examples when useful.
- **Human review focus:** Consequential decisions, tradeoffs, and departures from the plan; link the few files and tests worth inspecting and explain what to assess.
- **Verification:** Automated checks actually run and their results. For iOS, include relevant tests, build, and Swift lint.
- **Agent review:** Fresh reviewer or self-review, scope, findings resolved, and remaining concerns. Distinguish a completed review from one still outstanding.
- **Manual testing:** Concrete user journeys for the human when useful; omit otherwise.
- **Open points:** Remaining limitations, failed/unavailable checks, unresolved findings, or decisions; omit when empty.

The builder owns correctness, coding standards, verification, and finding resolution. The reviewer independently challenges the result. The human assesses product behavior, architectural judgment, and manual experience. Handoff does not imply human approval. Commits, pushes, deployments, and external PR updates retain their separate authorization requirements. Follow root policy: commit or push only when explicitly requested, without prompting at routine handoffs.

## Backlog and durable knowledge

Root [todos.md](../../../todos.md) remains the single prioritized backlog. Add items only when explicitly requested, using [lg-add-todo](../../../.agents/skills/lg-add-todo/SKILL.md). Each item is one plain Markdown bullet with one or two short nontechnical lines, without checkboxes. Preserve ordering unless reprioritization is requested. Remove completed items only after the full outcome, required checks, review, and handoff are complete; partial work leaves the item in place. Use no GitHub Issues or Projects for LetsGrow task management.

Keep plans, decisions, progress, review findings, and evidence in the conversation. Put enduring knowledge in its owning guide; create no separate task files or status templates.

## Code review

State the review scope and base. Unless specified otherwise, review the current branch against its target merge base (normally `origin/main`), including staged, unstaged, and relevant untracked changes. Report a missing target ref rather than silently narrowing the scope. Read affected app rules, complete changed functions, callers, and tests; inspect both sides of changed contracts. For broad renames, check all callers and the semantic changes remaining after the mechanical edits.

Report concrete findings first, ranked by impact, with a file/line, trigger, failure path, and observable consequence. Distinguish introduced from pre-existing problems. Concurrency or retry claims need a concrete event timeline. Report checks performed and uncertainty; avoid stylistic padding and unsupported defect claims. Verify implementation handoff claims against source.

Review is read-only unless changes are requested. Fixes, external comments, thread resolution, commits, and branch changes retain their authorization requirements. Add findings to `todos.md` only when explicitly asked. Apply platform architecture, authorization, persistence, localization, accessibility, and testing rules from their existing owning guides; run visual checks only when explicitly requested.
