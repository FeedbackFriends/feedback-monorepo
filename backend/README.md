# Feedback Backend

[![Kotlin](https://img.shields.io/badge/Kotlin-1.9.0-blue.svg)](https://kotlinlang.org)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.0-brightgreen.svg)](https://spring.io/projects/spring-boot)

Kotlin + Spring Boot services powering the LetsGrow feedback platform. Provides REST APIs and scheduled jobs for feedback management and notifications.

## Project Layout
-  – main REST API (controllers, services, configs, resources).
-  – background jobs and notification polling.
-  – shared entities/DTOs/enums and Jackson config.
-  – Exposed DAOs/repos and Liquibase change sets in .
-  – Firebase client wrapper.
-  – iCal parsing utilities for calendar invites.
-  – quick reference and diagrams ( PlantUML).

## Prerequisites
- JDK 21 (toolchain); Kotlin 1.9; Gradle wrapper included.
- Environment:  for Postgres, , , optional .
- Scheduler mail polling uses , , , plus OAuth refresh token + client credentials.
- Secrets: keep , Firebase service-account JSON, and any exported secrets out of git.

## Quick Start
API:


Scheduler:


For local Postgres:


## Deployment
Production deployment is defined in [../render.yaml](../render.yaml).

Render-specific assets:
- API Dockerfile: [./apps/api/Dockerfile](./apps/api/Dockerfile)
- Scheduler Dockerfile: [./apps/scheduler/Dockerfile](./apps/scheduler/Dockerfile)
- Render setup notes: [../render/README.md](../render/README.md)

The API and scheduler expect Firebase credentials via , which in Render should point at the mounted secret file path.

## Build, Test, and Tooling
-  – compile all modules and run tests (warnings fail build).
-  or  – run full or scoped tests.
-  – build the API image from [./apps/api/Dockerfile](./apps/api/Dockerfile).
-  – build the scheduler image from [./apps/scheduler/Dockerfile](./apps/scheduler/Dockerfile).
-  – start the full local stack with [../docker-compose.yml](../docker-compose.yml).

OpenAPI: auto-generated via Springdoc plugin; Swagger UI is served at  and the spec at  in the API service.

## Documentation
- [Getting Started](./docs/getting-started.md) – setup, environment, and common tasks.
- [Architecture Overview](./docs/overview.md) – module roles and request/notification flows.
- [Diagrams](./docs/diagrams/) – PlantUML diagrams; regenerate with your preferred UML tool.

## Contributing
- Follow the Kotlin style used in the codebase (4-space indent, idiomatic null-safety).
- Use concise, imperative commits (e.g., ); group related changes.
- Run  before opening a PR and include results plus any new env vars/migrations in the PR description.
