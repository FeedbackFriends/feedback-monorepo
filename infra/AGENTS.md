# Repository Guidelines

## Project Structure & Module Organization
`infra/` contains deployment assets for the Feedback monorepo. [`render.yaml`](./render.yaml) defines `feedback-api`, `feedback-scheduler`, `feedback-web`, and `feedback-db`. The referenced services live in `../backend/apps/api`, `../backend/apps/scheduler`, and `../web`; local stack wiring lives in `../docker-compose.yml`.

## Service Inventory
- `feedback-api`: Render `web` service, `runtime: docker`, built from repo root with `backend/apps/api/Dockerfile`. Public Spring Boot API on the free plan with health check `/actuator/health`.
- `feedback-scheduler`: Render `worker` service, `runtime: docker`, built from repo root with `backend/apps/scheduler/Dockerfile`. Runs background polling and scheduled jobs on the starter plan.
- `feedback-web`: Render `web` service, `runtime: docker`, built from `./web` with `./web/Dockerfile`. Public Next.js frontend on the free plan with health check `/api/health`.
- `feedback-db`: managed Postgres database on `basic-256mb`, currently PostgreSQL 18.

## Build, Test, and Local Commands
- `docker compose up --build` from the monorepo root starts Postgres, API, scheduler, and web with the same Dockerfiles Render uses.
- `cd ../backend && ./gradlew build` compiles backend modules and runs JVM tests.
- `cd ../backend && ./gradlew test` runs backend tests only.
- `cd ../web && npm run lint` checks the Next.js frontend with ESLint.
- `cd ../web && npm run build` verifies the production web bundle.

## Deployment Rules
Render deploys from Git after CI passes, not from prebuilt registry images. Even though CI may publish artifacts elsewhere, Render builds fresh Docker images from this repository using each service's `dockerContext` and `dockerfilePath`. Keep `autoDeployTrigger: checksPass` aligned with `.github/workflows/ci.yml`. The API and scheduler rebuild only when `backend/**` or `render.yaml` changes; the frontend rebuilds only when `web/**` or `render.yaml` changes. Health checks must remain `/actuator/health` for `feedback-api` and `/api/health` for `feedback-web`.

Current cost posture is intentional: `feedback-api` and `feedback-web` stay on Render `free`, while `feedback-scheduler` stays on `starter` because workers do not have a free tier. Cold starts on the public web services are expected until those plans are upgraded.

## Render Tooling
Use the `render-deploy` skill for Render-focused work in this repo, especially when changing the Blueprint, validating deployment assumptions, or investigating production behavior. The Render MCP can inspect live state without opening the dashboard: `list_services`, `get_service`, `list_deploys`, `get_deploy`, `list_logs`, and `get_metrics` are the main debugging tools here. Prefer read-only MCP actions first when debugging production. Before any mutating Render action, confirm the selected workspace is correct and note any manual dashboard follow-up in the PR.

## Coding Style & Naming Conventions
Use 2-space indentation in YAML and keep keys ordered consistently: service identity first, then build settings, then routing, then `envVars`. Keep Render resource names on the existing `feedback-*` prefix. Prefer `fromDatabase` for Postgres wiring and `sync: false` for secrets. Comments should stay brief and operational.

## Testing Guidelines
This directory has no standalone test harness. Validate infra changes by confirming Dockerfile paths, `buildFilter.paths`, domains, and health endpoints still match the monorepo. For application-side verification, rely on backend JUnit 5 tests (`*Test.kt`, `*Tests.kt`, `E2ETest.kt`) and the frontend lint/build checks above.

## Commit & Pull Request Guidelines
Recent commits use short, imperative subjects such as `Fix Render web host binding` and `Harden Render deployment workflow`. Keep each commit scoped to one deployment concern. PRs should describe Blueprint changes, list new environment variables or secret mounts, and call out manual Render follow-up when required.

## Security & Configuration Tips
Never commit real secrets, `.env` values, or Firebase credentials. Keep `firebase_config.json` mounted at `/etc/secrets/firebase_config.json` for both `feedback-api` and `feedback-scheduler`, with `FIREBASE_CONFIG_PATH` pointing there. Set all `sync: false` values manually in Render. If logs show a missing Firebase config file, the secret-file mount is wrong. If auto-deploy stops after merges, check `main` branch CI status first. Keep Liquibase enabled for the scheduler in Render so startup ordering does not break database initialization.
