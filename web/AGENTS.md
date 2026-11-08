# LetsGrow web

Next.js frontend for LetsGrow, using React, TypeScript, Tailwind CSS, and Supabase client auth.

Use npm with Node.js `24.22.2`; run web commands from `web/`. The `dev`, `build`, and `start` scripts load the root `.env` through `dotenv-cli`.

## Read when relevant

| Task | Guidance |
| --- | --- |
| Task refinement, implementation, review, or handoff | [Shared task workflow](../docs/agents/task-workflow.md) |
| Routes, components, or code organization | [Architecture and coding conventions](docs/agents/architecture.md) |
| Layout, styling, or responsive behavior | [UI guidelines](docs/agents/ui.md) |
| API types, authentication, or environment | [API and auth](docs/agents/api-and-auth.md) |
| Running, testing, or validating changes | [Commands and validation](docs/agents/validation.md) |

Repository-wide rules remain in the [root AGENTS.md](../AGENTS.md).

## Leader application UI

Use shadcn registry components and blocks wherever available for the leader application. Compose product screens from those primitives; do not build replacement controls, browser confirm dialogs, bespoke cards, selects, tables, or app-shell primitives. Use `components.json` and the configured shadcn MCP/CLI to discover and add official components. Keep UI primitives in `src/components/ui`; product behavior belongs outside them. Marketing-specific components remain separate.

<!-- BEGIN:nextjs-agent-rules -->

## This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory; in monorepos the `next` package may not be visible from the repo root) before writing any code. Heed deprecation notices.

This block is written and re-added by `next dev` — verify at `node_modules/next/dist/server/lib/generate-agent-files.js`. Removing it from a diff only re-creates the uncommitted change; committing it with your work keeps the tree clean.

<!-- END:nextjs-agent-rules -->
