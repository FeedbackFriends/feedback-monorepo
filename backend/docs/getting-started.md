# Getting Started

## Prerequisites
- JDK 21 (Gradle wrapper downloads required dependencies).
- Docker (optional) if you want local Postgres; otherwise H2 is used for dev/test.
- Firebase service account JSON (path provided via `FIREBASE_CONFIG_PATH`).

## Setup
1. Clone the repo and ensure `./gradlew` is executable.
2. Create a Postgres DB (optional):
   ```bash
   docker run --name feedback-db -e POSTGRES_DB=feedback -e POSTGRES_USER=feedback -e POSTGRES_PASSWORD=secret -p 5432:5432 -d postgres:16
   ```
3. Copy example configs and fill in real values:
   ```bash
   cp .env.example .env
   cp firebase_config.json.example firebase_config.json
   ```
4. Set environment variables (H2 defaults work if you skip Postgres):
   ```bash
   export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/feedback
   export SPRING_DATASOURCE_USERNAME=feedback
   export SPRING_DATASOURCE_PASSWORD=secret
   export FIREBASE_API_KEY=...
   export FIREBASE_CONFIG_PATH=./firebase_config.json
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

## Running Services
- API service:
  ```bash
  ./gradlew :apps:api:bootRun   # starts on :8080
  ```
- Scheduler service:
  ```bash
  ./gradlew :apps:scheduler:bootRun
  ```
- Swagger UI lives at `/` locally; OpenAPI YAML at `/v3/api-docs.yaml`.

## Tests and Tooling
- Run all tests: `./gradlew test`
- Scope to API tests: `./gradlew :apps:api:test`
- Build everything (fail on warnings): `./gradlew clean build`
- Docker image (per app): `./gradlew :apps:scheduler:jibDockerBuild`

## Database & Migrations
- Liquibase change sets live in `lib/persistence/src/main/resources/db/changelog/` and run automatically on startup (unless disabled).
- In tests, H2 in-memory DB is used; no extra setup required.

## Common Issues
- **Missing Firebase config**: ensure `FIREBASE_CONFIG_PATH` points to a valid service account JSON.
- **Connection refused to Postgres**: verify the container is running and `SPRING_DATASOURCE_URL` matches the host/port.
- **Ports in use**: change `server.port` in `apps/api/src/main/resources/application.yml` or via `--server.port=8081`.

## Zoho Mail Processing Status
Scheduler outcomes are stored in `zoho_processed_message`:
- `status` (`CLAIMED`, `SUCCESS`, `SKIPPED`, `FAILED`) tracks processing results.
- `archive_status` (`SUCCESS`, `FAILED`) tracks archiving attempts after processing.
