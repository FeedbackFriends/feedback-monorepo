# Maestro E2E (iOS)

Localhost Maestro setup for seeded iOS simulator E2E.

## Prerequisites

- Docker
- Maestro CLI (`maestro`)
- Xcode + iOS simulator runtime
- `rg` and `curl`

## Run

From repo root:

```bash
./scripts/e2e
```

What it does:

1. Starts local stack via `./scripts/run -d`
2. Waits for API health on `http://localhost:8090/actuator/health`
3. Builds and installs iOS app with `Feedback Localhost` scheme
4. Runs `manager-create-event-flow.yaml`
5. The flow opens the E2E authentication sheet from sign-up and taps `Seed manager empty`

## Runtime Auth

The manager flow performs auth through the debug E2E sheet in the sign-up UI, not launch arguments.

## Notes

- Default simulator name is `iPhone 16`.
- Override simulator by setting `SIMULATOR_NAME`:

```bash
SIMULATOR_NAME="iPhone 16 Pro" ./scripts/e2e
```
