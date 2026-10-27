---
name: letsgrow-ios-production
description: Build and launch the LetsGrow iOS app on a simulator against the existing Coolify production API using the Feedback Production Release scheme. Use for running the app against production, without deploying backend services or publishing the app.
---

# Build and run LetsGrow against production

Run from the monorepo root. Follow [iOS policy](../../../ios-app/AGENTS.md) and the [shared simulator workflow](../../../ios-app/.agents/skills/letsgrow-ios-run-simulator/SKILL.md) for native Xcode MCP operations.

1. Run `./scripts/ios-backend production` to check HTTP success and `status: UP` on the existing `https://api.letsgrow.dk/actuator/health` endpoint. This mode does not require Docker, local backend services, or a Coolify token. On failure, report the production health blocker. If deployment troubleshooting was requested, use the [Coolify operations skill](../coolify-operations/SKILL.md); do not redeploy as part of an app build.
2. Use the shared simulator workflow in **launch-only mode**, explicitly selecting `Feedback Production` (Release), not `Debug Production` or `Feedback Localhost`. Match the current checkout and use an eligible simulator. Call `RunProject` to build, install, and launch through native Xcode MCP. Do not archive, upload to TestFlight/App Store, or change Coolify services.
3. Observe launch success. Do not inject localhost admin-login arguments or reset/seed production data. If login is needed, the user signs in normally through the app. Unit tests belong to `Feedback Localhost`/`UnitTests`, not this production launch scheme.

Report production health, API URL, scheme/configuration, simulator, and app build/launch result separately. State whether login or any API journey was actually checked. A production app run uses real production data; additional mutations require the user's requested product action.

See the [harness guide](../../../ios-app/Docs/agent-harness.md#build-and-run-workflows) for setup and runtime assumptions.
