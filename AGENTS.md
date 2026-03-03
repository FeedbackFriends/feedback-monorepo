# Repository Guidelines

## Project Scope
This directory is the monorepo root. Work here should stay focused on cross-cutting repository concerns such as CI/CD, GitHub Actions, Docker Compose, shared tooling, root documentation, and Render infrastructure in `render.yaml`.

Do not use the root agent setup for normal application development inside `web/` or `backend/`. Those folders have their own `AGENTS.md` files and should be treated as the source of truth for frontend and backend development workflows.

## Project Structure & Ownership
- `render.yaml`: Render Blueprint for the deployed services and database. This is the root infrastructure source of truth.
- `docker-compose.yml`: local multi-service smoke-test entry point from the monorepo root.
- `web/`: frontend application. If the task is primarily UI, Next.js, routes, components, or frontend build behavior, switch into `web/` and follow `web/AGENTS.md`.
- `backend/`: backend application. If the task is primarily API, scheduler, database migrations, Kotlin, or service logic, switch into `backend/` and follow `backend/AGENTS.md`.
- Root files such as `README.md`, GitHub workflow files, and shared automation config belong to the root agent scope.

## Routing Rules
Before making changes, decide whether the task belongs at the root or inside a product app.

Use the root agent setup for:
- `render.yaml`
- `.github/workflows/`
- `docker-compose.yml`
- repo-wide docs or automation
- coordination across `web/` and `backend/`

Do not implement frontend or backend feature work from the root. Instead:
1. Change into `web/` for frontend development tasks.
2. Change into `backend/` for backend development tasks.
3. Read and follow the local `AGENTS.md` in that folder before editing code there.

If a task spans multiple areas, keep root changes limited to orchestration and infra, and make app-specific changes from the relevant subdirectory with its local agent instructions.

## Shared Skills
- `pr-workflow`: shared PR wrap-up guidance in [`.agents/skills/pr-workflow/SKILL.md`](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/.agents/skills/pr-workflow/SKILL.md). Use when a task is wrapping up, when the user asks for a PR title or description, or when summarizing validation and review impact.

## Build, Test, and Validation Commands
- `sed -n '1,240p' render.yaml`: inspect the current Render Blueprint before editing.
- `git diff -- render.yaml`: review infrastructure-only edits before committing.
- `git diff -- .github/workflows`: review CI/CD changes before committing.
- `docker compose up --build`: smoke-test the full stack wiring from the repo root when service integration changes.
- `git log --oneline -- render.yaml`: inspect recent infrastructure history and naming patterns.

When application behavior must be validated in detail, run the relevant commands from `web/` or `backend/` under those folders' instructions instead of inventing a root-level workflow.

## Editing Conventions
Use two-space indentation in YAML files such as `render.yaml` and GitHub Actions workflows. Keep Render resource definitions easy to scan: metadata first, then build/run settings, health checks, domains, and `envVars`.

Preserve existing service naming patterns such as `feedback-api`, `feedback-scheduler`, `feedback-web`, and `feedback-db`. Prefer explicit configuration over YAML anchors or clever indirection.

## Deployment & Render Notes
Render resources belong in the `FeedbackFriends` workspace. 
Use Render MCP read operations freely for inspection, but explicitly select the correct workspace before any mutating action.
Call out plan, disk, region, or other cost-affecting changes clearly in review.

## GitHub Actions Ways Of Working
Treat `.github/workflows/` as root-owned CI/CD infrastructure. Changes here should be deliberate because they can affect branch protection, release behavior, cache usage, required secrets, and Render deploy readiness.

When editing GitHub Actions:
- verify triggers such as `push`, `pull_request`, and `workflow_dispatch`
- keep `permissions` minimal and explicit
- review concurrency and cache settings so they still match repository behavior
- call out new secrets, tokens, registries, or external services in your summary
- prefer small, reviewable changes instead of broad workflow rewrites unless the task requires it

Current workflow intent:
- `ci.yml` validates backend and web changes for pull requests and pushes to `main`
- `release.yml` is a manual release pipeline for artifacts, Docker images, OpenAPI output, and GitHub releases
- `dependabot.yml` manages automated dependency update policy

## Ways Of Working
Use the root agent for coordination-heavy work and operational changes, not product feature development inside `web/` or `backend/`.

PR culture in this repository should stay review-friendly:
- keep changes scoped to one concern
- make root-level operational impact obvious in the summary
- mention any secrets, domain changes, deployment consequences, or cost changes
- avoid mixing unrelated app code with infrastructure or workflow edits from the root
- if a task spans root plus app code, do the app-specific work from the relevant subdirectory and keep the root diff focused on orchestration

When the work appears complete, use the shared `pr-workflow` skill to prepare the PR title, description, and validation summary.

## Commit & Pull Request Guidelines
Use short, imperative commit subjects with sentence casing, for example `Fix Render web host binding` or `Update CI cache key`.

Keep commits narrowly scoped to one operational concern. PRs should summarize deployment or pipeline impact, mention new secrets or domain changes, and note any cost-affecting infrastructure edits.

## Security & Configuration Tips
Never commit secret values into `render.yaml`, workflow files, or other root config. Secrets belong in Render-managed environment variables, GitHub Actions secrets, or other managed secret stores.

Treat root-level changes as production-sensitive by default. Infrastructure, CI/CD, domains, database sizing, and workspace targeting should be changed deliberately and reviewed carefully.
