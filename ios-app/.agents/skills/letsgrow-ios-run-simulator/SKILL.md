---
name: letsgrow-ios-run-simulator
description: Build, run, and verify the LetsGrow iOS app on a simulator through native Xcode MCP using the Feedback Localhost scheme. Use when asked to launch or test the iOS app locally.
---

# Run LetsGrow on a Simulator

Use native `mcp__xcode` tools for every Xcode and simulator operation. Follow `ios-app/AGENTS.md`. Use `Feedback Localhost` for builds, runs, and tests. Prefer the current simulator unless the user specifies another; do not pin an old simulator model or OS version.

1. Discover the project's workspace identifier with `XcodeListWorkspaces`. Open `ios-app/Feedback.xcodeproj` with `XcodeOpenWorkspace` only when absent, then list workspaces again if opening times out. Use the returned identifier in subsequent calls.
2. Select `Feedback Localhost` with `XcodeSwitchScheme`. Confirm the active destination with `XcodeListRunDestinations`; use `XcodeSwitchRunDestination` for a user-requested simulator.
3. For build-only work, use `BuildProject`. For a normal launch, use `RunProject`.
4. For interactive verification, start `DeviceInteractionStartWorkspaceSession`, build/install/launch with `DeviceInteractionInstallAndRun`, then inspect or interact with `DeviceInteractionSynthesize`. Base taps on the latest hierarchy, and close the interaction session with `DeviceInteractionEndSession` when done.
5. Use `GetBuildLog` and `GetConsoleOutput` for failures. Use `RunSomeTests` or `RunAllTests` for requested tests under the Localhost scheme; report missing test configuration rather than switching schemes silently.
6. When an authenticated app is required, use the sibling `letsgrow-ios-login/SKILL.md` workflow to provide per-launch login arguments.

Do not fall back to XcodeBuildMCP, Xcode CLI, simulator CLI, AppleScript, or another UI automation tool. Do not automate Xcode permission dialogs. If native Xcode MCP is blocked, report the blocking operation.

Report the scheme, simulator, build/launch result, and what was verified. Distinguish launch success from successful login or UI verification.
