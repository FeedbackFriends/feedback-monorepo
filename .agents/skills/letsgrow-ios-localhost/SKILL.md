---
name: letsgrow-ios-localhost
description: Start the local LetsGrow backend and launch iOS for manual testing, optionally as a manager, an anonymous user, or both on separate simulators. Supports explicit fixture preparation and optional database reset.
---

# Build and run LetsGrow locally

Run from the monorepo root. Follow [iOS policy](../../../ios-app/AGENTS.md), the [native simulator workflow](../../../ios-app/.agents/skills/letsgrow-ios-run-simulator/SKILL.md), and the [manual testing guide](../../../ios-app/Docs/local-testing.md). Use launch-only mode; this command does not require running the test suites or screenshot catalog.

## Invocation

Interpret the words following `$letsgrow-ios-localhost` as the requested mode and options; these are agent instructions, not shell arguments.

| Mode | App launch |
| --- | --- |
| No mode | `Feedback Localhost`, keeping the simulator's saved login |
| `manager` | `Feedback Localhost Manager`, using `mock-manager-with-data` |
| `anonymous` | `Feedback Localhost Anonymous`, using Firebase anonymous auth |
| `both` | Manager and anonymous on two distinct iPhone simulators |

Natural-language requests for these modes are equivalent. Honor simulator names supplied by the user.

Data options:

- Default: preserve the database and existing fixture data. Login does not authorize seeding.
- `seed-manager`: prepare/reset only the sample manager fixture, including its associated sample data. This is useful on first use; it is not a whole-database reset.
- `reset-db`: explicitly delete all local database data. If launching `manager` or `both`, recreate the sample manager afterward. This option is authorization for that local reset in this invocation; do not ask for the same approval again. Merely discussing a reset option is not authorization to perform it.

Examples:

```text
$letsgrow-ios-localhost both
$letsgrow-ios-localhost both seed-manager
$letsgrow-ios-localhost both reset-db
$letsgrow-ios-localhost manager
$letsgrow-ios-localhost anonymous
```

## Backend and data

1. Run `./scripts/ios-backend localhost`. It builds the API image, starts API/Postgres, and waits for health while preserving volumes. Stop on failure and report the failing stage. Do not use `scripts/run` or remove Compose volumes.
2. Only when `reset-db` was requested, run `API_BASE_URL=http://localhost:8080 E2E_ADMIN_RETRIES=1 ./scripts/e2e-admin reset`. Stop on failure; never retry a destructive operation automatically.
3. If `seed-manager` was requested, or after a successful requested database reset when mode is `manager` or `both`, run `API_BASE_URL=http://localhost:8080 E2E_ADMIN_RETRIES=1 ./scripts/e2e-admin seed-manager-with-data > /dev/null`. Stop on failure. Discard token output and never log credentials. Do not seed twice when both options are present.

The fixed loopback origin prevents a caller's `API_BASE_URL` environment override from redirecting fixture operations elsewhere. Missing fixtures or disabled admin endpoints are actionable failures; do not silently seed/reset without the corresponding option. Explain that `seed-manager` replaces the fixture's sample data when describing a first-time invocation.

## Simulator launch

1. Discover/open this checkout's `ios-app/Feedback.xcodeproj` using native Xcode MCP. If opening times out, list workspaces again. If still unavailable, report the exact blocker and leave the healthy backend running; do not substitute CLI Xcode/simulator commands or computer use.
2. Select the scheme for the requested mode, then discover eligible run destinations. Keep the active eligible iPhone simulator for the first role unless the user chose another. For `both`, choose a second existing eligible iPhone simulator with a different device UUID; prefer an already running second simulator when native tool output identifies one. Report the selected role-to-device mapping. Do not create or erase simulators, or select physical/generic devices. If fewer than two are available, report the missing destination rather than claiming both launched.
3. For each role, select its scheme and discovered run destination. Start a separate `DeviceInteractionStartWorkspaceSession` on the intended simulator and confirm `deviceIsSimulator` and distinct `deviceUUID` values. Keep session keys private. Launch directly with `DeviceInteractionInstallAndRun`, setting `environmentVariables` to `{"LETSGROW_LOCAL_TEST_ACCOUNT":"manager"}` or `{"LETSGROW_LOCAL_TEST_ACCOUNT":"anonymous"}` respectively. Do not also call `RunProject` or supply legacy custom-token launch arguments. The DEBUG startup helper fetches the manager token internally before RootFeature observes auth; anonymous mode preserves a current anonymous identity or creates a new one after signing out a manager. No tokens belong in shared schemes.
4. Inspect the UI with `DeviceInteractionSynthesize`. Verify manager access to owner features and anonymous access to the PIN feedback flow without manager access. For `both`, keep both interaction sessions until the second launch is complete, then inspect both again to establish that both apps are running in the expected state. A startup error, lost first app, or wrong role is a failed/incomplete launch, not success. Do not run a session/feedback mutation just to prove login unless requested.
5. Close every interaction session in cleanup, including on failure. Do not call `StopProject`, terminate either app, or stop the backend after a successful setup. Leave both apps available for the user's manual testing.

For the no-mode run, use the ordinary `Feedback Localhost` launch route in the shared simulator workflow. For a requested custom manager account ID, use `Feedback Localhost` and the [existing local login workflow](../../../ios-app/.agents/skills/letsgrow-ios-login/SKILL.md), whose helper accepts that ID; the Manager scheme always selects the fixed sample manager.

Report backend health/API URL, whether data was preserved, fixture-prepared, or fully reset, and each role's scheme, simulator, build/launch, and visibly verified login. Separate observed success from blocked or unverified steps. This skill configures Localhost testing, not TestFlight or production.
