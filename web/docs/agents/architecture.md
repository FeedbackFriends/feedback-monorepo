# Web architecture

Paths are relative to `web/` unless stated otherwise.

## Tech Stack

- Next.js 16 with the App Router
- React 19
- TypeScript
- Tailwind CSS
- Radix UI / shadcn-style primitives
- Firebase client auth
- Playwright for end-to-end tests
- Node.js `20.19.0` from `.nvmrc` and `package.json`

## Project Structure

- `src/app/`: App Router routes, layouts, metadata, route handlers, and page-level composition.
- `src/app/api/`: Next.js route handlers.
- `src/components/auth/`: authenticated shells, login, dashboard, and auth-bound UI.
- `src/components/landing/`: marketing landing page content and sections.
- `src/components/layout/`: site-level layout components.
- `src/components/ui/`: reusable UI primitives.
- `src/lib/api/generated/openapi.ts`: generated TypeScript API types. Do not hand-edit.
- `src/lib/auth/`: Firebase and e2e auth client wiring.
- `tests/`: Playwright tests.
- `public/`: static assets.

## Coding Style

- Prefer server components unless client state, browser APIs, Firebase auth, or effects require `"use client"`.
- Keep route files thin. Move reusable UI and logic into components or `src/lib`.
- Use existing UI primitives before adding new ones.
- Use `lucide-react` icons where an icon is appropriate.
- Keep customer-facing copy plain and concrete. LetsGrow is Danish-first unless the task asks for English.
- Do not introduce fallback behavior for missing required config; throw clear errors.
- Treat `NEXT_PUBLIC_*` values as client-exposed and never put secrets in them.

## Community guidance compatibility

Use `next-best-practices` as a discovery aid alongside the version-matched Next.js documentation required by web policy. Its upstream `rsc-boundaries.md` incorrectly restricts props to JSON types: React supports `Date`, `Map`, and `Set` containing serializable values across the Server/Client boundary. Follow [React's supported types](https://react.dev/reference/rsc/use-client#serializable-types-returned-by-server-components), rather than converting those types solely to satisfy that reference. This boundary differs from the JSON HTTP API contract.

Cache Components are not enabled in the current configuration. Adopt caching only for an agreed need and verify the installed version's APIs. For tag invalidation, follow [Next.js revalidateTag](https://nextjs.org/docs/app/api-reference/functions/revalidateTag): `revalidateTag(tag, 'max')` uses stale-while-revalidate; the deprecated single-argument call is not the background-revalidation pattern.
