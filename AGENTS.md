# LetsGrow

LetsGrow is a feedback-after-meetings product with a Next.js web app, Kotlin backend, and SwiftUI/TCA iOS app in one monorepo.

- Both Codex and Claude Code are actively used. Maintain shared guidance and working discovery/tool configuration for both clients.
- Read the nearest app `AGENTS.md` before editing its subtree.
- Do not commit or push unless the user explicitly asks. After implementation, required verification, and the human-review handoff are complete, briefly explain what was implemented (before/after behavior when useful), list the files proposed for committing, then ask "Should I commit?" with explicit Yes/No choices unless the user already authorized or declined committing that work. When proposing a push, also identify the branch and commits/files it would include. Finish all work and present the complete summary, verification results, and proposed files before opening the commit picker. Make the picker the last interaction before waiting for the answer; do not follow it with another summary. Use the client’s native selectable Yes/No picker, including an Up/Down and Enter terminal picker when available and permitted in the current mode. Prefer selecting an option over requiring a typed reply. If no supported picker is available, show explicit Yes/No choices in the final response. A Yes authorizes committing the completed work; pushing requires separate explicit authorization.
- Follow existing coding standards and patterns by default. Implementation handoffs should make architectural decisions easy for a human to review; use the [human review guide](.agents/skills/lg-implement/SKILL.md#prepare-the-human-review).
- Finish implementation by running the relevant automated tests and required lint/build checks. If they pass, hand off for human manual testing; manual journeys, simulator interaction, and visual review do not block implementation completion. Run those checks only when explicitly requested. This completion policy takes precedence over platform guides and older task verification plans. Report failures or unavailable checks honestly.
- Keep the backlog in root `todos.md`: one plain Markdown list item with one or two short, nontechnical lines; no checkboxes. The list is prioritized from highest to lowest; preserve its order unless the user asks to reprioritize. Add todos only when the user explicitly asks. Use `lg-refine` to grill requirements and architecture in the conversation before implementation; keep technical plans and verification out of the backlog. Remove completed items after verification and handoff. Never use GitHub Issues or Projects for LetsGrow task management.

## Repository commands

Run from the monorepo root:

- `./scripts/shared/generate-api-artifacts.sh`: regenerate the backend OpenAPI contract and TypeScript/Swift clients; never hand-edit generated API artifacts.
- `./scripts/shared/run` (or `./scripts/shared/run -d`): rebuild and start the local stack; this resets Compose volumes. Read the runtime guide before use.

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
