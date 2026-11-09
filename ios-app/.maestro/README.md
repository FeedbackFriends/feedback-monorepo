# Maestro E2E (iOS)

Localhost Maestro setup for seeded iOS simulator E2E.

Deferred journey-coverage work is listed in the root [todos](../../todos.md); grill its current scope before implementation.

Notification localization and tap checks have a separate [notification guide](notifications/README.md).
Run `python3 scripts/ios/test-notifications.py` for notification injection and
UI assertions against the real local backend. It uses the data-preserving
`prepare-backend.sh localhost` startup and existing manager login. Add `--seed-manager`
only to replace the standard sample fixture; no whole-database reset is used.

## Prerequisites

- Docker
- Maestro CLI (`maestro`)
- Xcode + iOS simulator runtime
- `rg`, `curl`, and `python3`

## Run

From repo root:

```bash
./scripts/ios/run-e2e-tests.sh
```

The default flow is `manager-create-activity-event`.

Run a specific flow or scenario:

```bash
./scripts/ios/run-e2e-tests.sh manager-create-activity-event
./scripts/ios/run-e2e-tests.sh debug-auth-seed-manager
./scripts/ios/run-e2e-tests.sh ios-app/.maestro/flows/manager-create-activity-event.yaml
./scripts/ios/run-e2e-tests.sh all
```

What it does:

1. Starts local stack via `./scripts/shared/reset-and-start-local-stack.sh -d`
2. Waits for API health on `http://localhost:8090/actuator/health`
3. Builds and installs iOS app with `Feedback Localhost` scheme
4. Resets backend state before each flow
5. Seeds deterministic backend state for flows that need it
6. Runs the requested Maestro flow
7. Writes Maestro debug and test artifacts under `ios-app/.build/maestro/`

Set `E2E_SKIP_BACKEND_START=1` if you already have the local backend stack running and only want the runner to wait for health, reset, seed, and execute the flow.

## Runtime Auth

Most flows use script-based backend seeding plus E2E launch arguments. The app does not call admin seed endpoints; the runner seeds through `./scripts/shared/manage-test-data.sh`, captures the custom token, and passes it to Maestro without printing it.

`manager-create-activity-event` uses auto-login via `E2E_ENABLE_AUTO_LOGIN=1`.

`debug-auth-seed-manager` is the explicit smoke test for the debug authentication sheet. It opens the sheet from the sign-up logo and taps `Login with injected E2E token`.

## Admin Helper

The runner uses `./scripts/shared/manage-test-data.sh` for local backend reset and seed commands:

```bash
./scripts/shared/manage-test-data.sh reset
./scripts/shared/manage-test-data.sh seed-manager-empty
```

Seed commands print only the custom token to stdout.

## Notes

- Default simulator name is `iPhone 16`.
- Override simulator by setting `SIMULATOR_NAME`:

```bash
SIMULATOR_NAME="iPhone 16 Pro" ./scripts/ios/run-e2e-tests.sh
```
