# Web commands and validation

Paths are relative to `web/` unless stated otherwise.

## Commands

Run these from `web/`:

```bash
npm install
npm run dev
npm run lint
npm run build
npm run test:e2e
npm run generate:api-types
```

The `dev`, `build`, and `start` scripts load the root `.env` through `dotenv-cli`.

Generate all API artifacts from the monorepo root:

```bash
./scripts/generate-api-artifacts.sh
```

## Testing And Validation

- Run `npm run lint` for TypeScript/React changes.
- Run `npm run build` for route, config, or data-loading changes.
- Run `npm run test:e2e` when changing login, dashboard, invite, or other user-facing flows covered by Playwright.
- For visual work, inspect responsive behavior on mobile and desktop before finishing.

## Next.js runtime verification

After changing runtime behavior, use [next-dev-loop](../../../.agents/skills/next-dev-loop/SKILL.md) with `npm run dev` to check framework compilation/errors, the affected browser journey, and relevant React behavior. Follow its preflight against the running server; framework diagnostics and browser checks complement the checks above. It requires Next.js 16.3+ with Turbopack and `agent-browser` 0.31.1+.

Follow [browser access](../../../docs/agents/browser-access.md) for isolation, authentication and readiness. Use locators and assertions instead of the upstream skill's generic `networkidle` wait. Keep repeatable regression coverage in `web/tests/`. If preflight fails, report which runtime evidence is missing and continue applicable lint/build/tests; those checks do not establish live behavior.

Browser CLI setup is documented in [browser access](../../../docs/agents/browser-access.md#browser-cli-setup).
