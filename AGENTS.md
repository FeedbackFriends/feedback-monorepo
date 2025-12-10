# Repository Guidelines

## Project Structure & Modules
- `apps/api` – Spring Boot REST API (controllers, services, config) with resources in `src/main/resources/application.yml`.
- `apps/scheduler` – background jobs and notification scheduling; config mirrors the API under `src/main/resources/`.
- `lib/model` – shared DTOs, enums, and Jackson config; `lib/firebase` – Firebase client wrapper; `lib/persistence` – Exposed DAO/repo layer plus Liquibase change sets in `src/main/resources/db/changelog/`.
- Tests live in `apps/api/src/test/kotlin` (API/integration utilities) and `lib/persistence/src/test/kotlin` (DAO/DB coverage).
- Diagrams for architecture live in `docs/diagrams/` (PlantUML).

## Build, Test, and Development Commands
- `./gradlew clean build` – compile all modules and run the full test suite (warnings fail the build).
- `./gradlew test` or `./gradlew :api:test` – run all tests or scope to the API module; uses in-memory H2 by default.
- `./gradlew :scheduler:test` or `./gradlew :scheduler:compileKotlin` – run scheduler tests or just compile the scheduler (useful for quick checks).
- `./gradlew :api:bootRun` – start the API locally on 8080 (set `SPRING_DATASOURCE_URL`, `FIREBASE_API_KEY`, `FIREBASE_CONFIG_PATH` to target real services).
- `./gradlew :scheduler:bootRun` – start the scheduler service; shares the same env vars as the API.
- `./gradlew jibDockerBuild` (per app) builds a container image if Docker is available.

## Coding Style & Naming Conventions
- Kotlin 1.9+, JVM 21 toolchain; prefer idiomatic Kotlin (null-safety, data classes for payloads) and 4-space indentation.
- Keep package structure by layer (`config/`, `controller/`, `service/`, `persistence/`).
- Use meaningful request/response DTO names (`*Input`, `*Dto`) and snake-free JSON via Jackson config.
- Enable logging via existing interceptors; avoid committing secrets or Firebase config files.

## Testing Guidelines
- Primary framework: JUnit 5 with `spring-boot-starter-test`; H2 in-memory DB is the default test datasource.
- Name tests `*Test.kt`; integration tests typically extend helpers in `apps/api/src/test/kotlin/.../utils`.
- Add DAO/migration coverage in `lib/persistence/src/test/kotlin`; keep Liquibase change sets incremental (`000X-description.yaml`).
- Run `./gradlew test` before opening a PR; include failing cases when reporting bugs.

## Commit & Pull Request Guidelines
- Use short, imperative commit messages (e.g., `Add feedback summary endpoint`); group related changes per commit.
- Before a PR: describe the change, mention related issue IDs, and list manual/automated test results (`./gradlew test`, local bootRun checks).
- Include screenshots or sample payloads for API-impacting changes; document new env vars and migrations in the PR description.
