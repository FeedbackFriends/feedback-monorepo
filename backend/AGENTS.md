# LetsGrow backend

Kotlin backend for LetsGrow: Spring Boot API, scheduler, Postgres persistence, and integrations.

Use the Gradle wrapper from `backend/`; warnings fail the build.

## Commands

- Build: `./gradlew clean build`
- Test: `./gradlew test` or the affected module task, such as `./gradlew :api:test`.
- Build local images: `./gradlew --no-configuration-cache buildLocalImages`.
- Regenerate the contract and clients from the monorepo root: `./scripts/shared/generate-api-artifacts.sh`.

## Read when relevant

| Task | Guidance |
| --- | --- |
| Task refinement, implementation, review, or handoff | [Shared task workflow](../docs/shared/agents/task-workflow.md) |
| Kotlin implementation or module ownership | [Architecture and conventions](#architecture-and-conventions) |
| Endpoints, DTOs, or generated contracts | [API contract](#api-contract) |
| Database, DAO, or migration changes | [Persistence](../docs/backend/agents/persistence.md) |
| Build, tests, or validation | [Commands and validation](../docs/backend/agents/validation.md) |
| Service startup or environment | [Runtime](#runtime-and-environment) |

Repository-wide rules remain in the [root AGENTS.md](../AGENTS.md).

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

Supabase Auth is verified by the API against its project JWKS and user endpoint. See [setup/cutover](../docs/shared/agents/supabase-auth.md). `authenticated` is a provider role, never a team role. Nonanonymous sessions retain the existing personal-meeting Manager capability; team authority remains stored ownership/assignment.

## API contract

- Backend controllers, DTOs, and OpenAPI configuration are the source of truth.
- `syncOpenApiSpec` writes `contracts/openapi/feedback-api.yaml`.
- Do not hand-edit the contract or generated clients; see the [shared API contract guide](../docs/shared/agents/api-contract.md).
- After endpoint, request, response, enum, or error-shape changes, regenerate with `./scripts/shared/generate-api-artifacts.sh` from the monorepo root and update affected call sites.

## Runtime and environment

- Local full-stack runtime is orchestrated from the monorepo root with `./scripts/shared/reset-and-start-local-stack.sh`.
- Direct service runs require the same environment contract described in `backend/README.md` and the root `.env.example`.
- Keep secrets out of source control. Treat Supabase secret keys, SMTP credentials, Firebase service accounts and Zoho values as secrets.
- Configure managed auth, mail, native clients and cutover through [Supabase auth setup](../docs/shared/agents/supabase-auth.md).
