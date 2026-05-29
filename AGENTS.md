# Repository Guidelines

## Scope
This is the LetsGrow monorepo. Root-level work is for shared orchestration and repository infrastructure only:

- Docker Compose and runtime wiring
- root scripts
- GitHub Actions and release automation
- generated API contracts under `contracts/openapi/`
- repository documentation and deployment notes

Product features belong in the app that owns them:

- `web/`: Next.js frontend. Follow `web/AGENTS.md` for routes, components, client auth, generated TypeScript API types, and frontend tests.
- `backend/`: Kotlin API, scheduler, persistence, migrations, integrations, and canonical OpenAPI source. Follow `backend/AGENTS.md`.
- `ios-app/`: SwiftUI/TCA iOS app, adapters, generated Swift OpenAPI sources, and Maestro flows. Follow `ios-app/AGENTS.md`.

## Architecture Rules
- The backend is the source of truth for API shape. Backend controllers, DTOs, and OpenAPI config generate `contracts/openapi/feedback-api.yaml`.
- The committed OpenAPI contract feeds `web/src/lib/api/generated/openapi.ts` and `ios-app/Modules/Sources/OpenAPI/GeneratedSources/`.
- Never hand-edit generated API artifacts. Regenerate them from the root with `./scripts/generate-api-artifacts.sh`.
- Keep root changes focused on shared infrastructure. Do not implement app behavior from the root.
- Prefer deterministic, single-path behavior. Throw clear errors instead of adding fallback logic or special-case recovery.

## Docker Compose
Root Docker files orchestrate the full stack:

- `docker-compose.yml`: production-like base stack using published `feedback-api:prod`, `feedback-scheduler:prod`, and `feedback-web:prod` images plus the shared environment contract.
- `docker-compose.override.yml`: local development override. It adds local development wiring, published ports, and local images.

Default root commands:

```bash
./scripts/run
./scripts/run -d
docker compose down
docker compose logs -f
docker compose ps
```

## Environment
Compose reads variables from a root `.env` file when present.

Rules:

- keep secrets in `.env`, GitHub secrets, or Coolify-managed environment variables
- never commit real secret values
- treat `NEXT_PUBLIC_*` values as client-exposed
- treat `COOLIFY_TOKEN` as a secret and never expose it in logs, docs, or commits

When adding or changing runtime configuration, call out new environment variables, ports, domains, image tags, or deployment assumptions.

## Deployment
Production deployment uses Coolify, not local Compose. Keep deployment changes aligned with the current Coolify setup and image tags.

- production runtime should pull mutable `prod` image tags
- infrastructure and cost changes are review-sensitive
- local Compose behavior and Coolify runtime expectations should stay consistent

## GitHub Actions / CI/CD
GitHub Actions live in `.github/workflows/` and are root-owned infrastructure.

- `ci.yml`: validates backend, web, and generated API artifacts
- `release.yml`: runs release validation, builds and publishes Docker images, creates a GitHub release, and triggers Coolify deployment

When editing workflows:

- keep triggers, permissions, caches, and concurrency intentional
- call out new required secrets or external integrations
- keep changes small and easy to review
- validate with `git diff -- .github/workflows` and any relevant local commands

## Working Rules
- Read the nearest `AGENTS.md` before editing a subtree.
- Use two-space indentation in YAML.
- Prefer explicit config over clever indirection.
- Do not modify generated files unless the change is the result of the repo's generation scripts.
- Do not commit or push unless the user explicitly asks.
