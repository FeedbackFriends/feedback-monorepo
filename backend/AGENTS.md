# Backend Guidelines

## Scope
Work in `backend/` for Kotlin API, scheduler, persistence, migrations, Firebase/Zoho integrations, OpenAPI source generation, and backend tests.

Keep work in this subtree focused on backend services. If an API shape changes, regenerate the root contract and generated client artifacts from the monorepo root.

## Project Structure
- `apps/api/`: Spring Boot REST API, controllers, services, configuration, auth, and OpenAPI generation.
- `apps/scheduler/`: background jobs, notification polling, and delayed work.
- `lib/model/`: shared DTOs, enums, entities, serialization, and API-facing models.
- `lib/persistence/`: Exposed repositories/DAOs and Liquibase migrations.
- `lib/firebase/`: Firebase integration helpers.
- `lib/ical-parser/`: iCal parsing utilities.
- `docs/`: backend architecture notes and PlantUML diagrams.

Tests live next to their modules under `src/test/kotlin`. API and persistence tests are the main integration coverage points.

## Build And Test Commands
Run these from `backend/` unless noted otherwise:

```bash
./gradlew clean build
./gradlew test
./gradlew :api:test
./gradlew :persistence:test
./gradlew :scheduler:bootRun
./gradlew --no-configuration-cache buildLocalImages
SPRING_PROFILES_ACTIVE=openapi ./gradlew syncOpenApiSpec --no-configuration-cache
```

Generate the backend contract and committed client artifacts from the monorepo root:

```bash
./scripts/generate-api-artifacts.sh
```

## OpenAPI Contract
- Backend controllers, DTOs, and OpenAPI configuration are the source of truth.
- `syncOpenApiSpec` writes `contracts/openapi/feedback-api.yaml`.
- Do not hand-edit `contracts/openapi/feedback-api.yaml` or generated client artifacts.
- After endpoint, request, response, enum, or error-shape changes, regenerate API artifacts and update affected call sites if needed.

## Coding Style
- Kotlin with the configured JVM toolchain. Use idiomatic null-safety, data classes for payloads, and 4-space indentation.
- Keep package structure organized by layer: controllers/configuration in `apps/api`, jobs in `apps/scheduler`, shared models in `lib/model`, persistence in `lib/persistence`.
- Controllers should stay thin and delegate business logic to services.
- Services should map between domain/API concepts and persistence repositories.
- Use constructor injection with `val` dependencies.
- Prefer straight-line flows, guard clauses, and explicit exceptions over fallback behavior.
- Keep logs useful and low-noise. Do not log secrets, tokens, Firebase service account values, or Zoho credentials.
- Warnings fail the build; fix them before finishing.

## Persistence And Migrations
- Postgres is the runtime database.
- Liquibase changelogs live in `lib/persistence/src/main/resources/db/changelog/`.
- Add new changelogs incrementally. Do not edit existing applied changelogs unless the user explicitly asks and the migration has not been shared.
- Add DAO/repository tests for persistence behavior and migration-sensitive changes.

## Testing Guidelines
- Primary framework: JUnit 5.
- Use MockMvc and existing integration helpers for API behavior.
- Use scenario-style backtick test names where the surrounding tests do.
- For bug fixes, prefer a failing test that reproduces the issue before changing behavior.

## Runtime And Environment
- Local full-stack runtime is orchestrated from the monorepo root with `./scripts/run`.
- Direct service runs require the same environment contract described in `backend/README.md` and the root `.env.example`.
- Keep secrets out of source control. Treat Firebase and Zoho values as secrets.

## Validation Expectations
- Narrow backend logic change: run the relevant module test task.
- Persistence or migration change: run persistence tests and any affected API tests.
- API contract change: run `./scripts/generate-api-artifacts.sh` from the root and inspect the generated diff.
- Docker/runtime change: run the relevant Gradle image task or root Compose command.
