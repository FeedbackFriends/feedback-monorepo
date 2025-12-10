# Feedback Backend

[![OpenAPI](https://img.shields.io/badge/OpenAPI-3.0.0-green.svg)](https://github.com/FeedbackFriends/feedback-openapi/blob/main/openapi.yaml)
[![Kotlin](https://img.shields.io/badge/Kotlin-1.9.0-blue.svg)](https://kotlinlang.org)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.0-brightgreen.svg)](https://spring.io/projects/spring-boot)

Kotlin + Spring Boot services powering the LetsGrow feedback platform. Provides REST APIs and scheduled jobs for feedback management and notifications.

## Project Layout
- `apps/api` – main REST API (controllers, services, configs, resources).
- `apps/scheduler` – background jobs (reminders/notifications).
- `lib/model` – shared entities/DTOs/enums and Jackson config.
- `lib/persistence` – Exposed DAOs/repos and Liquibase change sets in `src/main/resources/db/changelog/`.
- `lib/firebase` – Firebase client wrapper.
- `docs/` – quick reference and diagrams (`docs/diagrams` PlantUML).

## Prerequisites
- JDK 21 (toolchain); Kotlin 1.9; Gradle wrapper included.
- Docker (optional) for running Postgres locally.
- Environment: `SPRING_DATASOURCE_URL/USERNAME/PASSWORD` for Postgres, `FIREBASE_API_KEY`, `FIREBASE_CONFIG_PATH`, `VERSION` (e.g., `0.0.5`), optional `SHOW_EXPOSED_SQL=true`.

## Quick Start (API)
```bash
cp firebase_config.json.example firebase_config.json   # if provided
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

## Build, Test, and Tooling
- `./gradlew clean build` – compile all modules and run tests (warnings fail build).
- `./gradlew test` or `./gradlew :apps:api:test` – run full or scoped tests (uses H2).
- `./gradlew jibDockerBuild` (per app) – build a Docker image if Docker is available.

OpenAPI: auto-generated via Springdoc plugin; visit `/` locally for Swagger UI or use the shared spec at [feedback-openapi](https://github.com/FeedbackFriends/feedback-openapi/blob/main/openapi.yaml).

## Documentation
- [Getting Started](./docs/getting-started.md) – setup, environment, and common tasks.
- [Architecture Overview](./docs/overview.md) – module roles and request/notification flows.
- [Diagrams](./docs/diagrams/) – PlantUML diagrams; regenerate with your preferred UML tool.

## Contributing
- Follow the Kotlin style used in the codebase (4-space indent, idiomatic null-safety).
- Use concise, imperative commits (e.g., `Add feedback summary endpoint`); group related changes.
- Run `./gradlew test` before opening a PR and include results plus any new env vars/migrations in the PR description.
