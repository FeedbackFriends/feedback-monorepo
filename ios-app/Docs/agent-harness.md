# iOS agent harness

Start at the monorepo root. [Repository harness architecture](../../docs/agent-tooling.md) owns shared instructions, skill provenance, and hooks. [iOS policy](../AGENTS.md) routes platform work; [setup](SETUP.md) owns prerequisites and project configuration.

## Xcode MCP setup

Use Xcode 27 with the installed iOS 27 simulator runtime, complete Xcode's first-launch setup, and select the intended Xcode installation in its command-line tools settings. Install SwiftLint (`brew install swiftlint`) and Python 3. Open this repository as a trusted project in Codex or Claude Code.

The checked-in project configurations, `.codex/config.toml` and root `.mcp.json`, start Apple's native server using `xcrun mcpbridge`. After configuration changes, restart the MCP client. In either client, `/mcp` shows connections; `codex mcp list` or `claude mcp list` shows configured servers. Claude project servers may await approval before connecting. See [shared client setup](../../docs/agent-tooling.md#claude-code-setup), [Codex MCP configuration](https://learn.chatgpt.com/docs/extend/mcp?surface=cli), and [Claude MCP configuration](https://code.claude.com/docs/en/mcp).

Verify the connection with `XcodeListWorkspaces`. Match this checkout's absolute `ios-app/Feedback.xcodeproj` path; use `XcodeOpenWorkspace` if absent. Follow Xcode's authorization prompts yourself if required. A missing connection or denied operation is a blocker to report, not a reason to switch local automation tools.

Apple's built-in guidance is discovered from the current client and native Xcode MCP responses. Its names and availability may change between Xcode and client versions, so this repository does not pin or vendor those skills. Follow the [simulator workflow](../../.agents/skills/lg-ios-run-simulator/SKILL.md) for discovery and direct native operation when a referenced instruction resource is not exposed. Repository workflows retain LetsGrow-specific scheme, test, login, and verification rules.

## Workflows

| Need | Owning procedure |
| --- | --- |
| Plan, implement, investigate, or review a feature | [Feature workflow](agents/feature-workflow.md) and [shared task lifecycle](../../docs/agents/task-workflow.md) |
| Build, test, launch, or interact with a simulator | [Native Xcode workflow](../../.agents/skills/lg-ios-run-simulator/SKILL.md) and [simulator policy](agents/simulator.md) |
| Local backend and manager/anonymous apps | [Localhost skill](../../.agents/skills/lg-ios-localhost/SKILL.md); [manual two-simulator setup](local-testing.md) |
| Release simulator build against deployed production | [Production skill](../../.agents/skills/lg-ios-production/SKILL.md) |
| Local test-account authentication | [Login skill](../../.agents/skills/lg-ios-login/SKILL.md) |
| UI catalog and baseline review | [Visual review](agents/visual-review.md) |
| Lint, tests, and CI boundaries | [Testing](agents/testing.md), [CI/CD](../../docs/agents/ci-cd.md), and [iOS workflow source](../../.github/workflows/ios.yml) |
| Notification testing | [Notification skill](../../.agents/skills/lg-ios-test-notifications/SKILL.md) and [delivery runner](../.maestro/notifications/README.md) |

Local agent Xcode operations use native MCP. Explicit Maestro runners and hosted CI have their documented exceptions. Launch/login does not imply fixture reset; follow the chosen workflow's data-preservation rules. See [runtime guidance](../../docs/agents/runtime-and-deployment.md) before other stack commands.

The [guidance navigator](SETUP.md#repository-guidance-in-the-navigator) exposes checked-in docs and skills without target membership. Refresh it after guidance moves. Validate affected routing, metadata, and links; helper changes also need their relevant regression checks.
