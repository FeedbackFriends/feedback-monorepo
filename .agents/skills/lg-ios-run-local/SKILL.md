---
name: lg-ios-run-local
description: Start the local LetsGrow backend and launch one logged-in employee simulator. Also handles existing test-account overrides and login-only requests; preserves data unless a database reset is explicitly requested.
---

# Run LetsGrow locally

Follow [iOS policy](../../../ios-app/AGENTS.md), [shared launch setup](../../../ios-app/AGENTS.md#shared-launch-setup), and [employee testing](../../../docs/ios/development.md#local-employee-testing). Use launch-only mode.

The default is one employee on one iPhone simulator using `Feedback Localhost`.
The scheme uses Supabase anonymous auth and preserves the employee identity and
team membership. A saved leader session is signed out locally. Leaders use web;
no manager fixture or second simulator is needed.

## Backend and launch

1. Unless `login-only` was requested, run `./scripts/ios/prepare-backend.sh localhost` from the monorepo root. Stop on failure. Preserve existing data; do not seed fixtures or remove Compose volumes.
2. Only if the user explicitly requested `reset-db`, run `API_BASE_URL=http://localhost:8080 E2E_ADMIN_RETRIES=1 ./scripts/shared/manage-test-data.sh reset`. Never retry a destructive operation automatically. `login-only` cannot be combined with a reset.
3. Select `Feedback Localhost` and the user's requested eligible iPhone simulator, or retain the active eligible simulator. Use one simulator. Do not create, erase, or delete devices. Follow shared launch setup and native Xcode MCP; do not substitute simulator CLIs.
4. Launch through one workspace-backed interaction session with `DeviceInteractionInstallAndRun`, setting `environmentVariables` to `{"LETSGROW_LOCAL_TEST_ACCOUNT":"anonymous"}`. This ensures scheme-equivalent employee startup. Do not also call `RunProject`.
5. Verify the employee app is signed in and shows its team or team-join state. An error alert is a failed/incomplete launch. Joining a team or submitting content requires the user's requested action. Close the interaction session, leaving the app and backend running.

`login-only` skips backend preparation and preserves all data. If the backend is
unavailable, report the blocker. The employee session uses managed nonproduction
Supabase; it does not require `/admin/login`.

## Explicit test-account override

Only when the user requests `account <account-id>`, use that existing account
instead of the default employee. Do not seed a missing account.

1. Run `python3 .agents/skills/lg-ios-run-local/scripts/login_token.py --account-id <account-id>`. The helper accepts only loopback HTTP backend origins. Check its exit status; never log or save the token.
2. Launch once through the same native session with `environmentVariables` set to `{"LETSGROW_LOCAL_TEST_ACCOUNT":""}` and four separate `commandLineArguments`: `-E2E_ENABLE_AUTO_LOGIN`, `1`, `-E2E_CUSTOM_TOKEN`, and the fresh token. The empty environment value disables the default scheme login so it cannot override the requested account.
3. Verify the requested account's UI, then close the session leaving the app running. This DEBUG-only override requires enabled local test-admin endpoints and working test-auth configuration.

Report backend health/API URL, whether data was preserved or explicitly reset,
scheme/simulator, build/launch result and visibly verified employee login.
Separate observed success from blocked or unverified steps.
