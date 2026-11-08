# iOS setup and agent harness

Start at the monorepo root. [Repository harness architecture](../shared/agent-tooling.md) owns shared instructions, skill provenance, and hooks. [iOS policy](../../ios-app/AGENTS.md) routes platform work.

## Prerequisites and manual development

Open `ios-app/Feedback.xcodeproj` from the monorepo root. `ios-app/Modules/Package.swift` owns module dependencies. Use Xcode 27 with Swift 6.2 or newer and an installed iOS 27 simulator runtime. Install SwiftLint (`brew install swiftlint`) and Python 3.

For manual development, select the `Feedback Localhost` scheme and an iOS simulator in Xcode, then Build & Run. Run the shared `UnitTests` plan from the same scheme. Other schemes target different configurations; `Feedback Production` is the production scheme.

Live authentication requires managed Supabase and Google configuration in the app's Info.plist, populated through `App/Config/secrets.xcconfig`; see [Supabase setup](../shared/agents/supabase-auth.md). Firebase configuration is still used for push and crash reporting. Keep that file local and ignored by Git. See [configuration](CONFIGURATION.md) and [local testing](local-testing.md) for local backend addressing and test-account login.

The backend owns the API contract. Regenerate the committed contract and both clients from the monorepo root using `./scripts/shared/generate-api-artifacts.sh`; do not hand-edit generated Swift sources.

## Project configuration format

`Feedback.xcodeproj/project.xcproj` is Xcode's native JSON project configuration. Xcode 27 or later is required to open it; Xcode 27.2 performed the migration from `project.pbxproj`. The `.xcodeproj` bundle, shared schemes, test plans, and command entry points retain their existing paths. The format permits trailing commas; use Xcode or format-aware tools when editing it.

Apple documents the conversion and rollback in [Updating your Xcode project configuration file format](https://developer.apple.com/documentation/xcode/updating-your-xcode-project-configuration-file-format). Its [open source format library](https://github.com/apple/xcode-project-format) describes the schema.

## Xcode MCP setup

Complete Xcode's first-launch setup and select the intended Xcode installation in its command-line tools settings. Open this repository as a trusted project in Codex or Claude Code.

The checked-in project configurations, `.codex/config.toml` and root `.mcp.json`, start Apple's native server using `xcrun mcpbridge`. After configuration changes, restart the MCP client. In either client, `/mcp` shows connections; `codex mcp list` or `claude mcp list` shows configured servers. Claude project servers may await approval before connecting. See [shared client setup](../shared/agent-tooling.md#claude-code-setup), [Codex MCP configuration](https://learn.chatgpt.com/docs/extend/mcp?surface=cli), and [Claude MCP configuration](https://code.claude.com/docs/en/mcp).

Verify the connection with `XcodeListWorkspaces`. Match this checkout's absolute `ios-app/Feedback.xcodeproj` path; use `XcodeOpenWorkspace` if absent. Follow Xcode's authorization prompts yourself if required. A missing connection or denied operation is a blocker to report, not a reason to switch local automation tools.

## Apple skills setup

Export guidance from the selected Xcode directly into the shared skills folder:

```sh
python3 scripts/shared/update-xcode-skills.py
```

Run this on a fresh checkout and after switching or upgrading Xcode. The helper uses `xcrun agent skills export --output-dir` to stage and validate guidance before updating Apple-owned folders directly in `.agents/skills/`. It creates Claude discovery symlinks under `.claude/skills/` and removes stale Apple skills and aliases. Generated `.gitignore` files keep Apple content and aliases local; `.agents/skills/.apple-skills.json` records export ownership and is also ignored. Custom and community skills remain tracked in the same shared folder; `skills-lock.json` owns community provenance.

The native export currently supplies 11 skills with Xcode 27.2. It does not include the plugin packages' translation and accessibility specialist skills. Export contents follow the selected Xcode. No plugin marketplace registration or client-specific package installation is needed. If migrating an existing installation, uninstall the old `xcode-integration@letsgrow-xcode` plugin in each client's plugin manager to prevent duplicate guidance; removing repository catalogs does not uninstall cached plugins.

Open a fresh session and confirm exported guidance appears in the skill catalog. Separately call `XcodeListWorkspaces` to verify the existing MCP connection. Export and symlink checks establish local installation, not session activation, a build, or device interaction.

Use loaded Apple guidance for native operations and the [simulator guide](agents/simulator.md) for LetsGrow schemes, tests, login, and verification. Repository and higher-priority client instructions retain precedence, including delegation authorization. Tool names and arguments come from current MCP descriptions. Optional missing guidance does not block operations whose tool descriptions are sufficient.

## Workflows

| Need | Owning procedure |
| --- | --- |
| Plan, implement, investigate, or review a feature | [Feature workflow](agents/feature-workflow.md) and [shared task lifecycle](../shared/agents/task-workflow.md) |
| Build, test, launch, or interact with a simulator | Loaded Apple guidance and [simulator policy](agents/simulator.md) |
| Local backend and manager/anonymous apps | [Localhost skill](../../.agents/skills/lg-ios-run-local/SKILL.md); [manual two-simulator setup](local-testing.md) |
| Release simulator build against deployed production | [Production skill](../../.agents/skills/lg-ios-run-production/SKILL.md) |
| Local test-account authentication | [Login skill](../../.agents/skills/lg-ios-login/SKILL.md) |
| UI catalog and baseline review | [Visual review](agents/visual-review.md) |
| Lint, tests, and CI boundaries | [Testing](agents/testing.md), [CI/CD](../shared/agents/ci-cd.md), and [iOS workflow source](../../.github/workflows/ios.yml) |
| Notification testing | [Notification skill](../../.agents/skills/lg-ios-test-notifications/SKILL.md) and [delivery runner](../../ios-app/.maestro/notifications/README.md) |

Local agent Xcode operations use native MCP. Explicit Maestro runners and hosted CI have their documented exceptions. Launch/login does not imply fixture reset; follow the chosen workflow's data-preservation rules. See [runtime guidance](../shared/agents/runtime-and-deployment.md) before other stack commands.

Validate affected guidance routing, metadata, and links; helper changes also need their relevant regression checks.
