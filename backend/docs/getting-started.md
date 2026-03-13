# Getting Started

## Prerequisites
- JDK 21 (Gradle wrapper downloads required dependencies).
- Docker if you want the full local stack or local Postgres; otherwise H2 is used for dev/test.
- Firebase service account JSON provided via `FIREBASE_SERVICE_ACCOUNT_JSON_B64`.

## Setup
1. Clone the repo and ensure `./gradlew` is executable.
2. Ensure the root `.env` contains the Firebase, JWT, and Zoho values you want to use locally.
3. Set environment variables for direct Gradle runs (H2 defaults work if you skip Postgres):
   ```bash
   export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/feedback
   export SPRING_DATASOURCE_USERNAME=feedback
   export SPRING_DATASOURCE_PASSWORD=feedback
   export FIREBASE_API_KEY=...
   export FIREBASE_SERVICE_ACCOUNT_JSON_B64="$(base64 < ../firebase_config.json | tr -d '\n')"
   export ZOHO_ACCOUNT_ID=...
   export ZOHO_FOLDER_ID=...
   export ZOHO_OAUTH_REFRESH_TOKEN=...
   export ZOHO_CLIENT_ID=...
   export ZOHO_CLIENT_SECRET=...
   ```
   Base version is set in `gradle.properties` (CI appends build metadata).

   Zoho OAuth scopes for Self Client: use `ZohoMail.messages.READ` for the scheduler runtime.
   If Zoho rejects multiple scopes in a Self Client grant, obtain `ZOHO_ACCOUNT_ID` and `ZOHO_FOLDER_ID`
   with one-off access tokens using `ZohoMail.accounts.READ` and `ZohoMail.folders.READ`, then switch
   the refresh token to `ZohoMail.messages.READ` for production. ZohoMail.attachments.READ cannot be
   combined in a Self Client grant; attachments are still accessed via the message APIs.

## Local Docker Stack
Run the full stack from the repo root:

```bash
docker compose up --build
```

Services:
- `web` at `http://localhost:3000`
- `api` at `http://localhost:18080`
- API health at `http://localhost:18090/actuator/health`
- `scheduler` on the internal Docker network with health at `http://localhost:18091/actuator/health`
- Postgres at `localhost:5432` with database `feedback`

Override any published host port with `DB_HOST_PORT`, `WEB_HOST_PORT`, `API_HOST_PORT`, `API_MANAGEMENT_HOST_PORT`, or `SCHEDULER_MANAGEMENT_HOST_PORT` in your shell or `.env`.

## Running Services
- API service:
  ```bash
  ./gradlew :api:bootRun   # starts on :8080
  ```
- Scheduler service:
  ```bash
  ./gradlew :scheduler:bootRun
  ```
- Swagger UI lives at `/` locally; OpenAPI YAML at `/v3/api-docs.yaml`.

## Tests and Tooling
- Run all tests: `./gradlew test`
- Scope to API tests: `./gradlew :api:test`
- Build everything (fail on warnings): `./gradlew clean build`
- Build API image: `docker build -f backend/apps/api/Dockerfile .`
- Build scheduler image: `docker build -f backend/apps/scheduler/Dockerfile .`

## Database & Migrations
- Liquibase change sets live in `lib/persistence/src/main/resources/db/changelog/` and run automatically on startup (unless disabled).
- In tests, H2 in-memory DB is used; no extra setup required.

## Common Issues
- **Missing Firebase config**: ensure `FIREBASE_SERVICE_ACCOUNT_JSON_B64` contains a valid base64-encoded service account JSON.
- **Connection refused to Postgres**: verify the container is running and `SPRING_DATASOURCE_URL` matches the host/port.
- **Ports in use**: change `server.port` in `apps/api/src/main/resources/application.yml` or via `--server.port=8081`.

## Zoho Mail Processing Status
Scheduler outcomes are stored in `zoho_processed_message`:
- `status` (`CLAIMED`, `SUCCESS`, `SKIPPED`, `FAILED`) tracks processing results.
- `archive_status` (`SUCCESS`, `FAILED`) tracks archiving attempts after processing.
