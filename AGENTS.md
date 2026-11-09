# LetsGrow

LetsGrow is a feedback-after-meetings product with a Next.js web app, Kotlin backend, and SwiftUI/TCA iOS app in one monorepo.

- Both Codex and Claude Code are actively used. Maintain shared guidance and working discovery/tool configuration for both clients.
- Read the nearest app `AGENTS.md` before editing its subtree.
- Commit or push only when the user explicitly requests it. Do not ask whether to commit or push as part of routine handoffs.
- Finish implementation by running the relevant automated tests and required lint/build checks. Complete the applicable agent review and resolve material findings before handoff for human manual testing; manual journeys, simulator interaction, and visual review do not block implementation completion. Run those checks only when explicitly requested. This completion policy takes precedence over platform guides and older task verification plans. Report failures or unavailable checks honestly.
- Keep the backlog in root `todos.md`: one plain Markdown list item with one or two short, nontechnical lines; no checkboxes. The list is prioritized from highest to lowest; preserve its order unless the user asks to reprioritize. Add todos only when the user explicitly asks. Use `lg-plan` when requirements or architecture need clarification; keep technical plans and verification out of the backlog. Remove completed items after verification and handoff. Never use GitHub Issues or Projects for LetsGrow task management.

## Repository commands

Run from the monorepo root:

- `./scripts/shared/generate-api-artifacts.sh`: regenerate the backend OpenAPI contract and TypeScript/Swift clients; never hand-edit generated API artifacts.
- `./scripts/shared/reset-and-start-local-stack.sh` (or `./scripts/shared/reset-and-start-local-stack.sh -d`): rebuild and start the local stack; this resets Compose volumes. Read the runtime guide before use.

## Read when relevant

| Task | Guidance |
| --- | --- |
| Documentation overview | [Documentation index](docs/README.md) |
| Agent harness, tools, skills, or hooks | [Agent harness architecture](docs/shared/agent-tooling.md) |
| Cross-platform architecture or repository orientation | [Architecture overview](docs/shared/architecture.md) |
| Product, UX, marketing, or domain terminology | [Domain guidance](docs/shared/product/lets-grow-strategi-teamtrivsel.md) |
| Web frontend | [web/AGENTS.md](web/AGENTS.md) |
| Backend API, scheduler, or persistence | [backend/AGENTS.md](backend/AGENTS.md) |
| Task creation, refinement, implementation, verification, review, or handoff | [Shared task workflow](docs/shared/agents/task-workflow.md) and [add-todo skill](.agents/skills/lg-add-todo/SKILL.md) |
| iOS app | [ios-app/AGENTS.md](ios-app/AGENTS.md) |
| iOS feature refinement, implementation, Swift, review, or investigation | [iOS feature workflow](docs/ios/agents/feature-workflow.md) |
| Creating or moving docs/scripts, file ownership, or shared conventions | [Repository scope](docs/shared/agents/repository-scope.md) |
| API shape or generated clients | [API contract](docs/shared/agents/api-contract.md) |
| Docker, environment, or production deployment | [Runtime and deployment](docs/shared/agents/runtime-and-deployment.md) |
| GitHub Actions or release automation | [CI/CD](docs/shared/agents/ci-cd.md) |
| iOS build, test, launch, or verification, including from the root | [iOS policy and guide map](ios-app/AGENTS.md) |
| Browser access or website authentication | [Browser access](docs/shared/agents/browser-access.md) |
