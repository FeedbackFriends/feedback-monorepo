# Backend commands and validation

Paths and commands are relative to `backend/` unless stated otherwise.

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

## Testing Guidelines

- Primary framework: JUnit 5.
- Use MockMvc and existing integration helpers for API behavior.
- Use scenario-style backtick test names where the surrounding tests do.
- For bug fixes, prefer a failing test that reproduces the issue before changing behavior.

## Validation Expectations

- Narrow backend logic change: run the relevant module test task.
- Persistence or migration change: run persistence tests and any affected API tests.
- API contract change: run `./scripts/generate-api-artifacts.sh` from the root and inspect the generated diff.
- Docker/runtime change: run the relevant Gradle image task or root Compose command.
