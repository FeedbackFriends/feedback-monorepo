---
name: lg-ios-login
description: Start the LetsGrow iOS app already logged in as a local test user by passing fresh login arguments through native Xcode MCP under the Feedback Localhost scheme. Use when asked to log in on the simulator or test an authenticated iOS flow.
---

# Log In to LetsGrow iOS

Follow [iOS policy](../../../ios-app/AGENTS.md) and the [shared launch setup](../../../docs/ios/agents/simulator.md#shared-launch-setup) in launch-only mode. Use loaded Apple guidance for device interaction. Keep local test tokens out of tracked files and shared schemes; they may appear in helper output and MCP arguments.

## Prepare

- Use this checkout's `ios-app/Feedback.xcodeproj` and the requested existing test account. Default to `mock-manager-with-data`.
- Preserve existing fixture data. Do not reset or seed unless the user explicitly requests it.
- The local backend must support `POST /admin/login` with enabled test-admin endpoints and working Firebase configuration. The bundled `scripts/login_token.py` obtains a fresh custom token and only accepts loopback HTTP backends. If the backend or account is unavailable, report the cause instead of inventing a token or resetting data.

## Launch through native Xcode MCP

1. Use shared launch setup with `Feedback Localhost` and a workspace-backed interaction session on the requested eligible simulator.
2. From the monorepo root, obtain a fresh token:

   ```sh
   python3 .agents/skills/lg-ios-login/scripts/login_token.py
   # For another existing account, add --account-id <account-id>.
   ```

   Check the exit status and use the token printed to stdout. The helper also accepts `--api-base-url` for another loopback HTTP backend.
3. Call `DeviceInteractionInstallAndRun` with the current workspace identifier, interaction session key, and four separate `commandLineArguments`:

   ```text
   -E2E_ENABLE_AUTO_LOGIN
   1
   -E2E_CUSTOM_TOKEN
   <fresh token from helper stdout>
   ```

   Use an array, not a combined string. Do not call `RunProject` first or use it for this step: it does not accept per-launch arguments. Auto-login is DEBUG-only and reads process arguments in `ios-app/App/DebugMenuView.swift`.
4. Inspect the current UI using the native interaction tool. Verify authenticated manager UI such as Overblik/Aktiviteter, or the expected participant/profile state for another account. If authentication is still pending, inspect again without reinstalling. Report any error alert; launch success alone does not prove login success.
5. Finish session cleanup through the shared workflow, leaving the app logged in for manual testing. Use focused runtime logs if diagnosis is needed.

Report the scheme, simulator, test account, and whether login was visibly verified. State any blocker explicitly.
