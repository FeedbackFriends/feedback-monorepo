# Repository Guidelines

## Project Structure & Modules
- `apps/api` – Spring Boot REST API (controllers, services, config) with resources in `src/main/resources/application.yml`.
- `apps/scheduler` – background jobs and notification scheduling; config mirrors the API under `src/main/resources/`.
- `apps/email-listener` – IMAP listener for calendar invites; config lives in `src/main/resources/application.yml`.
- `lib/model` – shared DTOs, enums, and Jackson config; `lib/firebase` – Firebase client wrapper; `lib/ical-parser` – iCal parsing utilities; `lib/persistence` – Exposed DAO/repo layer plus Liquibase change sets in `src/main/resources/db/changelog/`.
- Tests live in `apps/api/src/test/kotlin` (API/integration utilities) and `lib/persistence/src/test/kotlin` (DAO/DB coverage).
- Diagrams for architecture live in `docs/diagrams/` (PlantUML).

## Build, Test, and Development Commands
- `./gradlew clean build` – compile all modules and run the full test suite (warnings fail the build).
- `./gradlew test` – run all tests
- `./gradlew :scheduler:test` or `./gradlew :scheduler:compileKotlin` – run scheduler tests or just compile the scheduler (useful for quick checks).
- `./gradlew :scheduler:bootRun` – start the scheduler service; shares the same env vars as the API.
- `./gradlew :email-listener:bootRun` – start the email listener; configure `IMAP_HOST`, `IMAP_PORT`, `IMAP_USERNAME`, `IMAP_PASSWORD`, `IMAP_FOLDER`.
- `./gradlew  --no-daemon :api:jibDockerBuild :scheduler:jibDockerBuild :email-listener:jibDockerBuild --no-configuration-cache` – Build docker images locally
- `docker compose -f ../infra/docker-compos****e.yml up -d --remove-orphans` – build and run the applications via Docker Compose (from this repo root; or run `docker compose -f infra/docker-compose.yml ...` from the monorepo root).
- `SPRING_PROFILES_ACTIVE=openapi ./gradlew :api:generateOpenApiDocs --no-configuration-cache` - generate openapi spec
- Local env vars live in `../.env` (monorepo root); source it or export needed variables before running services.
## Coding Style & Naming Conventions
- Kotlin 1.9+, JVM 21 toolchain; prefer idiomatic Kotlin (null-safety, data classes for payloads) and 4-space indentation.
- Keep package structure by layer (`config/`, `controller/`, `service/`, `persistence/`).
- Use meaningful request/response DTO names (`*Input`, `*Dto`) and snake-free JSON via Jackson config.
- Enable logging via existing interceptors; avoid committing secrets or Firebase config files.
- Controllers stay thin and delegate to services; services map domain to DTOs and push persistence through repos (keep concerns separated).
- Constructor injection with `val` deps is the norm; keep helper/guard logic in extensions (e.g., JWT helpers) for readability.
- Favor straight-line flows with guard clauses/exceptions over clever abstractions—simple and explicit beats smart.
- Use data classes with explicit nullability and trailing commas; convert collections with `map`/`filter` instead of in-place mutation.
- Log notable state changes with `LoggerFactory`, but keep noise low; warnings are treated as errors during compilation.
- Tests lean on JUnit5 + MockMvc integration flows with scenario-style backtick names; H2 in-memory defaults keep them fast and repeatable.

## Testing Guidelines
- Primary framework: JUnit 5 with `spring-boot-starter-test`; H2 in-memory DB is the default test datasource.
- Name tests `*Test.kt`; integration tests typically extend helpers in `apps/api/src/test/kotlin/.../utils`.
- Add DAO/migration coverage in `lib/persistence/src/test/kotlin`; keep Liquibase change sets incremental (`000X-description.yaml`).
- Run `./gradlew test` before opening a PR; include failing cases when reporting bugs.

## Commit & Pull Request Guidelines
- Use short, imperative commit messages (e.g., `Add feedback summary endpoint`); group related changes per commit.
- Before a PR: describe the change, mention related issue IDs, and list manual/automated test results (`./gradlew test`, local bootRun checks).
- Include screenshots or sample payloads for API-impacting changes; document new env vars and migrations in the PR description.
