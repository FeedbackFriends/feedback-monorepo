# Repository Guidelines

## Scope
This is a monorepo. Root-level work should stay limited to shared tooling, Docker Compose, GitHub Actions, CI/CD, documentation, and deployment wiring.

Do not implement product features from the root when they belong inside an app:
- `web/`: frontend app. Follow `web/AGENTS.md` for UI, Next.js, routes, components, and frontend build work.
- `backend/`: API and scheduler. Follow `backend/AGENTS.md` for Kotlin, database, migrations, and service logic.

## Docker Compose
Root Docker files orchestrate the full stack together:
- `docker-compose.yml`: base stack. Uses the published `feedback-api`, `feedback-scheduler`, and `feedback-web` images and shared environment variables. This is the production-like Compose definition and includes the external `coolify` network.
- `docker-compose.override.yml`: local development override. Adds Postgres, publishes ports, points backend services at the local database, and builds the web app from `./web`.

Default root commands:
- `docker compose up --build`: start the local stack with the override applied.
- `docker compose down`: stop the stack.
- `docker compose logs -f`: stream logs.
- `docker compose ps`: inspect service state.

## Environment
Compose reads variables from a root `.env` file if present. Use it for local configuration such as database credentials, host ports, image tags, Firebase values, and other runtime settings.

Rules:
- keep secrets in `.env`, GitHub secrets, or Coolify-managed env vars
- never commit real secret values
- treat `NEXT_PUBLIC_*` values as client-exposed
- `COOLIFY_TOKEN` in `.env` can be used for authenticated calls to the Coolify API from local scripts or automation; treat it as a secret and never expose it in logs or commits

## Deployment
Production deployment uses Coolify, not local Compose. Keep root deployment changes aligned with the current Coolify setup and image tags.

When changing deployment-related files:
- call out any new env vars, ports, domains, or image changes
- treat cost or infrastructure changes as review-sensitive
- keep local Compose behavior and Coolify runtime expectations consistent

## GitHub Actions / CI/CD
GitHub Actions live in `.github/workflows/` and are root-owned infrastructure.
- `ci.yml`: runs backend build/tests and web install/lint/build for pull requests and pushes to `main`
- `release.yml`: builds and publishes Docker images, generates OpenAPI output, creates a GitHub release, and triggers Coolify deployment

When editing workflows:
- keep triggers, permissions, caches, and concurrency intentional
- call out any new required secrets or external integrations
- keep changes small and easy to review

## Working Rules
- keep root changes focused on orchestration and shared infrastructure
- use two-space indentation in YAML
- prefer explicit config over clever indirection
- validate root changes with `git diff -- .github/workflows` and relevant `docker compose` commands
