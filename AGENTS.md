# LetsGrow

LetsGrow is a feedback-after-meetings product with a Next.js web app, Kotlin backend, and SwiftUI/TCA iOS app in one monorepo.

- Read the nearest app `AGENTS.md` before editing its subtree.
- Do not commit or push unless the user explicitly asks.
- Follow existing coding standards and patterns by default. Implementation handoffs should make architectural decisions easy for a human to review; use the [human review guide](docs/agents/human-review.md).
- Use root `tasks/` for unfinished task management; delete a task file when its acceptance and required verification are complete, after preparing the final human-review handoff; never use GitHub Issues or GitHub Projects for LetsGrow tasks. Refine → save a Markdown task plan → implement. Use the create-task skill for the required structure, including phases for large tasks. Generic issue-refinement workflows must write local task files instead of GitHub issues.

## Repository commands

Run from the monorepo root:

- `./scripts/generate-api-artifacts.sh`: regenerate the backend OpenAPI contract and TypeScript/Swift clients; never hand-edit generated API artifacts.
- `./scripts/run` (or `./scripts/run -d`): rebuild and start the local stack; this resets Compose volumes. Read the runtime guide before use.

## Read when relevant

| Task | Guidance |
| --- | --- |
| Web frontend | [web/AGENTS.md](web/AGENTS.md) |
| Backend API, scheduler, or persistence | [backend/AGENTS.md](backend/AGENTS.md) |
| Task creation, refinement, implementation, verification, review, or handoff | [Shared task workflow](docs/agents/task-workflow.md) and [create-task skill](.agents/skills/lg-create-task/SKILL.md) |
| iOS app | [ios-app/AGENTS.md](ios-app/AGENTS.md) |
| iOS feature refinement, implementation, Swift, review, or investigation | [iOS feature workflow](ios-app/Docs/agents/feature-workflow.md) |
| File ownership or shared implementation conventions | [Repository scope](docs/agents/repository-scope.md) |
| API shape or generated clients | [API contract](docs/agents/api-contract.md) |
| Docker, environment, or production deployment | [Runtime and deployment](docs/agents/runtime-and-deployment.md) |
| GitHub Actions or release automation | [CI/CD](docs/agents/ci-cd.md) |
| iOS build, test, launch, or verification, including from the root | [iOS workflows](docs/agents/ios-workflows.md) |
| Browser access or website authentication | [Browser access](docs/agents/browser-access.md) |
