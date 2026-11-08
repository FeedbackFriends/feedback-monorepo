# Repository scope

Root-level work is for shared orchestration and repository infrastructure:

- Docker Compose and runtime wiring
- Helper scripts and their tests under `scripts/{shared,ios,backend,web}/` as needed
- GitHub Actions and release automation
- Generated API contracts under `contracts/openapi/`
- Maintained documentation and assets under `docs/{shared,ios,backend,web}/`

Product features belong in the app that owns them:

- [`web/`](../../../web/AGENTS.md): Next.js routes, components, client auth, generated TypeScript API types, and frontend tests. Uses npm.
- [`backend/`](../../../backend/AGENTS.md): Kotlin API, scheduler, persistence, migrations, integrations, and canonical OpenAPI source. Uses the Gradle wrapper.
- [`ios-app/`](../../../ios-app/AGENTS.md): SwiftUI/TCA app, adapters, generated Swift OpenAPI sources, and Maestro flows. Uses Swift Package Manager.

Keep root changes focused on shared infrastructure; implement app behavior in the owning app.

## Documentation and helper placement

For all new or moved repository-owned files:

- Put maintained documentation and its assets under root `docs/<scope>/`, using `shared`, `ios`, `backend`, or `web`.
- Put helper scripts and their tests under root `scripts/<scope>/`; create a scope folder only when needed.
- Keep root and app `AGENTS.md` files, app/contract/test-suite README entry points, and tool-required files with their owners. Tool-required files include Xcode Cloud hooks, migrations, build wrappers, application tests, and generated artifacts.
- Keep skill instructions and skill-specific supporting files together under `.agents/skills/`. Follow the [inline-by-default rule](../../../.agents/skills/lg-maintain-harness/SKILL.md#inline-by-default) for supporting guidance.

Use these homes instead of introducing app-local documentation or helper-script trees. Update callers, commands, client configuration, and indexes whenever files move.

## Shared implementation conventions

- Modify generated files only through the repository's generation scripts. For API artifacts, follow the [API contract guide](api-contract.md).
- Use two-space indentation in YAML.
- Prefer deterministic, single-path behavior. Throw clear errors instead of adding fallback logic or special-case recovery.
