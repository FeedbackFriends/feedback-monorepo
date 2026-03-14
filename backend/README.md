# Feedback Backend

Kotlin + Spring Boot services powering the Feedback platform. The backend is split into an API service, a scheduler service, and shared libraries for persistence, models, and integrations.

## Project Layout
- `apps/api` contains the main REST API, Spring configuration, and OpenAPI generation.
- `apps/scheduler` contains background jobs and notification polling.
- `lib/model` contains shared DTOs, enums, entities, and Jackson configuration.
- `lib/persistence` contains Exposed repositories and Liquibase change sets.
- `lib/firebase` contains Firebase integration helpers.
- `lib/ical` contains iCal parsing utilities.
- `docs/` contains architecture notes and diagrams.

## Prerequisites
- JDK 21
- Docker for the full local stack or local Postgres
- Firebase service account JSON exposed via `FIREBASE_SERVICE_ACCOUNT_JSON_B64`

## Local Development

### Full Stack From The Repo Root
Run the full stack from the monorepo root:

```bash
docker compose up --build
```

Services:
- `web` at `http://localhost:3000`
- `api` at `http://localhost:8080`
- API health at `http://localhost:8090/actuator/health`
- scheduler health at `http://localhost:8091/actuator/health`
- Postgres at `localhost:5432` with database `feedback`

The root [`.env.example`](../.env.example) includes every environment variable Compose needs for a local run. Copy it to `.env` at the repo root and fill in the real values you need.

### Direct Gradle Runs
Export the runtime variables first:

```bash
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_DB=feedback
export POSTGRES_USER=feedback
export POSTGRES_PASSWORD=feedback
export FIREBASE_API_KEY=...
export FIREBASE_SERVICE_ACCOUNT_JSON_B64="$(base64 < ../firebase_config.json | tr -d '\n')"
export ZOHO_ACCOUNT_ID=...
export ZOHO_FOLDER_ID=...
export ZOHO_OAUTH_REFRESH_TOKEN=...
export ZOHO_CLIENT_ID=...
export ZOHO_CLIENT_SECRET=...
```

Run the services:

```bash
./gradlew :api:bootRun
./gradlew :scheduler:bootRun
```

Swagger UI is served at `http://localhost:8080/` and the OpenAPI YAML at `http://localhost:8080/v3/api-docs.yaml`.

### OpenAPI Generation
Generate the API spec with the dedicated `openapi` profile:

```bash
SPRING_PROFILES_ACTIVE=openapi ./gradlew :api:generateOpenApiDocs --no-configuration-cache
```

## Tests And Tooling
- `./gradlew test` runs all backend tests.
- `./gradlew :api:test` runs only API tests.
- `./gradlew clean build` builds all backend modules and fails on warnings.
- `docker build -f backend/apps/api/Dockerfile .` builds the API image.
- `docker build -f backend/apps/scheduler/Dockerfile .` builds the scheduler image.

## Database And Migrations
- Postgres is the runtime datasource for the application services.
- Liquibase change sets live in `lib/persistence/src/main/resources/db/changelog/` and run automatically on startup.

## Common Issues
- Missing Firebase config: ensure `FIREBASE_SERVICE_ACCOUNT_JSON_B64` contains a valid base64-encoded service account JSON.
- Connection refused to Postgres: verify the container is running and `POSTGRES_HOST` / `POSTGRES_PORT` point at the right server.
- Ports in use: override Spring ports with standard Spring Boot properties when running directly.

## Zoho Notes
Zoho OAuth scopes for Self Client should use `ZohoMail.messages.READ` for the scheduler runtime. If Zoho rejects multiple scopes in a Self Client grant, obtain `ZOHO_ACCOUNT_ID` and `ZOHO_FOLDER_ID` with one-off access tokens using `ZohoMail.accounts.READ` and `ZohoMail.folders.READ`, then switch the refresh token to `ZohoMail.messages.READ` for the runtime path.

## Documentation
- [Architecture Overview](./docs/overview.md) explains module roles and request/notification flows.
- [Diagrams](./docs/diagrams/) contains PlantUML diagrams.
