# LetsGrow web

Next.js frontend for LetsGrow, using React, TypeScript, Tailwind CSS, and Supabase client auth.

Use npm with Node.js `24.22.2`; run web commands from `web/`. The `dev`, `build`, and `start` scripts load the root `.env` through `dotenv-cli`.

## Read when relevant

| Task | Guidance |
| --- | --- |
| Task refinement, implementation, review, or handoff | [Shared task workflow](../docs/agents/task-workflow.md) |
| Routes, components, or code organization | [Architecture and coding conventions](#architecture-and-conventions) |
| Layout, styling, or responsive behavior | [UI guidelines](docs/agents/ui.md) |
| API types, authentication, or environment | [API and auth](#api-authentication-and-environment) |
| Running, testing, or validating changes | [Commands and validation](docs/agents/validation.md) |

Repository-wide rules remain in the [root AGENTS.md](../AGENTS.md).

## Leader application UI

Use shadcn registry components and blocks wherever available for the leader application. Compose product screens from those primitives; do not build replacement controls, browser confirm dialogs, bespoke cards, selects, tables, or app-shell primitives. Use `components.json` and the configured shadcn MCP/CLI to discover and add official components. Keep UI primitives in `src/components/ui`; product behavior belongs outside them. Marketing-specific components remain separate.

<!-- BEGIN:nextjs-agent-rules -->

## This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory; in monorepos the `next` package may not be visible from the repo root) before writing any code. Heed deprecation notices.

This block is written and re-added by `next dev` — verify at `node_modules/next/dist/server/lib/generate-agent-files.js`. Removing it from a diff only re-creates the uncommitted change; committing it with your work keeps the tree clean.

<!-- END:nextjs-agent-rules -->

## API, authentication, and environment

### API Contract

- `src/lib/api/generated/openapi.ts` is generated from `contracts/openapi/feedback-api.yaml`; never hand-edit it.
- When the contract changes, regenerate from the monorepo root with `./scripts/generate-api-artifacts.sh` and update typed call sites.
- Backend controllers, DTOs, and OpenAPI configuration own API shape; see the [shared API contract guide](../docs/agents/api-contract.md).

### Auth And Environment

- Supabase client auth lives under `src/lib/auth/`.
- E2E auth helpers live under `src/lib/auth/e2e-auth-client.ts`.
- Root `.env` supplies runtime values. Never commit secrets.
- Treat `NEXT_PUBLIC_*` values as client-exposed and never put secrets in them.

### Leader application

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

Managed provider setup, native configuration and fresh-start release/rollback: [Supabase auth](../docs/agents/supabase-auth.md). Pending personal invitations are listed before organization creation; provider roles never grant team authority.

## Architecture and conventions

### Tech Stack

- Next.js 16 with the App Router
- React 19
- TypeScript
- Tailwind CSS
- Radix UI / shadcn-style primitives
- Supabase client auth
- Playwright for end-to-end tests
- Node.js `24.22.2` from `.nvmrc` and `package.json`

### Project Structure

- `src/app/`: App Router routes, layouts, metadata, route handlers, and page-level composition.
- `src/app/api/`: Next.js route handlers.
- `src/app/(account)/`: shared AuthProvider for login, dashboard and leader invitations; the route group preserves public URL paths.
- `src/components/auth/`: session provider and login UI.
- `src/components/dashboard/`: authenticated shell and legacy dashboard views.
- `src/components/teams/`: team/employee/leader-invitation screens, feature UI and ordered request lifecycle.
- `src/components/landing/`: marketing landing page content and sections.
- `src/components/layout/`: site-level layout components.
- `src/components/ui/`: reusable UI primitives.
- `src/lib/api/generated/openapi.ts`: generated TypeScript API types. Do not hand-edit.
- `src/lib/auth/`: Supabase and e2e auth client wiring.
- `tests/`: Playwright tests.
- `public/`: static assets.

### Coding Style

- Prefer server components unless client state, browser APIs, Supabase auth, or effects require `"use client"`.
- Keep route files thin. Move reusable UI and logic into components or `src/lib`.
- Use existing UI primitives before adding new ones.
- Use `lucide-react` icons where an icon is appropriate.
- Keep customer-facing copy plain and concrete. LetsGrow is Danish-first unless the task asks for English.
- Do not introduce fallback behavior for missing required config; throw clear errors.
- Treat `NEXT_PUBLIC_*` values as client-exposed and never put secrets in them.

### Community guidance compatibility

Use `next-best-practices` for Next.js architecture and conventions, `vercel-react-best-practices` for relevant performance concerns, and `vercel-composition-patterns` when designing reusable component APIs. Use `next-upgrade` for framework migrations. Runtime verification follows the [validation guide](docs/agents/validation.md#nextjs-runtime-verification).

Use `next-best-practices` as a discovery aid alongside the version-matched Next.js documentation required by web policy. Its upstream `rsc-boundaries.md` incorrectly restricts props to JSON types: React supports `Date`, `Map`, and `Set` containing serializable values across the Server/Client boundary. Follow [React's supported types](https://react.dev/reference/rsc/use-client#serializable-types-returned-by-server-components), rather than converting those types solely to satisfy that reference. This boundary differs from the JSON HTTP API contract.

Cache Components are not enabled in the current configuration. Adopt caching only for an agreed need and verify the installed version's APIs. For tag invalidation, follow [Next.js revalidateTag](https://nextjs.org/docs/app/api-reference/functions/revalidateTag): `revalidateTag(tag, 'max')` uses stale-while-revalidate; the deprecated single-argument call is not the background-revalidation pattern.

### Data ownership

Protected data stays in the browser's authenticated feature tree. `DashboardShell` keys that tree by account ID so a changed identity discards protected state. `useTeamResource` owns request cancellation, ordering, mutation locking, loading/error state and clearing data on 401/403/404. Requests are scoped to a mounted screen; there is no shared user-data cache. Mutation cancellation prevents stale UI updates and does not undo work already accepted by the backend. Creation drafts preserve submission IDs across retries.

Use named operations in `lib/api/teams.ts`, with inputs/results derived from the generated OpenAPI types; keep arbitrary response casts inside the transport boundary. `requestAPI` owns HTTP errors and safe display copy. The Next.js relay forwards only allowed team paths and bearer tokens; Kotlin owns identity and permission checks.

Public landing/privacy content renders without auth. Supabase is loaded only inside the account route group; runtime Supabase configuration stays uncached and deployment-specific. Test authentication is available only in development. Public metadata and sitemap use the marketing domain; app-host responses and invitation/account metadata prevent indexing.

Brand-logo links do not prefetch the marketing homepage. Prefetching that optional surface from login would eagerly download its animation code before the user needs it. Supabase stays a static dependency of the account route: another dynamic import adds an initialization waterfall without reducing the authenticated route's required code.
