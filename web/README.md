# feedback-web

This frontend now runs on Next.js App Router with Tailwind CSS and shadcn UI primitives.

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
