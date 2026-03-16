# Architecture Overview

## Services
- **API (`apps/api`)**: Spring Boot REST endpoints for feedback sessions, events, accounts, and questions. Uses JWT validation against Google/Firebase. Controllers delegate to services, which call persistence DAOs and emit notifications.
- **Scheduler (`apps/scheduler`)**: Background jobs that batch/remind owners about new feedback and handle delayed notifications.

## Shared Libraries
- **model (`lib/model`)**: DTOs, enums, JPA/Exposed entities, and Jackson config shared across services.
- **persistence (`lib/persistence`)**: Exposed-based DAOs/repos and Liquibase migrations in `src/main/resources/db/changelog/`.
- **firebase (`lib/firebase`)**: Wrapper for Firebase messaging/auth helpers.

## Data & Configuration
- Postgres is the runtime datasource for the application services.
- Liquibase runs on startup and keeps schema aligned with change sets (`000X-description.yaml`).
- Security: Resource server with JWT (Google/Firebase) configured in `apps/api/src/main/resources/application.yml`.
- Logging: services use Spring Boot console logging, and the API interceptor captures request context for Render logs.

## Request/Notification Flow
1. Client calls API (JWT bearer token).
2. Controller → service → persistence layer to read/write domain entities.
3. On new feedback, notification intent is recorded; Firebase client can push messages, and the scheduler can batch reminders.
4. Scheduler jobs poll outstanding notification records and notify owners/managers, updating activity history.

## Local Development Tips
- Configure Postgres via `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, and `POSTGRES_PASSWORD`.
- OpenAPI docs live at `/` (Swagger UI) and `/v3/api-docs.yaml`; regenerate the committed contract with `SPRING_PROFILES_ACTIVE=openapi ./gradlew syncOpenApiSpec --no-configuration-cache` if you add endpoints.
- Keep DTOs in `model`, business logic in `service`, and database details in `persistence` to maintain module boundaries.
