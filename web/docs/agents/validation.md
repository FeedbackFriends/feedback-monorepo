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
