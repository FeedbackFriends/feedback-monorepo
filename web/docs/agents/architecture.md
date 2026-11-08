# Web architecture

Paths are relative to `web/` unless stated otherwise.

## Tech Stack

- Next.js 16 with the App Router
- React 19
- TypeScript
- Tailwind CSS
- Radix UI / shadcn-style primitives
- Supabase client auth
- Playwright for end-to-end tests
- Node.js `24.22.2` from `.nvmrc` and `package.json`

## Project Structure

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

## Coding Style

- Prefer server components unless client state, browser APIs, Supabase auth, or effects require `"use client"`.
- Keep route files thin. Move reusable UI and logic into components or `src/lib`.
- Use existing UI primitives before adding new ones.
- Use `lucide-react` icons where an icon is appropriate.
- Keep customer-facing copy plain and concrete. LetsGrow is Danish-first unless the task asks for English.
- Do not introduce fallback behavior for missing required config; throw clear errors.
- Treat `NEXT_PUBLIC_*` values as client-exposed and never put secrets in them.

## Community guidance compatibility

Use `next-best-practices` for Next.js architecture and conventions, `vercel-react-best-practices` for relevant performance concerns, and `vercel-composition-patterns` when designing reusable component APIs. Use `next-upgrade` for framework migrations. Runtime verification follows the [validation guide](validation.md#nextjs-runtime-verification).

Use `next-best-practices` as a discovery aid alongside the version-matched Next.js documentation required by web policy. Its upstream `rsc-boundaries.md` incorrectly restricts props to JSON types: React supports `Date`, `Map`, and `Set` containing serializable values across the Server/Client boundary. Follow [React's supported types](https://react.dev/reference/rsc/use-client#serializable-types-returned-by-server-components), rather than converting those types solely to satisfy that reference. This boundary differs from the JSON HTTP API contract.

Cache Components are not enabled in the current configuration. Adopt caching only for an agreed need and verify the installed version's APIs. For tag invalidation, follow [Next.js revalidateTag](https://nextjs.org/docs/app/api-reference/functions/revalidateTag): `revalidateTag(tag, 'max')` uses stale-while-revalidate; the deprecated single-argument call is not the background-revalidation pattern.

## Data ownership

Protected data stays in the browser's authenticated feature tree. `DashboardShell` keys that tree by account ID so a changed identity discards protected state. `useTeamResource` owns request cancellation, ordering, mutation locking, loading/error state and clearing data on 401/403/404. Requests are scoped to a mounted screen; there is no shared user-data cache. Mutation cancellation prevents stale UI updates and does not undo work already accepted by the backend. Creation drafts preserve submission IDs across retries.

Use named operations in `lib/api/teams.ts`, with inputs/results derived from the generated OpenAPI types; keep arbitrary response casts inside the transport boundary. `requestAPI` owns HTTP errors and safe display copy. The Next.js relay forwards only allowed team paths and bearer tokens; Kotlin owns identity and permission checks.

Public landing/privacy content renders without auth. Supabase is loaded only inside the account route group; runtime Supabase configuration stays uncached and deployment-specific. Test authentication is available only in development. Public metadata and sitemap use the marketing domain; app-host responses and invitation/account metadata prevent indexing.

Brand-logo links do not prefetch the marketing homepage. Prefetching that optional surface from login would eagerly download its animation code before the user needs it. Supabase stays a static dependency of the account route: another dynamic import adds an initialization waterfall without reducing the authenticated route's required code.
