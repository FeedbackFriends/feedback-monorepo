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
- Hand responsive and visual inspection to the human after automated checks pass.

## Next.js runtime verification

When runtime/browser verification is explicitly requested, use [next-dev-loop](../../../.agents/skills/next-dev-loop/SKILL.md) with `npm run dev` to check framework compilation/errors, the affected browser journey, and relevant React behavior. Follow its preflight against the running server; framework diagnostics and browser checks complement the checks above. It requires Next.js 16.3+ with Turbopack and `agent-browser` 0.31.1+.

Follow [browser access](../../../docs/agents/browser-access.md) for isolation, authentication and readiness. Use locators and assertions instead of the upstream skill's generic `networkidle` wait. Keep repeatable regression coverage in `web/tests/`. If preflight fails, report which runtime evidence is missing and continue applicable lint/build/tests; those checks do not establish live behavior.

Browser CLI setup is documented in [browser access](../../../docs/agents/browser-access.md#browser-cli-setup).

## Test boundaries

`npm run test:e2e` starts an isolated development app on port 3100 and a controlled HTTP upstream on 3199. Keep both ports free. Team UI tests mock browser responses; `relay.spec.ts` exercises the actual Next.js relay against that upstream, including status/body/header forwarding, denied requests, redirects and the real 15-second timeout. These tests do not establish Supabase or Kotlin authorization correctness. `architecture.spec.ts` checks public auth isolation, indexing and responsive anchor navigation. Tests run in CI and block release on failure.

`PLAYWRIGHT_BASE_URL` selects an externally managed app and disables both automatic servers. That app must use development E2E auth and the controlled upstream at 3199 for this complete suite; start the fixture with `node tests/fixtures/upstream.ts`. Use a separate focused journey for live Supabase/backend verification, with test credentials and no database reset.

After moving routes, stale `.next/dev/types` may refer to the old paths. Stop the development server before removing those generated declarations and regenerate with Next.js; keep the active server's build state intact.

The Node runtime is pinned in `.nvmrc`, `package.json` and Docker; CI reads `.nvmrc`. Scoped dependency overrides patch TypeScript ESLint's minimatch dependency. Recheck compatibility and `npm audit` when upstream constraints change before removing these overrides.
