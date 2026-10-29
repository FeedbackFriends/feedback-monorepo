# LetsGrow

LetsGrow is a feedback-after-meetings product with a Next.js web app, Kotlin backend, and SwiftUI/TCA iOS app in one monorepo.

- Read the nearest app `AGENTS.md` before editing its subtree.
- Do not commit or push unless the user explicitly asks.

## Repository commands

Run from the monorepo root:

- `./scripts/generate-api-artifacts.sh`: regenerate the backend OpenAPI contract and TypeScript/Swift clients; never hand-edit generated API artifacts.
- `./scripts/run` (or `./scripts/run -d`): rebuild and start the local stack; this resets Compose volumes. Read the runtime guide before use.

## Read when relevant

| Task | Guidance |
| --- | --- |
| Web frontend | [web/AGENTS.md](web/AGENTS.md) |
| Backend API, scheduler, or persistence | [backend/AGENTS.md](backend/AGENTS.md) |
| iOS app | [ios-app/AGENTS.md](ios-app/AGENTS.md) |
| File ownership or shared implementation conventions | [Repository scope](docs/agents/repository-scope.md) |
| API shape or generated clients | [API contract](docs/agents/api-contract.md) |
| Docker, environment, or production deployment | [Runtime and deployment](docs/agents/runtime-and-deployment.md) |
| GitHub Actions or release automation | [CI/CD](docs/agents/ci-cd.md) |
| iOS build, test, launch, or verification, including from the root | [iOS workflows](docs/agents/ios-workflows.md) |
| Browser access or website authentication | [Browser access](docs/agents/browser-access.md) |
