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
4. Calls `/admin/seed-manager-with-data` and runs `seeded-manager-flow.yaml`
5. Calls `/admin/reset-database`
6. Calls `/admin/seed-participant-with-data` and runs `seeded-participant-flow.yaml`
7. Stops stack with `docker compose down`

## Runtime Auth Injection

The two seeded flows pass launch arguments into the iOS app:

- `E2E_ENABLE_AUTO_LOGIN=1`
- `E2E_CUSTOM_TOKEN=<custom token from seed endpoint>`

The app reads these arguments in debug builds and performs Firebase custom-token sign-in automatically.

## Notes

- Default simulator name is `iPhone 16`.
- Override simulator by setting `SIMULATOR_NAME`:

```bash
SIMULATOR_NAME="iPhone 16 Pro" ./scripts/e2e
```
