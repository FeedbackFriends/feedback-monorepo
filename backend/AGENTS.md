# LetsGrow backend

Kotlin backend for LetsGrow: Spring Boot API, scheduler, Postgres persistence, and integrations.

Use the Gradle wrapper from `backend/`; warnings fail the build.

## Commands

- Build: `./gradlew clean build`
- Test: `./gradlew test` or the affected module task, such as `./gradlew :api:test`.
- Build local images: `./gradlew --no-configuration-cache buildLocalImages`.
- Regenerate the contract and clients from the monorepo root: `./scripts/shared/generate-api-artifacts.sh`.

## Architecture and conventions

### Project Structure

- `apps/api/`: Spring Boot REST API, controllers, services, configuration, auth, and OpenAPI generation.
- `apps/scheduler/`: background jobs, notification polling, and delayed work.
- `lib/model/`: shared DTOs, enums, entities, serialization, and API-facing models.
- `lib/persistence/`: Exposed repositories/DAOs and Liquibase migrations.
- `lib/firebase/`: Firebase integration helpers.
- `lib/ical-parser/`: iCal parsing utilities.
- `../docs/backend/`: backend architecture notes and PlantUML diagrams.

Tests live next to their modules under `src/test/kotlin`. API and persistence tests are the main integration coverage points.

### Coding Style

- Kotlin with the configured JVM toolchain. Use idiomatic null-safety, data classes for payloads, and 4-space indentation.
- Keep package structure organized by layer: controllers/configuration in `apps/api`, jobs in `apps/scheduler`, shared models in `lib/model`, persistence in `lib/persistence`.
- Controllers should stay thin and delegate business logic to services.
- Services should map between domain/API concepts and persistence repositories.
- Use constructor injection with `val` dependencies.
- Prefer straight-line flows, guard clauses, and explicit exceptions over fallback behavior.
- Do not log secrets, tokens, Firebase service account values, or Zoho credentials.

### Account access

- `Role.Manager` is the only named account role; anonymous feedback users have no role.
- Session participation and feedback records are independent of account roles.
- Role switching (`PUT /account/role`) has been removed.

### Team access

Organization creators own all organization teams. Additional leaders have one database assignment to one team; only the owner creates teams or changes leaders. Check current database authority on every team request, never legacy Manager claims. Personal leader invitations require the matching verified email and expire after seven days; employee invitation codes remain separate.

Supabase Auth is verified by the API against its project JWKS and user endpoint. See [setup/cutover](../docs/shared/authentication.md#supabase-auth-setup-and-cutover). `authenticated` is a provider role, never a team role. Nonanonymous sessions retain the existing personal-meeting Manager capability; team authority remains stored ownership/assignment.

## API contract

- Backend controllers, DTOs, and OpenAPI configuration are the source of truth.
- `syncOpenApiSpec` writes `contracts/openapi/feedback-api.yaml`.
- Do not hand-edit the contract or generated clients; see the [shared API contract guide](../AGENTS.md#api-contract).
- After endpoint, request, response, enum, or error-shape changes, regenerate with `./scripts/shared/generate-api-artifacts.sh` from the monorepo root and update affected call sites.

## Runtime and environment

- Local full-stack runtime is orchestrated from the monorepo root with `./scripts/shared/reset-and-start-local-stack.sh`.
- Direct service runs require the same environment contract described in `backend/README.md` and the root `.env.example`.
- Keep secrets out of source control. Treat Supabase secret keys, SMTP credentials, Firebase service accounts and Zoho values as secrets.
- Configure managed auth, mail, native clients and cutover through [Supabase auth setup](../docs/shared/authentication.md#supabase-auth-setup-and-cutover).

## Persistence and migrations

Paths and commands are relative to `backend/` unless stated otherwise.

### Persistence And Migrations

- Postgres is the runtime database.
- Liquibase changelogs live in `lib/persistence/src/main/resources/db/changelog/`.
- Add new changelogs incrementally. Do not edit existing applied changelogs unless the user explicitly asks and the migration has not been shared.
- Add DAO/repository tests for persistence behavior and migration-sensitive changes.

For database-specific query plans, indexing, connection management, and locking, consult [Postgres best practices](../.agents/skills/supabase-postgres-best-practices/SKILL.md). Keep Exposed repositories and incremental Liquibase changelogs as the implementation owners. Evaluate recommendations against actual queries, constraints, and plans; example speedups are not measurements of this application. The skill does not select Supabase hosting, an auth provider, or a new RLS architecture.

## Backend commands and validation

Paths and commands are relative to `backend/` unless stated otherwise.

### Build And Test Commands

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
./scripts/shared/generate-api-artifacts.sh
```

### Testing Guidelines

- Primary framework: JUnit 5.
- Use MockMvc and existing integration helpers for API behavior.
- Use scenario-style backtick test names where the surrounding tests do.
- For bug fixes, prefer a failing test that reproduces the issue before changing behavior.

### Validation Expectations

- Narrow backend logic change: run the relevant module test task.
- Persistence or migration change: run persistence tests and any affected API tests.
- API contract change: run `./scripts/shared/generate-api-artifacts.sh` from the root and inspect the generated diff.
- Docker/runtime change: run the relevant Gradle image task or root Compose command.
