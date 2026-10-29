# Repository scope

Root-level work is for shared orchestration and repository infrastructure:

- Docker Compose and runtime wiring
- Root scripts
- GitHub Actions and release automation
- Generated API contracts under `contracts/openapi/`
- Repository documentation and deployment notes

Product features belong in the app that owns them:

- [`web/`](../../web/AGENTS.md): Next.js routes, components, client auth, generated TypeScript API types, and frontend tests. Uses npm.
- [`backend/`](../../backend/AGENTS.md): Kotlin API, scheduler, persistence, migrations, integrations, and canonical OpenAPI source. Uses the Gradle wrapper.
- [`ios-app/`](../../ios-app/AGENTS.md): SwiftUI/TCA app, adapters, generated Swift OpenAPI sources, and Maestro flows. Uses Swift Package Manager.

Keep root changes focused on shared infrastructure; implement app behavior in the owning app.

## Shared implementation conventions

- Modify generated files only through the repository's generation scripts. For API artifacts, follow the [API contract guide](api-contract.md).
- Use two-space indentation in YAML.
- Prefer deterministic, single-path behavior. Throw clear errors instead of adding fallback logic or special-case recovery.
