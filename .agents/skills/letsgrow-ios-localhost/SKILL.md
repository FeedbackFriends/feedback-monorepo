---
name: letsgrow-ios-localhost
description: Build the local LetsGrow backend, start API and Postgres, then build and launch the iOS app on a simulator using Feedback Localhost. Use for a complete local backend plus iOS development run.
---

# Build and run LetsGrow locally

Run from the monorepo root. Follow [iOS policy](../../../ios-app/AGENTS.md) and use the [shared simulator workflow](../../../ios-app/.agents/skills/letsgrow-ios-run-simulator/SKILL.md) for Xcode operations.

1. Run `./scripts/ios-backend localhost`. This builds `:api:jibDockerBuild` for the configured local image platform, starts API/Postgres through the root Compose files, and waits for health. Stop on failure and report the failing stage. Keep existing data; do not use `scripts/run`, reset/seed endpoints, or `docker compose down --volumes` as part of this workflow.
2. Use the shared simulator workflow in **launch-only mode**, explicitly selecting `Feedback Localhost`. Match this checkout's project, select an eligible simulator, and call native Xcode MCP `RunProject` to build, install, and launch. The app connects directly to `http://localhost:8080`; no proxy is needed. Do not substitute CLI Xcode or simulator commands.
3. If authenticated local testing was requested, launch directly using the [local login skill](../../../ios-app/.agents/skills/letsgrow-ios-login/SKILL.md) instead of the ordinary `RunProject` launch in step 2. Do not first launch unauthenticated and then launch again for login. Ordinary build/run does not reset fixtures or require login. Additional unit/UI tests are scoped to the user's request or the code change, not required merely to launch.

Report backend build/health, API URL, scheme, simulator, and app build/launch result separately. A successful launch does not prove login or an authenticated API journey. Report any remaining blocker explicitly and leave the local API/Postgres running for development.

Requirements and configuration ownership are in the [harness guide](../../../ios-app/Docs/agent-harness.md#build-and-run-workflows).
