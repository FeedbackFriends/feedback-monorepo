# LetsGrow iOS

Native LetsGrow iOS app using SwiftUI and The Composable Architecture, targeting iOS 26+ with Swift 6.2 and Xcode 27.

Use Swift Package Manager. The main project is `Feedback.xcodeproj`; the development scheme is `Feedback Localhost`.

- Never create or switch branches unless the user explicitly asks.
- When asked to commit and push, commit the intended changes and push the current branch.
- Use native Xcode MCP for Xcode/simulator operations and discover Apple's available built-in guidance dynamically; read the simulator guide before build, test, launch, or verification work.

## Non-standard validation

For Swift changes, run `python3 ios-app/scripts/lint-swift-changes.py --base <merge-base>` from the monorepo root. Use the merge base with the target branch (normally `origin/main`), or `HEAD` for uncommitted changes only. Follow the testing guide for changed-line lint rules and reporting.

## Read when relevant

| Task | Guidance |
| --- | --- |
| Features, dependencies, shared state, or module ownership | [Architecture and state](Docs/agents/architecture.md) |
| API adapters, mappers, or generated clients | [API integration](Docs/agents/api-contract.md) |
| SwiftUI/reducer naming or form validation | [UI conventions](Docs/agents/ui.md) |
| Build, test, launch, simulator interaction, or login | [Simulator workflows](Docs/agents/simulator.md) |
| UI changes, screenshots, or baseline acceptance | [Visual review](Docs/agents/visual-review.md) |
| Swift tests, linting, CI, or Maestro flows | [Testing and linting](Docs/agents/testing.md) |
| Product copy, onboarding, or domain naming | [Product language](Docs/agents/product-language.md) |

Repository-wide rules remain in the [root AGENTS.md](../AGENTS.md). For backend preparation and local/production app launch, use the [shared iOS workflows](../docs/agents/ios-workflows.md).
