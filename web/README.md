# feedback-web

This frontend runs on Next.js 16 App Router, React 19, and Tailwind CSS with
shadcn UI primitives.

## Runtime

The web app is pinned to Node `20.19.0`.

- Use `nvm use` in `web/` to load the version from `.nvmrc`.
- `package.json` enforces the same version via `engines.node`.
- GitHub Actions reads `web/.nvmrc`.
- The web `Dockerfile` uses `node:20.19.0-alpine` for dependency, build, and runtime stages.

## Tailwind CSS

The web app now uses Tailwind CSS `v4` with the CSS-first setup recommended by
the current Next.js docs:

- `src/app/globals.css` is the Tailwind entrypoint via `@import 'tailwindcss'`
- `postcss.config.js` uses `@tailwindcss/postcss`
- there is no `tailwind.config.js`; theme tokens and custom utilities live in
  `src/app/globals.css`

Tailwind CSS `v4` requires a modern browser baseline. For this app, that means:

- Chrome `111+`
- Safari `16.4+`
- Firefox `128+`

If older browser support becomes a requirement again, the styling stack should
move back to Tailwind CSS `v3` instead of adding fallbacks.

## Firebase auth config

The `web` npm scripts now load the repo-root `.env`, so the same file works for
both `docker compose` and `cd web && npm run dev`.

Set these public environment variables in the repo-root `.env` before using the
`/login` and `/dashboard` auth flow:

- `NEXT_PUBLIC_FIREBASE_API_KEY`
- `NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN`
- `NEXT_PUBLIC_FIREBASE_PROJECT_ID`
- `NEXT_PUBLIC_FIREBASE_APP_ID`
- `NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET` (optional)
- `NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID` (optional)
- `NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID` (optional)

## Backend API types

The frontend generates backend API types from the committed monorepo contract at
`../contracts/openapi/feedback-api.yaml`.

Refresh the generated types with:

```bash
npm run generate:api-types
```

This writes the generated TypeScript definitions to
`src/lib/api/generated/openapi.ts`.
