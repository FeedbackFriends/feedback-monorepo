# Feedback Monorepo

This repository contains the Feedback frontend, backend, and root-level infrastructure and automation used to run them together.

## Repository Layout
- `web/`: frontend application and frontend-specific tooling.
- `backend/`: API, scheduler, shared backend modules, and backend-specific tooling.
- `render.yaml`: Render Blueprint for production infrastructure.
- `docker-compose.yml`: local multi-service entry point for running the stack together from the repo root.
- `.github/workflows/`: CI and release automation.

Application development should happen from `web/` or `backend/`, each of which has its own local `AGENTS.md` and workflow. The root is mainly for repo-wide orchestration, CI/CD, shared docs, Docker Compose, and Render configuration.

## Local Development
For full-stack smoke testing from the monorepo root:
- `docker compose up --build`

For feature work or app-specific debugging:
1. Change into `web/` for frontend tasks.
2. Change into `backend/` for backend tasks.
3. Follow the local instructions in that folder's `AGENTS.md`.

If you need Render access from your local shell, add `export RENDER_API_KEY=...` to `~/.zshrc` and reload your shell. If you run Render-related commands through an agent, provide `RENDER_API_KEY` in the agent environment instead.

## Deployment
Production deployment is defined by [render.yaml](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/render.yaml).

The active Render Blueprint defines:
- the `feedback-api` web service
- the `feedback-scheduler` background worker
- the `feedback-web` web service
- the `feedback-db` managed Postgres instance

Backend container builds use [backend/apps/api/Dockerfile](/Users/nicolaidam/Documents/Projects/Feedback/feedback-monorepo/backend/apps/api/Dockerfile) and [backend/apps/scheduler/Dockerfile](/Users/nicolaidam/Documents/Projects/Feedback/feedback-monorepo/backend/apps/scheduler/Dockerfile). The frontend container build lives in [web/Dockerfile](/Users/nicolaidam/Documents/Projects/Feedback/feedback-monorepo/web/Dockerfile).

Render is the production deployment target. Changes to `render.yaml` should be treated as production-sensitive because they affect build behavior, runtime configuration, service plans, and database wiring.

Current cost posture:
- `feedback-api` uses Render `free`.
- `feedback-web` uses Render `free`.
- `feedback-scheduler` uses Render `starter`.
- `feedback-db` uses `basic-256mb`.

Free-tier tradeoffs:
- `feedback-api` and `feedback-web` can spin down after idle periods and incur cold starts.
- This setup is acceptable for low-traffic production or pre-launch use, but it is not a zero-latency production setup.
- The first infrastructure upgrade should be moving the API and web services from `free` to `starter`.

## GitHub Actions
GitHub Actions configuration lives in [`.github/workflows/ci.yml`](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/.github/workflows/ci.yml) and [`.github/workflows/release.yml`](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/.github/workflows/release.yml).

Current workflow behavior:
- `ci.yml` runs on pushes to `main` and on pull request open, sync, and reopen events.
- CI builds and tests the backend with Gradle, then installs, lints, and builds the web app with npm.
- `release.yml` runs automatically after a successful `CI ✅` run on `main`, publishes Docker images with both immutable and `prod` tags, generates OpenAPI output, and creates GitHub releases.
- Dependabot configuration lives in [`.github/dependabot.yml`](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/.github/dependabot.yml) and currently manages Gradle dependency updates.

When updating GitHub Actions:
- keep workflow names, triggers, permissions, and cache behavior intentional
- review whether a change affects PR validation, `main` branch protection, or Render deployment readiness
- call out any new required secrets, tokens, or package registry permissions

## Validation
Useful root-level checks:
- `docker compose up --build`
- `git diff -- render.yaml`
- `git diff -- .github/workflows`

App-specific validation should be run from `web/` or `backend/` using the commands documented in those directories.
