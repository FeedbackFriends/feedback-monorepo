---
name: lg-ios-login
description: Start the LetsGrow iOS app already logged in as a local test user by passing fresh login arguments through native Xcode MCP under the Feedback Localhost scheme. Use when asked to log in on the simulator or test an authenticated iOS flow.
---

# Log In to LetsGrow iOS

Follow `ios-app/AGENTS.md`. Use `Feedback Localhost` and native Xcode MCP for Xcode and simulator operations. Codex and Claude Code use the same workflow; local test tokens may appear in tool output and MCP arguments. No private orchestration runtime is required. Keep tokens out of tracked files and shared schemes.

## Prepare

- Use this checkout's `ios-app/Feedback.xcodeproj` and the requested existing test account. Default to `mock-manager-with-data`.
- Preserve existing fixture data. Do not reset or seed unless the user explicitly requests it.
- The local backend must support `POST /admin/login` with enabled test-admin endpoints and working Firebase configuration. The bundled `scripts/login_token.py` obtains a fresh custom token and only accepts loopback HTTP backends. If the backend or account is unavailable, report the cause instead of inventing a token or resetting data.

## Launch through native Xcode MCP

1. Discover the current workspace with `XcodeListWorkspaces`, matching this checkout's absolute project path. Open it with `XcodeOpenWorkspace` if absent; list again if opening times out. Never reuse an identifier from a previous conversation.
2. Select `Feedback Localhost` using `XcodeSwitchScheme`. Inspect `XcodeListRunDestinations` and keep the active eligible simulator unless the user chose another; select it with `XcodeSwitchRunDestination` when needed. Do not implicitly use a physical device.
3. Start `DeviceInteractionStartWorkspaceSession` and retain its `interactionSessionKey`. Follow the returned interaction guidance. Close the session with `DeviceInteractionEndSession` when finished, including on failure.
4. From the monorepo root, obtain the token through the client's ordinary shell tool:

   ```sh
   python3 .agents/skills/lg-ios-login/scripts/login_token.py
   # For another existing account, add --account-id <account-id>.
   ```

   Check the exit status and use the token printed to stdout. The helper also accepts `--api-base-url` for another loopback HTTP backend.
5. Call `DeviceInteractionInstallAndRun` with the current workspace identifier, interaction session key, and four separate `commandLineArguments`:

   ```text
   -E2E_ENABLE_AUTO_LOGIN
   1
   -E2E_CUSTOM_TOKEN
   <fresh token from helper stdout>
   ```

   Use an array, not a combined string. Do not call `RunProject` first or use it for this step: it does not accept per-launch arguments. Auto-login is DEBUG-only and reads process arguments in `ios-app/App/DebugMenuView.swift`.
6. Inspect the current UI with `DeviceInteractionSynthesize`. Verify authenticated manager UI such as Overblik/Aktiviteter, or the expected participant/profile state for another account. If authentication is still pending, inspect again without reinstalling. Report any error alert; launch success alone does not prove login success.
7. Use `GetConsoleOutput` when diagnosis requires it. End the interaction session and leave the app logged in for the user's testing.

Do not substitute XcodeBuildMCP, `xcodebuild`, `xcrun simctl`, AppleScript, computer use, or Maestro for native Xcode operations. Do not automate permission dialogs. Report a failed native operation instead of switching automation tools.

Report the scheme, simulator, test account, and whether login was visibly verified. State any blocker explicitly.
