---
name: lg-ios-run-local
description: Start the local LetsGrow backend and launch iOS for manual testing, optionally as a manager, an anonymous user, or both on separate simulators. Also handles custom test-account login and login-only requests; preserves data unless fixture preparation or database reset is explicitly requested.
---

# Build and run LetsGrow locally

Run from the monorepo root. Follow [iOS policy](../../../ios-app/AGENTS.md), the [simulator guide](../../../ios-app/AGENTS.md#xcode-and-simulator-workflows), and the [manual testing guide](../../../docs/ios/development.md#manual-testing-with-two-simulators). Use launch-only mode; this command does not require running the test suites or screenshot catalog.

## Invocation

Interpret the words following `$lg-ios-run-local` as the requested mode and options; these are agent instructions, not shell arguments.

| Mode | App launch |
| --- | --- |
| No mode | `Feedback Localhost`, keeping the simulator's saved login |
| `manager` | `Feedback Localhost Manager`, using `mock-manager-with-data` |
| `anonymous` | `Feedback Localhost Anonymous`, using Supabase anonymous auth |
| `both` | Manager and anonymous on two distinct iPhone simulators |
| `account <account-id>` | `Feedback Localhost`, logging in as the specified existing test account |

Natural-language requests for these modes are equivalent. Honor simulator names supplied by the user.

Use `login-only` with `manager` or `account <account-id>` when the user only wants to sign in against an already running backend. Skip backend preparation and preserve all data; report an unavailable backend/account instead of starting services or seeding. A request only to log in selects `manager login-only` unless another account is specified.

Data options:

A natural-language request for seeded/sample manager data selects `seed-manager`; a request for a fresh fixture does not imply `reset-db`. Select `reset-db` only when the user requests clearing the entire local database.

- `login-only` cannot be combined with `seed-manager` or `reset-db`; resolve conflicting intent before executing anything.
- Default: preserve the database and existing fixture data. Login does not authorize seeding.
- `seed-manager`: prepare/reset only the sample manager fixture, including its associated sample data. This is useful on first use; it is not a whole-database reset.
- `reset-db`: explicitly delete all local database data. If launching `manager` or `both`, recreate the sample manager afterward. This option is authorization for that local reset in this invocation; do not ask for the same approval again. Merely discussing a reset option is not authorization to perform it.

Examples:

```text
$lg-ios-run-local both
$lg-ios-run-local both seed-manager
$lg-ios-run-local both reset-db
$lg-ios-run-local manager
$lg-ios-run-local anonymous
$lg-ios-run-local manager login-only
$lg-ios-run-local account <account-id> login-only
```

## Backend and data

1. Unless `login-only` was requested, run `./scripts/ios/prepare-backend.sh localhost`. It builds the API image, starts API/Postgres, and waits for health while preserving volumes. Stop on failure and report the failing stage. Do not use `scripts/shared/reset-and-start-local-stack.sh` or remove Compose volumes.
2. Only when `reset-db` was requested, run `API_BASE_URL=http://localhost:8080 E2E_ADMIN_RETRIES=1 ./scripts/shared/manage-test-data.sh reset`. Stop on failure; never retry a destructive operation automatically.
3. If `seed-manager` was requested, or after a successful requested database reset when mode is `manager` or `both`, run `API_BASE_URL=http://localhost:8080 E2E_ADMIN_RETRIES=1 ./scripts/shared/manage-test-data.sh seed-manager-with-data > /dev/null`. Stop on failure. Discard token output and never log credentials. Do not seed twice when both options are present.

The fixed loopback origin prevents a caller's `API_BASE_URL` environment override from redirecting fixture operations elsewhere. Missing fixtures or disabled admin endpoints are actionable failures; do not silently seed/reset without the corresponding option. Explain that `seed-manager` replaces the fixture's sample data when describing a first-time invocation.

## Simulator launch

1. Follow [shared launch setup](../../../ios-app/AGENTS.md#shared-launch-setup) in launch-only mode. If the workspace remains unavailable, report the blocker and leave the healthy backend running.
2. Select the scheme for the requested mode, then discover eligible run destinations. Keep the active eligible iPhone simulator for the first role unless the user chose another. For `both`, choose a second existing eligible iPhone simulator with a different device UUID; prefer an already running second simulator when native tool output identifies one. Report the selected role-to-device mapping. Do not create or erase simulators, or select physical/generic devices. If fewer than two are available, report the missing destination rather than claiming both launched.
3. For `manager`, `anonymous`, or `both`, select each role’s scheme and run destination, using a separate workspace-backed interaction session for each role. Confirm `deviceIsSimulator` and distinct `deviceUUID` values. Launch directly with `DeviceInteractionInstallAndRun`, setting `environmentVariables` to `{"LETSGROW_LOCAL_TEST_ACCOUNT":"manager"}` or `{"LETSGROW_LOCAL_TEST_ACCOUNT":"anonymous"}` respectively. Do not also call `RunProject` or supply legacy custom-token launch arguments. The DEBUG startup helper fetches the manager token internally before RootFeature observes auth; anonymous mode preserves a current anonymous identity or creates a new one after signing out a manager. No tokens belong in shared schemes.
4. Inspect the UI using Apple device-interaction guidance and current native tools. For standard roles, verify manager access to owner features and anonymous access to the PIN feedback flow without manager access. For a custom account, verify its expected participant/profile or manager state. For `both`, keep both interaction sessions until the second launch is complete, then inspect both again to establish that both apps are running in the expected state. A startup error, lost first app, or wrong role is a failed/incomplete launch, not success. Do not run a session/feedback mutation just to prove login unless requested.
5. Follow shared session cleanup. Keep both apps and the backend running after successful setup. Leave both apps available for the user's manual testing.

For the no-mode run, use the ordinary `Feedback Localhost` launch route in the shared simulator workflow. For `account <account-id>`, use the custom-account route below instead of the role-based launch in step 3; apply the same simulator selection, UI verification, and cleanup. The Manager scheme always selects the fixed sample manager.

## Custom test-account login

The local backend must expose `POST /admin/login` with test-admin endpoints enabled and working test-auth configuration. The account must already exist. Preserve fixtures; report missing accounts or unavailable authentication rather than inventing tokens or seeding.

1. From the monorepo root, run:

   ```sh
   python3 .agents/skills/lg-ios-run-local/scripts/login_token.py --account-id <account-id>
   ```

   Check the exit status and use the fresh token printed to stdout. The helper accepts `--api-base-url` only for loopback HTTP origins.
2. Select `Feedback Localhost` and launch once through the workspace-backed `DeviceInteractionInstallAndRun` session with four separate `commandLineArguments`: `-E2E_ENABLE_AUTO_LOGIN`, `1`, `-E2E_CUSTOM_TOKEN`, and the fresh token. Use an array, not a combined string. Do not call `RunProject` first. Ensure `LETSGROW_LOCAL_TEST_ACCOUNT` is unset so role-based startup cannot conflict with the requested account.
3. Verify the expected authenticated UI for the requested account. If authentication is pending, inspect again without reinstalling; report any error alert. Finish shared session cleanup, leaving the app logged in.

This launch-argument route is DEBUG-only. Keep tokens out of tracked files and shared schemes; they may appear in helper output and MCP arguments.

Report backend health/API URL, whether data was preserved, fixture-prepared, or fully reset, and each role's scheme, simulator, build/launch, and visibly verified login. Separate observed success from blocked or unverified steps. This skill configures Localhost testing, not TestFlight or production.
