# Xcode and simulator workflows

Paths are relative to `ios-app/` unless stated otherwise.

## Xcode And Simulator Harness

Setup and configuration ownership are documented in [the harness overview](../agent-harness.md). The build, test, launch, and verification procedure lives in [the simulator workflow skill](../../.agents/skills/letsgrow-ios-run-simulator/SKILL.md); read it for those tasks.

- For screen and state screenshots, follow [the screenshot skill](../../.agents/skills/letsgrow-ios-screenshots/SKILL.md). Captures use native Xcode MCP and publish original-size PNG files under `Docs/screenshots/catalog/`.

- Use the native Xcode MCP server (`mcp__xcode`) for all interaction with Xcode and simulators: workspace discovery, scheme/destination selection, builds, tests, launch arguments, install/run, UI interaction, screenshots, logs, and debugging.
- Use `Feedback Localhost` for local development and testing unless the user explicitly asks for another scheme. Resolve the current checkout's workspace and keep the active eligible simulator by default; never implicitly select a physical device.
- Do not substitute XcodeBuildMCP, `xcodebuild`, `xcrun simctl`, AppleScript, computer-use automation, or Maestro for these Xcode/simulator operations. If native Xcode MCP is unavailable or fails, report the exact blocker instead of silently switching tools. Existing explicitly requested Maestro test flows remain separate from this harness.
- File edits, SwiftLint, API generation scripts, and local backend HTTP requests may use normal filesystem/shell tools; they are not Xcode interaction.

## Simulator Verification

After implementing iOS app changes, run the app on the active simulator through Xcode MCP before finishing when feasible. Prefer the `Feedback Localhost` scheme. If the app cannot be launched, report the reason in the final response.

## Simulator Login

Use the repository skill [the login skill](../../.agents/skills/letsgrow-ios-login/SKILL.md) (relative to `ios-app/`) to start the Localhost app with an authenticated test account. Obtain a fresh custom token and pass it only as per-launch arguments through Xcode MCP. Never commit tokens to a shared scheme or log them. Login alone must not reset or reseed test data.
