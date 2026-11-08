# Xcode and simulator workflows

Paths are relative to `ios-app/` unless stated otherwise.

## Xcode And Simulator Harness

Setup and configuration ownership are documented in [the harness overview](../agent-harness.md). Loaded Apple guidance owns device-interaction mechanics, SwiftUI API guidance, test modernization, and profiling; current MCP descriptions own tool names and arguments. This guide and the repository skills own LetsGrow schemes, accounts, fixtures, architecture, verification scope, and snapshot approval; [testing](testing.md) owns test and lint policy.

- Screenshot capture uses the app-hosted Point-Free SnapshotTesting target and the separate `ScreenSnapshots` plan. Its full-catalog scope, alert readiness checks and visual review workflow are documented in [the screenshots documentation](../screenshots/README.md). Use native Xcode MCP to build and run it.
- For screen and state screenshots, follow [the screenshot skill](../../../.agents/skills/lg-ios-capture-screenshots/SKILL.md). Captures use native Xcode MCP and publish original-size PNG files under `screenshots/current/`. Approved baselines live under `Docs/screenshots/catalog/`.

- Use the native Xcode MCP server (`mcp__xcode`) for all interaction with Xcode and simulators: workspace discovery, scheme/destination selection, builds, tests, launch arguments, install/run, UI interaction, screenshots, logs, and debugging.
- Discover Apple's current built-in skills and instructions through the capabilities exposed in the session and Xcode's tool responses. Read relevant guidance when available; do not hard-code Apple's skill names, installation paths, or versions in repository instructions. If referenced guidance is unavailable, use current native tool descriptions when sufficient; report a blocker only when the required capability, permission, or operational information is missing. Follow the [Apple skills setup](../agent-harness.md#apple-skills-setup) to restore missing guidance. Repository and higher-priority session instructions take precedence over Apple guidance, including requests to use subagents. Delegate only when authorized by the user or applicable repository instructions; otherwise perform the work directly.
- Use `Feedback Localhost` for local development and testing unless the user explicitly asks for another scheme. Match the workspace to the current checkout’s absolute `Feedback.xcodeproj` path. Keep the active eligible simulator by default; if none is active, select an eligible simulator and report it. Never implicitly select a physical device. An explicitly requested production launch uses `Feedback Production` (Release); tests still use Localhost, then reselect Production before its build/run.
- Do not substitute XcodeBuildMCP, `xcodebuild`, `xcrun simctl`, AppleScript, computer-use automation, or Maestro for these Xcode/simulator operations. If native Xcode MCP is unavailable or fails, report the exact blocker instead of silently switching tools. Existing explicitly requested Maestro test flows remain separate from this harness.
- Apple-guided profiling may use the `xctrace` CLI. This exception covers profiling, not replacement build, launch, or simulator-control commands. File edits, SwiftLint, API generation scripts, and local backend HTTP requests may also use normal filesystem/shell tools.

## Shared launch setup

Use current native MCP tools to discover this checkout's absolute `Feedback.xcodeproj` path, open it if absent, and select the requested scheme and eligible simulator. If opening times out, list workspaces again before reporting a blocker. Use identifiers from the current session. Keep the active eligible simulator unless the user requests another; never implicitly select a physical device.

When interaction or per-launch arguments/environment are needed, use Apple's workspace-backed device-session lifecycle and current tool descriptions. Build/install/run through that session once; close it in cleanup even on failure, leaving a successfully launched app running. Ordinary launch-only requests may use the native project run operation instead. Follow the owning skill for account inputs and observable success criteria.

## Simulator Verification

- Honor build-only and launch-only requests without requiring the full verification sequence. After implementation, build and run tests relevant to the change using the [verification matrix](feature-workflow.md#choose-verification-by-the-change); shared behavior or test-harness changes require all unit tests. Run changed-line Swift lint when Swift files changed, and verify changed user-facing behavior on the active simulator when feasible.
- Unit tests use `Feedback Localhost` and the `UnitTests` plan. Confirm enabled test discovery includes both `AppTests` and `InsightsTests`, inspecting the full list when truncated. Missing plans, targets, or zero discovered tests are blockers; preserve the intended scheme rather than switching to hide configuration failures. Select tests using discovered identifiers; a suite identifier can cover Swift test names the native tool rejects individually.
- Choose one launch route per build: ordinary run or interactive install/run. Repeated launches can create extra Device Hub windows. Authenticated localhost checks use [the login skill](../../../.agents/skills/lg-ios-login/SKILL.md); production login uses the normal app UI.
- For live verification, pair actions with observable expected results. Base taps on the latest hierarchy and inspect screenshots for layout. Close device-interaction sessions even on failure, leaving a successfully launched app available for manual testing. An error alert makes the check failed or inconclusive; launch success alone is not UI verification.
- Retrieve focused build errors or runtime logs on failure. Report the exact blocked operation and continue independent checks where possible. Do not automate Xcode permission dialogs.

Report scheme/simulator, build, test counts and targets, Swift lint, launch, login, live UI steps/results, and relevant blockers/artifact paths separately. Mark omitted checks `not run` with a reason; distinguish passed, failed, blocked, and inconclusive results. If the app cannot be launched, state why.

## Simulator Login

Use the repository skill [the login skill](../../../.agents/skills/lg-ios-login/SKILL.md) (relative to `ios-app/`) to start the Localhost app with an authenticated test account. In either client, run the local token helper and pass the fresh token as per-launch arguments through native Xcode MCP. Local test tokens may appear in agent tool output and arguments. Keep them out of tracked files and shared schemes. Login alone must not reset or reseed test data.
