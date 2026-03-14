# feedback-web

This frontend runs on Next.js 16 App Router, React 19, and Tailwind CSS with
shadcn UI primitives.

## Runtime

The web app is pinned to Node `20.19.0`.

- Use `nvm use` in `web/` to load the version from `.nvmrc`.
- `package.json` enforces the same version via `engines.node`.
- GitHub Actions reads `web/.nvmrc`.
- The web `Dockerfile` uses `node:20.19.0-alpine` for dependency, build, and runtime stages.

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
