# LetsGrow backend

Kotlin backend for LetsGrow: Spring Boot API, scheduler, Postgres persistence, and integrations.

Use the Gradle wrapper from `backend/`; warnings fail the build.

## Commands

- Build: `./gradlew clean build`
- Test: `./gradlew test` or the affected module task, such as `./gradlew :api:test`.
- Build local images: `./gradlew --no-configuration-cache buildLocalImages`.
- Regenerate the contract and clients from the monorepo root: `./scripts/generate-api-artifacts.sh`.

## Read when relevant

| Task | Guidance |
| --- | --- |
| Kotlin implementation or module ownership | [Architecture and conventions](docs/agents/architecture.md) |
| Endpoints, DTOs, or generated contracts | [API contract](docs/agents/api-contract.md) |
| Database, DAO, or migration changes | [Persistence](docs/agents/persistence.md) |
| Build, tests, or validation | [Commands and validation](docs/agents/validation.md) |
| Service startup or environment | [Runtime](docs/agents/runtime.md) |

Repository-wide rules remain in the [root AGENTS.md](../AGENTS.md).
