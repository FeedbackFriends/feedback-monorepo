---
name: letsgrow-ios-login
description: Start the LetsGrow iOS app already logged in as a local test user by passing fresh login arguments through native Xcode MCP under the Feedback Localhost scheme. Use when asked to log in on the simulator or test an authenticated iOS flow.
---

# Log In to LetsGrow iOS

Use `Feedback Localhost` and native `mcp__xcode` tools for all Xcode and simulator interaction. Follow `ios-app/AGENTS.md`. Obtain a fresh Firebase custom token from the local backend without editing a shared scheme or resetting data.

## Prepare

- Discover the repo from the current workspace. Use `ios-app/Feedback.xcodeproj`.
- Use the requested test account ID. Otherwise use the existing seeded owner `mock-manager-with-data`.
- Keep the existing fixture data. Login is `POST http://localhost:8080/admin/login` with JSON `{"id":"<account-id>"}`; the response's `token` is the Firebase custom token. The endpoint requires enabled test-admin endpoints and working local Firebase configuration.
- The bundled `scripts/login_token.py` issues this request. It defaults to that account and backend, accepts `--account-id` and `--api-base-url`, and only permits loopback HTTP backends. Do not read Firebase secrets or invent a token.
- If the account is missing or login fails, report the cause. Do not call reset or seed endpoints unless the user explicitly requested fixture creation/reset. Requested fixture creation can use the repo's `scripts/e2e-admin` commands, then continue with a fresh token.

## Launch Through Xcode MCP

1. Discover the live workspace identifier using `XcodeListWorkspaces`. If absent, open the project with `XcodeOpenWorkspace`; if opening times out, list workspaces again. Never reuse an identifier from a previous conversation.
2. Select `Feedback Localhost` using `XcodeSwitchScheme`. Use the active simulator unless the user chose another. Discover/select it with `XcodeListRunDestinations` and `XcodeSwitchRunDestination`.
3. Start `DeviceInteractionStartWorkspaceSession` for the project and simulator. Keep its `interactionSessionKey` private and follow the returned interaction guidance.
4. Capture `login_token.py` stdout inside the tool-orchestration runtime. Check its exit status and hold the trimmed token only in memory. Do not print the process result or token, send it in commentary, or write it to a file.
5. Call `DeviceInteractionInstallAndRun` using the workspace identifier and interaction session key, with four separate launch arguments:

   ```text
   -E2E_ENABLE_AUTO_LOGIN
   1
   -E2E_CUSTOM_TOKEN
   <fresh token held in memory>
   ```

   Set `commandLineArguments` to that array. Do not pass a single combined string. Do not use `RunProject` for this step because it does not accept per-launch arguments. App auto-login reads these keys from `UserDefaults.standard` via process arguments in `ios-app/App/DebugMenuView.swift` and is available only in DEBUG builds.
6. Sanitize any returned log messages before displaying them. Never echo launch arguments that contain the token. Do not persist the token in `.xcscheme`, `.env`, source, or skill files.
7. Use `DeviceInteractionSynthesize` to inspect the current UI hierarchy. Verify authenticated owner UI such as Overblik/Aktiviteter for a manager, or the expected participant/profile state for another account. If an error alert appears, report that error; launch success alone does not establish login success.
8. Use `GetConsoleOutput` only with narrowly filtered, non-credential log messages when diagnosis is needed. Close the interaction session with `DeviceInteractionEndSession` after verification. Leave the app logged in for the user's testing.

## Tool Orchestration

When using `functions.exec`, keep credential capture and the install/run call in the same execution cell. Use `tools.exec_command` to execute the helper, assign the returned stdout to a local variable, and pass it directly to `tools.mcp__xcode__DeviceInteractionInstallAndRun`. Do not call `text()` on the token, shell result, launch arguments, or unredacted build/launch logs. Shell access here is solely a backend HTTP request, not Xcode interaction.

Do not use XcodeBuildMCP, `xcodebuild`, `xcrun simctl`, AppleScript, computer use, or Maestro to perform this login. Do not automate permission dialogs. Report native Xcode MCP failures instead of switching tools.

Report the scheme, simulator, test account, and whether login was visibly verified. State a blocker explicitly if login could not be verified.
