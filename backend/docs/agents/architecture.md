# Backend architecture and conventions

Paths and commands are relative to `backend/` unless stated otherwise.

## Project Structure

- `apps/api/`: Spring Boot REST API, controllers, services, configuration, auth, and OpenAPI generation.
- `apps/scheduler/`: background jobs, notification polling, and delayed work.
- `lib/model/`: shared DTOs, enums, entities, serialization, and API-facing models.
- `lib/persistence/`: Exposed repositories/DAOs and Liquibase migrations.
- `lib/firebase/`: Firebase integration helpers.
- `lib/ical-parser/`: iCal parsing utilities.
- `docs/`: backend architecture notes and PlantUML diagrams.

Tests live next to their modules under `src/test/kotlin`. API and persistence tests are the main integration coverage points.

## Coding Style

- Kotlin with the configured JVM toolchain. Use idiomatic null-safety, data classes for payloads, and 4-space indentation.
- Keep package structure organized by layer: controllers/configuration in `apps/api`, jobs in `apps/scheduler`, shared models in `lib/model`, persistence in `lib/persistence`.
- Controllers should stay thin and delegate business logic to services.
- Services should map between domain/API concepts and persistence repositories.
- Use constructor injection with `val` dependencies.
- Prefer straight-line flows, guard clauses, and explicit exceptions over fallback behavior.
- Do not log secrets, tokens, Firebase service account values, or Zoho credentials.
