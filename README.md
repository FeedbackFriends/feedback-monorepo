# LetsGrow

LetsGrow has a Next.js web app, Kotlin/Spring backend and scheduler, and a native SwiftUI/TCA iOS app.

| Area | Entry point |
| --- | --- |
| Shared and platform documentation | [Docs index](docs/README.md) |
| Web architecture and development | [Web guide](web/AGENTS.md) |
| Backend and scheduler | [Backend README](backend/README.md) |
| iOS | [iOS README](ios-app/README.md) |
| Agent instructions | [Root policy](AGENTS.md), [harness architecture](docs/agent-tooling.md) |
| Unfinished work | [Todos](todos.md) |

## Local development

Use Node.js from `web/.nvmrc` for web commands. The root Compose override supplies local Postgres and development wiring; the base Compose file defines production services.

Read [runtime and deployment](docs/agents/runtime-and-deployment.md) before running the stack. From the root, `./scripts/run -d` regenerates API artifacts, rebuilds images, and starts services. **It deletes local Compose volumes and their data.** For data-preserving backend startup and iOS launch, use the [iOS workflows](docs/agents/ios-workflows.md).

Keep credentials in the ignored root `.env` and local iOS configuration. Use `.env.example` and the owning app guides for setup. Production deployment is documented in [Coolify](docs/deployment/coolify.md).
