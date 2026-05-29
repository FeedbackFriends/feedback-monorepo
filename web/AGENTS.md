# Web App Guidelines

## Scope
Work in `web/` for the Next.js frontend: routes, React components, layout, styling, Firebase client auth, generated TypeScript API types, Playwright tests, and the web Docker image.

Keep work in this subtree focused on the web app. If the API contract changes, regenerate artifacts from the monorepo root.

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

## API Contract
- `src/lib/api/generated/openapi.ts` is generated from `contracts/openapi/feedback-api.yaml`.
- Do not hand-edit generated API types.
- The committed OpenAPI contract is the source of truth for generated web API types.
- When the contract changes, regenerate from the root and update typed call sites.

## Coding Style
- Prefer server components unless client state, browser APIs, Firebase auth, or effects require `"use client"`.
- Keep route files thin. Move reusable UI and logic into components or `src/lib`.
- Use existing UI primitives before adding new ones.
- Use `lucide-react` icons where an icon is appropriate.
- Keep customer-facing copy plain and concrete. LetsGrow is Danish-first unless the task asks for English.
- Do not introduce fallback behavior for missing required config; throw clear errors.
- Treat `NEXT_PUBLIC_*` values as client-exposed and never put secrets in them.

## UI Guidelines
- Build the actual product experience first, not a marketing placeholder.
- Keep operational/dashboard UI dense, calm, and easy to scan.
- Avoid nested cards, decorative gradient orbs, and one-note color palettes.
- Keep cards to individual repeated items, modals, or framed tools.
- Make text fit its container across mobile and desktop.
- Use stable dimensions for controls, boards, counters, tiles, and toolbars so state changes do not shift layout.

## Auth And Environment
- Firebase client auth lives under `src/lib/auth/`.
- E2E auth helpers live under `src/lib/auth/e2e-auth-client.ts`.
- Root `.env` supplies runtime values. Never commit secrets.
- Remember that `NEXT_PUBLIC_*` values are visible to browsers.

## Testing And Validation
- Run `npm run lint` for TypeScript/React changes.
- Run `npm run build` for route, config, or data-loading changes.
- Run `npm run test:e2e` when changing login, dashboard, invite, or other user-facing flows covered by Playwright.
- For visual work, inspect responsive behavior on mobile and desktop before finishing.
