# Maestro E2E (iOS)

Initial Maestro setup for iOS simulator smoke testing.

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
4. Runs `smoke-launch.yaml`
5. Stops stack with `docker compose down`

## Notes

- Default simulator name is `iPhone 16`.
- Override simulator by setting `SIMULATOR_NAME`:

```bash
SIMULATOR_NAME="iPhone 16 Pro" ./scripts/e2e
```
