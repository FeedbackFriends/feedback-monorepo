# LetsGrow Project Overview

## Repository Shape

This monorepo contains the LetsGrow product surfaces and the shared infrastructure needed to run and deploy them:

- `web/`: Next.js frontend and public/dashboard web experience.
- `ios-app/`: native iOS app built with SwiftUI and The Composable Architecture.
- `backend/`: Kotlin/Spring Boot API, scheduler, shared model, persistence, Firebase, and iCal modules.
- `contracts/openapi/`: committed canonical OpenAPI contract generated from the backend.
- `scripts/`: root automation for local stack startup, API artifact generation, database reset, and end-to-end mobile flow execution.
- `.github/workflows/`: CI and release automation.
- root Docker Compose files: local and production-like stack orchestration.

Root work should stay limited to shared tooling, Docker Compose, CI/CD, documentation, scripts, generated contracts, and deployment wiring.

## End-To-End Shape

The core architecture is contract-driven from the backend outward:

1. Backend Kotlin controllers, DTOs, and OpenAPI config define the API shape.
2. `cd backend && SPRING_PROFILES_ACTIVE=openapi ./gradlew syncOpenApiSpec --no-configuration-cache` writes `contracts/openapi/feedback-api.yaml`.
3. `web` generates TypeScript API types from that contract.
4. `ios-app` generates Swift OpenAPI sources from that contract.
5. Clients authenticate with Firebase/JWT and call the backend API.
6. Backend services persist data in Postgres and record notification work.
7. Scheduler jobs process delayed or batched notification work.

The root helper `./scripts/generate-api-artifacts.sh` performs the full contract and client regeneration chain.

## Web App

Location: `web/`

Main traits:

- Next.js 16, React 19, TypeScript, Tailwind CSS.
- Firebase client auth.
- `web/src/app/` contains routes such as dashboard, invite, login, privacy policy, and API route handlers.
- `web/src/components/` contains UI, layout, auth, and landing components.
- `web/src/lib/api/generated/openapi.ts` is generated from `contracts/openapi/feedback-api.yaml`.
- `web/package.json` pins Node `20.19.0` and defines `dev`, `build`, `lint`, `generate:api-types`, and `test:e2e`.

Generated API types are not hand-edited. Regenerate them from the root script after backend API changes.

## iOS App

Location: `ios-app/`

Main traits:

- SwiftUI app organized around The Composable Architecture.
- Xcode project at `ios-app/Feedback.xcodeproj`.
- App entry and composition live in `ios-app/App/`.
- Modular Swift package lives in `ios-app/Modules/`.
- Core module groups include `RootFeature`, `TabbarFeature`, `FocusFeature`, `EnterCodeFeature`, `FeedbackFlowFeature`, `MoreFeature`, `SignUpFeature`, `DesignSystem`, `Domain`, `Adapters`, `Utility`, `Logger`, `Localization`, `InfoPlist`, and `OpenAPI`.
- Domain services are protocol-style boundaries consumed by features.
- Adapters implement real API, auth, notification, logging, and system integrations.
- Swift OpenAPI generated code lives under `ios-app/Modules/Sources/OpenAPI/GeneratedSources/`.
- Maestro flows live under `ios-app/.maestro/`.

Architecture docs live in `ios-app/Docs/`, especially `ios-app/Docs/ARCHITECTURE.md`.

## Backend

Location: `backend/`

Main traits:

- Kotlin, Spring Boot, Gradle, JDK 21.
- `apps/api`: REST API, Spring configuration, auth, and OpenAPI generation.
- `apps/scheduler`: background jobs for notifications and delayed work.
- `lib/model`: shared DTOs, enums, entities, and serialization configuration.
- `lib/persistence`: Exposed repositories/DAOs and Liquibase migrations.
- `lib/firebase`: Firebase integration helpers.
- `lib/ical-parser`: iCal parsing utilities.
- Postgres is the runtime database.
- Liquibase migrations live under `backend/lib/persistence/src/main/resources/db/changelog/`.

Backend docs live in `backend/README.md` and `backend/docs/overview.md`.

## OpenAPI Contract

Location: `contracts/openapi/feedback-api.yaml`

Rules:

- Source of truth is backend Spring controllers, DTOs, and OpenAPI config.
- The committed contract is generated, not hand-edited.
- Web and iOS clients consume the committed contract.
- API contract version is managed in backend OpenAPI config.

Regenerate all API artifacts from the repo root:

```bash
./scripts/generate-api-artifacts.sh
```

## Scripts

Location: `scripts/`

Important scripts:

- `./scripts/run`: checks Docker, brings the stack down, regenerates API artifacts, builds local backend images, and starts Docker Compose.
- `./scripts/run -d`: same flow in detached mode.
- `./scripts/generate-api-artifacts.sh`: regenerates the backend OpenAPI contract, web TypeScript API types, and iOS Swift OpenAPI sources.
- `./scripts/reset`: posts to the backend admin reset endpoint.
- `./scripts/e2e`: starts the local stack, waits for API health, builds/installs the iOS localhost app, and runs the Maestro manager flow.

The scripts intentionally fail when prerequisites are missing.

## Local Runtime

Root Compose files orchestrate the stack:

- `docker-compose.yml`: production-like base using published `prod` images.
- `docker-compose.override.yml`: local development override with local images, ports, and database wiring.

The root `.env` file supplies local configuration. Secrets belong in `.env`, GitHub secrets, or Coolify-managed environment variables. `NEXT_PUBLIC_*` values are client-exposed.

Common root commands:

```bash
./scripts/run -d
docker compose ps
docker compose logs -f
docker compose down
```

## CI And Release

GitHub Actions live in `.github/workflows/`:

- `ci.yml`: backend build/tests plus web install/lint/build, and generated API artifact checks.
- `release.yml`: web end-to-end tests, Docker image publication, GitHub release creation, OpenAPI artifact attachment, and Coolify deployment trigger.

Production deployment uses Coolify and should pull mutable `prod` image tags.

## Common Change Paths

Backend endpoint change:

1. Change backend controller/DTO/service/persistence/migrations as needed.
2. Regenerate API artifacts with `./scripts/generate-api-artifacts.sh`.
3. Update web and iOS call sites if the contract changed.
4. Run backend tests plus relevant client checks.

Web-only UI change:

1. Work in `web/`.
2. Keep API usage aligned with generated types.
3. Run lint/build and Playwright for changed journeys.

iOS-only feature change:

1. Work in `ios-app/`.
2. Keep feature logic in TCA feature modules.
3. Use Domain services and Adapters for external integration.
4. Run Swift/Xcode validation and Maestro when flows change.

Infrastructure change:

1. Work from the root.
2. Check Docker Compose, scripts, GitHub Actions, Coolify expectations, env vars, ports, and image tags.
3. Call out deployment or cost implications.
