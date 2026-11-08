# API, authentication, and environment

Paths are relative to `web/` unless stated otherwise.

## API Contract

- `src/lib/api/generated/openapi.ts` is generated from `contracts/openapi/feedback-api.yaml`; never hand-edit it.
- When the contract changes, regenerate from the monorepo root with `./scripts/generate-api-artifacts.sh` and update typed call sites.
- Backend controllers, DTOs, and OpenAPI configuration own API shape; see the [shared API contract guide](../../../docs/agents/api-contract.md).

## Auth And Environment

- Supabase client auth lives under `src/lib/auth/`.
- E2E auth helpers live under `src/lib/auth/e2e-auth-client.ts`.
- Root `.env` supplies runtime values. Never commit secrets.
- Treat `NEXT_PUBLIC_*` values as client-exposed and never put secrets in them.

## Leader application

The marketing homepage stays on `https://letsgrow.dk/`. The same Next.js service
serves `https://app.letsgrow.dk`; its root redirects to `/dashboard`. Production
marketing-host `/login` and `/dashboard` URLs redirect to the app domain.
Localhost keeps these routes on one origin for development.

The browser gets the current Supabase access token through `AuthClient.getIdToken()`.
Typed team calls go through `/api/leader/teams/...`, which forwards the bearer
token to the Kotlin API. The Kotlin API alone verifies identity and permissions.
Set server-only `FEEDBACK_API_ORIGIN` to the reachable backend origin (locally
`http://localhost:8080`, in Compose `http://api:8080`). No provider token is
stored in cookies by this relay; requests and responses use no-store caching.

`/team-invite/[code]` is an employee handoff to the iOS custom scheme
`letsgrow://team-invite?code=...`, with an App Store link and manual code. It does
not create a join request in the browser. The matching iOS flow uses anonymous Supabase sessions and owner approval. Event invitations retain `/invite/[id]`.

`TeamContext.isOwner` gates organization/team creation and leadership administration; `managedTeams` already contains only the caller’s authorized scope. Team detail clears protected state on denied responses. `/leader-invite/[code]` keeps its personal token in the URL through shared email-code or Google login and explicitly accepts via the API; the API requires the matching verified email. Only owners create/revoke these links or remove leaders. Links expire after seven days and are distinct from employee invitations.

AuthProvider is scoped to `src/app/(account)/layout.tsx`, shared by login, dashboard and leader invitations. Public routes do not initialize auth. Supabase is imported only by the account route group, initializes from runtime configuration and rejects E2E authentication in production. Protected screen state is recreated on account changes.

Use the named operations in `src/lib/api/teams.ts` rather than constructing paths and choosing arbitrary response types in components. The relay propagates the request's cancellation signal, enforces a 15-second upstream timeout, rejects redirects and sends `Cache-Control: no-store` for both success and failure responses.

Managed provider setup, native configuration and fresh-start release/rollback: [Supabase auth](../../../docs/agents/supabase-auth.md). Pending personal invitations are listed before organization creation; provider roles never grant team authority.
