# Feedback Backend

[![Kotlin](https://img.shields.io/badge/Kotlin-1.9.0-blue.svg)](https://kotlinlang.org)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.0-brightgreen.svg)](https://spring.io/projects/spring-boot)

Kotlin + Spring Boot services powering the LetsGrow feedback platform. Provides REST APIs and scheduled jobs for feedback management and notifications.

## Project Layout
- `apps/api` – main REST API (controllers, services, configs, resources).
- `apps/scheduler` – background jobs (reminders/notifications).
- `lib/model` – shared entities/DTOs/enums and Jackson config.
- `lib/persistence` – Exposed DAOs/repos and Liquibase change sets in `src/main/resources/db/changelog/`.
- `lib/firebase` – Firebase client wrapper.
- `lib/ical-parser` – iCal parsing utilities for calendar invites.
- `docs/` – quick reference and diagrams (`docs/diagrams` PlantUML).

## Prerequisites
- JDK 21 (toolchain); Kotlin 1.9; Gradle wrapper included.
- Docker (optional) for running Postgres locally.
- Environment: `SPRING_DATASOURCE_URL/USERNAME/PASSWORD` for Postgres, `FIREBASE_API_KEY`, `FIREBASE_CONFIG_PATH`, optional `SHOW_EXPOSED_SQL=true`. Scheduler mail polling uses `ZOHO_ACCOUNT_ID`, `ZOHO_FOLDER_ID`, plus OAuth refresh token + client credentials. Base version is set in `gradle.properties` (CI appends build metadata).
- Secrets: copy `.env.example` and `firebase_config.json.example` to `.env` and `firebase_config.json`, then fill in real values. Keep those files out of git.

## Quick Start (API)
```bash
cp firebase_config.json.example firebase_config.json   # if provided
cp .env.example .env                                   # add env vars for local runs
./gradlew :apps:api:bootRun                            # starts on :8080, H2 in-memory by default
# or point to Postgres
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/feedback \
SPRING_DATASOURCE_USERNAME=feedback \
SPRING_DATASOURCE_PASSWORD=secret \
./gradlew :apps:api:bootRun
```

Scheduler service:
```bash
./gradlew :apps:scheduler:bootRun
```

## Docker Compose
The Compose setup runs both services from prebuilt images. Local helper scripts derive per-service image tags from `VERSION=local` in `.env`, while CI sets real tags during deploys.
Ensure `.env` includes `ZOHO_ACCOUNT_ID`, `ZOHO_FOLDER_ID`, and OAuth settings for the scheduler mail poller.

```bash
docker compose -f infra/docker-compose.yml up -d
```

Local Jib builds:
- Jib tags images with `project.version`. For local builds, set `VERSION=local` in `.env` and build with `-Pversion=local` so the helper scripts can pass the same tag to Compose.

```bash
./gradlew :api:jibDockerBuild :scheduler:jibDockerBuild --no-configuration-cache
docker compose -f infra/docker-compose.yml up -d
```

CI behavior:
- CI injects a real version (run number + short SHA) via `-Pversion=...`, and Jib tags images with that value.
- `infra/docker-compose.yml` consumes `API_VERSION`, `SCHEDULER_VERSION`, and `WEB_VERSION`, with web deploys updating only `WEB_VERSION`.

## CI Pipeline (GitHub Actions)
The deploy workflow computes `FULL_VERSION=run_number-short_sha`, builds and pushes the web image, then deploys only `web` via Docker Compose on the Debian host.

## Build, Test, and Tooling
- `./gradlew clean build` – compile all modules and run tests (warnings fail build).
- `./gradlew test` or `./gradlew :apps:api:test` – run full or scoped tests (uses H2).
- `./gradlew jibDockerBuild` (per app) – build a Docker image if Docker is available.

OpenAPI: auto-generated via Springdoc plugin; Swagger UI is served at `/` and the spec at `/v3/api-docs` in this service.

## Documentation
- [Getting Started](./docs/getting-started.md) – setup, environment, and common tasks.
- [Architecture Overview](./docs/overview.md) – module roles and request/notification flows.
- [Diagrams](./docs/diagrams/) – PlantUML diagrams; regenerate with your preferred UML tool.

## Contributing
- Follow the Kotlin style used in the codebase (4-space indent, idiomatic null-safety).
- Use concise, imperative commits (e.g., `Add feedback summary endpoint`); group related changes.
- Run `./gradlew test` before opening a PR and include results plus any new env vars/migrations in the PR description.
