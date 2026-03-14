# Feedback Monorepo

This repository contains the Feedback platform as a single monorepo: the web app, the backend services, and the root-level infrastructure used to run and deploy them together.

The root of the repo is for shared orchestration only. Product work should usually happen inside `web/` or `backend/`.

## What Lives Here

- `web/` contains the Next.js frontend.
- `backend/` contains the Kotlin services, shared backend libraries, and database tooling.
- `docker-compose.yml` defines the production-like multi-service stack using published images.
- `docker-compose.override.yml` adds the local development overrides, including Postgres and a locally built web app.
- `.github/workflows/` contains CI and release automation.

## Tech Stack

### Frontend

- Next.js 14
- React 18
- TypeScript
- Tailwind CSS
- Radix UI / shadcn-style primitives
- Firebase client auth
- Playwright for end-to-end testing

### Backend

- Kotlin
- Spring Boot
- Gradle
- PostgreSQL
- Liquibase
- OpenAPI / Swagger
- Firebase integration
- Dedicated scheduler service for background jobs

### Infrastructure

- Docker Compose
- GitHub Actions
- Coolify for production deployment
- Published Docker images for `feedback-api`, `feedback-scheduler`, and `feedback-web`

## Repository Structure

```text
.
|-- web/                    # Frontend app
|-- backend/                # API, scheduler, shared backend code, DB tooling
|-- docker-compose.yml      # Base stack using published production images
|-- docker-compose.override.yml
|-- .github/workflows/      # CI/CD pipelines
|-- AGENTS.md               # Root-level repo working rules
```

App-specific instructions live in:

- `web/README.md`
- `backend/README.md`
- `web/AGENTS.md`
- `backend/AGENTS.md`

## Local Development

For full-stack local development from the repo root:

```bash
docker compose up --build
```

Useful root-level commands:

```bash
docker compose down
docker compose logs -f
docker compose ps
```

How local Compose is wired:

- `docker-compose.yml` uses the published production-style images and shared environment variables.
- `docker-compose.override.yml` adds a local Postgres container, exposes ports, points backend services at the local database, and builds the web app from `./web`.

For feature work inside a single app, switch into that app directory and use its local README and AGENTS instructions.

## Environment

Compose reads variables from the root `.env` file when present.

Typical values stored there include:

- database credentials and port overrides
- Firebase configuration
- JWT / auth configuration
- Docker image platform settings
- public frontend variables prefixed with `NEXT_PUBLIC_`

Rules:

- never commit real secrets
- keep secrets in `.env`, GitHub secrets, or Coolify-managed environment variables
- treat `NEXT_PUBLIC_*` values as client-exposed

## Deployment

Production deployment is handled through Coolify, not local Compose.

Important deployment assumptions:

- production should pull the mutable `prod` image tags
- root deployment changes should stay aligned with the current Coolify setup
- infrastructure changes should call out any new env vars, ports, domains, or image changes

## CI/CD

GitHub Actions in `.github/workflows/` handle validation and releases.

- `ci.yml` runs backend build/tests plus web install, lint, and build
- `release.yml` builds and publishes Docker images, generates OpenAPI output, creates a GitHub release, and triggers deployment

## Where To Work

- Work in `web/` for frontend routes, components, and UI behavior.
- Work in `backend/` for API logic, scheduler jobs, database changes, and backend integrations.
- Keep root changes focused on documentation, Docker Compose, CI/CD, and deployment wiring.
