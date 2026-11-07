# iOS agent harness

Start at the monorepo root. [Repository harness architecture](../../docs/agent-tooling.md) owns shared instructions, skill provenance, and hooks. [iOS policy](../AGENTS.md) routes platform work; [setup](SETUP.md) owns prerequisites and project configuration.

## Xcode MCP setup

Use Xcode 27 with the installed iOS 27 simulator runtime, complete Xcode's first-launch setup, and select the intended Xcode installation in its command-line tools settings. Install SwiftLint (`brew install swiftlint`) and Python 3. Open this repository as a trusted project in Codex or Claude Code.

The checked-in project configurations, `.codex/config.toml` and root `.mcp.json`, start Apple's native server using `xcrun mcpbridge`. After configuration changes, restart the MCP client. In either client, `/mcp` shows connections; `codex mcp list` or `claude mcp list` shows configured servers. Claude project servers may await approval before connecting. See [shared client setup](../../docs/agent-tooling.md#claude-code-setup), [Codex MCP configuration](https://learn.chatgpt.com/docs/extend/mcp?surface=cli), and [Claude MCP configuration](https://code.claude.com/docs/en/mcp).

Verify the connection with `XcodeListWorkspaces`. Match this checkout's absolute `ios-app/Feedback.xcodeproj` path; use `XcodeOpenWorkspace` if absent. Follow Xcode's authorization prompts yourself if required. A missing connection or denied operation is a blocker to report, not a reason to switch local automation tools.

## Apple plugin setup

Apple's `xcode-integration` plugin supplies skills such as `device-interaction` and translation guidance. The MCP connection supplies tools separately. This repository's client catalogs discover ignored copies of the official packages exported by the selected Xcode; Apple content and machine-specific paths stay outside Git.

From the monorepo root, prepare both client packages:

```sh
python3 scripts/setup-xcode-plugin.py
```

The helper requires Xcode's `xcrun agent plugin path --plugin-format` support (verified with Xcode 27.2). It validates both exports before replacing local copies under `.agents/local-plugins/`. Run it before the first plugin-enabled session, and again after changing the selected Xcode or upgrading it. A fresh checkout needs this step before its catalog sources exist.

For **Codex**, the tracked `.agents/plugins/marketplace.json` exposes `xcode-integration@letsgrow-xcode`; trusted project configuration enables it. Install or refresh its cached copy after preparation:

```sh
codex plugin marketplace add .
codex plugin add xcode-integration@letsgrow-xcode
```

For **Claude Code**, register the tracked `.claude-plugin/marketplace.json` catalog and install for this checkout only:

```sh
claude plugin marketplace add . --scope local
claude plugin install xcode-integration@letsgrow-xcode --scope local
```

On refresh, run preparation again, then `claude plugin update xcode-integration@letsgrow-xcode`. Local Claude settings remain ignored. Client versions must support local plugin marketplaces; consult their `plugin --help` if a command is unavailable. The catalogs contain skills only; the existing project MCP connection remains the owner of Xcode tools.

Restart the client or open a fresh session after installation/refresh. Confirm `xcode-integration:device-interaction` is in the skill picker/catalog, then call `XcodeListWorkspaces` separately to verify MCP. A successful export or manifest check proves neither session activation nor a build or device interaction. If using another desktop/IDE client, select the local **LetsGrow Xcode** marketplace and confirm skill discovery there; CLI installation alone does not prove that surface loaded it.

Use loaded Apple guidance for native operations and the [simulator guide](agents/simulator.md) for LetsGrow schemes, tests, login, and verification. Repository and higher-priority client instructions retain precedence, including delegation authorization. If Apple guidance requests a worker agent, delegate only when the current session permits it; otherwise execute directly with the exposed native tools. Tool names and arguments come from current MCP descriptions. If a required skill cannot be loaded, report that gap; optional missing guidance does not block operations whose tool descriptions are sufficient.


## Workflows

| Need | Owning procedure |
| --- | --- |
| Plan, implement, investigate, or review a feature | [Feature workflow](agents/feature-workflow.md) and [shared task lifecycle](../../docs/agents/task-workflow.md) |
| Build, test, launch, or interact with a simulator | Loaded Apple guidance and [simulator policy](agents/simulator.md) |
| Local backend and manager/anonymous apps | [Localhost skill](../../.agents/skills/lg-ios-localhost/SKILL.md); [manual two-simulator setup](local-testing.md) |
| Release simulator build against deployed production | [Production skill](../../.agents/skills/lg-ios-production/SKILL.md) |
| Local test-account authentication | [Login skill](../../.agents/skills/lg-ios-login/SKILL.md) |
| UI catalog and baseline review | [Visual review](agents/visual-review.md) |
| Lint, tests, and CI boundaries | [Testing](agents/testing.md), [CI/CD](../../docs/agents/ci-cd.md), and [iOS workflow source](../../.github/workflows/ios.yml) |
| Notification testing | [Notification skill](../../.agents/skills/lg-ios-test-notifications/SKILL.md) and [delivery runner](../.maestro/notifications/README.md) |

Local agent Xcode operations use native MCP. Explicit Maestro runners and hosted CI have their documented exceptions. Launch/login does not imply fixture reset; follow the chosen workflow's data-preservation rules. See [runtime guidance](../../docs/agents/runtime-and-deployment.md) before other stack commands.

Validate affected guidance routing, metadata, and links; helper changes also need their relevant regression checks.
