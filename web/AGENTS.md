# Repository Guidelines

## Project Structure & Module Organization
This repository is a single Next.js App Router frontend. Application routes live in `src/app` (`page.tsx`, `layout.tsx`, `api/*/route.ts`, and nested routes such as `invite/[id]`). Reusable UI is split across `src/components/layout`, `src/components/pages`, `src/components/sections`, and `src/components/ui`. Shared helpers belong in `src/lib`. Static assets, logos, and marketing imagery live in `public/` and `public/branding/`.

## Build, Test, and Development Commands
Use `npm install` to sync dependencies from `package-lock.json`.

- `npm run dev`: start the local Next.js dev server.
- `npm run build`: create a production build; catches many route and config issues.
- `npm run start`: serve the production build locally.
- `npm run lint`: run ESLint across the repo.

There is no dedicated test runner configured yet, so `lint` and `build` are the current required checks before merging.

## Coding Style & Naming Conventions
TypeScript is strict; keep new code typed and avoid `any` unless justified. Follow the existing App Router conventions: route files use Next.js names (`page.tsx`, `layout.tsx`, `route.ts`), React components use PascalCase file names (`MarketingShell.tsx`), and shared utilities use lower-case names in `src/lib`.

Use the `@/*` import alias for code under `src`. Match the surrounding file’s formatting style, keep indentation to two spaces, and prefer small, composable components. ESLint is configured in `eslint.config.js` with `@next/next` core web vitals and React Hooks rules; fix warnings before opening a PR.

## Testing Guidelines
Add tests alongside the feature when introducing non-trivial logic. Until a test framework is added, verify changes with `npm run lint` and `npm run build`, then smoke-test affected routes such as `/`, `/invite/[id]`, and `/privacy-policy`. For API work, confirm `src/app/api/health/route.ts` still returns `{"ok":true}`.

## Commit & Pull Request Guidelines
Recent history uses short, imperative commit subjects with sentence casing, for example `Fix Render web host binding` and `Add Lets Grow app icons`. Keep commits focused and descriptive.

PRs should include a short summary, linked issue or context, and screenshots for UI changes. Call out environment or deployment changes explicitly, especially anything touching `NEXT_PUBLIC_*` variables or Render configuration.

## Configuration Tips
Client-exposed settings belong in `NEXT_PUBLIC_*` variables only. Review `src/lib/letsgrow.ts` before changing signup or campaign URLs, and do not hardcode secrets into components or route handlers.
