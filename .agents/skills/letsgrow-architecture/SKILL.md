---
name: letsgrow-architecture
description: LetsGrow architecture map and codebase orientation for the full monorepo. Use when explaining, reviewing, or changing project-wide architecture across the iOS app, web app, backend API, scheduler, OpenAPI contract, scripts, Docker Compose, CI/CD, and deployment wiring.
---

# LetsGrow Architecture

## Use This When

Use this skill for architecture-level work across more than one project surface, especially:

- explaining how the whole project fits together
- tracing a feature across iOS, web, backend, OpenAPI, scripts, and infrastructure
- deciding where a change belongs
- reviewing module boundaries or generated API artifacts
- onboarding an agent or developer to the repository structure
- checking whether a proposed change cuts across app, API, contract, CI, or deployment boundaries

For product language, positioning, and domain invariants, also use `$letsgrow-domain`.

## Quick Rule

The backend API and DTOs generate the canonical OpenAPI contract. The committed contract then feeds generated clients for web and iOS. Do not hand-edit generated API artifacts.

## Load The Overview

Read [references/project-overview.md](references/project-overview.md) before answering architecture questions or making cross-surface changes.

## Workflow

1. Start from the narrowest relevant surface:
   - root for shared orchestration, Docker Compose, GitHub Actions, scripts, contracts, and deployment
   - `backend/` for Kotlin API, scheduler, persistence, migrations, backend integrations, and OpenAPI source
   - `web/` for Next.js routes, components, Firebase client auth, and TypeScript API client usage
   - `ios-app/` for SwiftUI/TCA features, adapters, generated Swift OpenAPI sources, Xcode config, and Maestro flows
2. Read local instructions before editing:
   - `AGENTS.md`
   - app-local `AGENTS.md` when present
   - relevant README or docs under the surface being touched
3. Inspect repo-owned files only. Exclude generated/build/dependency directories unless the task is specifically about generated output:
   - `web/node_modules/`
   - `web/.next/`
   - `backend/**/build/`
   - `backend/.gradle/`
   - `ios-app/.build/`
   - `ios-app/Modules/.build/`
4. Trace cross-surface changes through the contract:
   - backend controller, DTO, service, persistence, migration
   - generated OpenAPI contract at `contracts/openapi/feedback-api.yaml`
   - web generated client at `web/src/lib/api/generated/openapi.ts`
   - iOS generated sources under `ios-app/Modules/Sources/OpenAPI/GeneratedSources/`
5. Regenerate API artifacts with `./scripts/generate-api-artifacts.sh` when API shape changes.
6. Validate at the correct level:
   - backend: Gradle tests/build from `backend/`
   - web: `npm run lint`, `npm run build`, and Playwright when user-facing flows change
   - iOS: Swift package or Xcode build/test, plus Maestro for mobile journeys when relevant
   - root: relevant `docker compose` or workflow diff checks for orchestration changes

## Architectural Biases

- Keep product features inside the app that owns them; root work is shared tooling and infrastructure.
- Prefer explicit single-path configuration. Throw clear errors instead of adding fallback behavior.
- Treat generated artifacts as outputs of the canonical source, not as places to implement behavior.
- Preserve existing boundaries: web UI in `web/`, API and scheduler logic in `backend/`, native app features in `ios-app/`, shared API contract in `contracts/openapi/`.
- When a change spans surfaces, state the propagation path and the files that must stay in sync.

## Output Shape

For architecture explanations, include:

- the involved surfaces
- the source of truth
- the runtime flow
- generated artifacts, if any
- validation commands
- risks or boundary concerns

For implementation work, keep changes scoped and call out any new environment variables, ports, image tags, generated files, or deployment implications.
