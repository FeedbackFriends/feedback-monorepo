# Repository Guidelines

## Project Structure & Modules
-  – Spring Boot REST API (controllers, services, config) with resources in .
-  – background jobs and notification scheduling; config mirrors the API under .
-  – shared DTOs, enums, and Jackson config;  – Firebase client wrapper;  – iCal parsing utilities;  – Exposed DAO/repo layer plus Liquibase change sets in .
- Tests live in  (API/integration utilities) and  (DAO/DB coverage).
- Diagrams for architecture live in  (PlantUML).

## Build, Test, and Development Commands
-  – compile all modules and run the full test suite (warnings fail the build).
-  – run all tests.
-  or  – run scheduler tests or just compile the scheduler.
-  – start the scheduler service; shares the same env vars as the API.
-  – build Docker images locally.
-  – generate the OpenAPI spec.
- Production deployment is defined in ; keep backend runtime expectations aligned with the Render Dockerfiles under .
- Local env vars live in  (monorepo root); source it or export needed variables before running services.

## Coding Style & Naming Conventions
- Kotlin 1.9+, JVM 21 toolchain; prefer idiomatic Kotlin (null-safety, data classes for payloads) and 4-space indentation.
- Keep package structure by layer (, , , ).
- Use meaningful request/response DTO names (, ) and snake-free JSON via Jackson config.
- Enable logging via existing interceptors; avoid committing secrets or Firebase config files.
- Controllers stay thin and delegate to services; services map domain to DTOs and push persistence through repos (keep concerns separated).
- Constructor injection with  deps is the norm; keep helper/guard logic in extensions (e.g., JWT helpers) for readability.
- Favor straight-line flows with guard clauses/exceptions over clever abstractions; simple and explicit beats smart.
- Use data classes with explicit nullability and trailing commas; convert collections with / instead of in-place mutation.
- Log notable state changes with , but keep noise low; warnings are treated as errors during compilation.
- Tests lean on JUnit5 + MockMvc integration flows with scenario-style backtick names.

## Testing Guidelines
- Primary framework: JUnit 5 with .
- Name tests ; integration tests typically extend helpers in .
- Add DAO/migration coverage in ; keep Liquibase change sets incremental ().
- Run  before opening a PR; include failing cases when reporting bugs.

## Commit & Pull Request Guidelines
- Use short, imperative commit messages (e.g., ); group related changes per commit.
- Before a PR: describe the change, mention related issue IDs, and list manual/automated test results (, local bootRun checks).
- Include screenshots or sample payloads for API-impacting changes; document new env vars and migrations in the PR description.
