# Manual testing with two simulators

Use the shared **Feedback Localhost Manager** and **Feedback Localhost Anonymous**
schemes to test against the same local backend without manual signup or copying
login tokens. Both schemes run the real app with `DebugLocalhost`.

## Agent command

From an agent session in this repository, invoke:

```text
$letsgrow-ios-localhost both
```

This starts the backend and launches the manager and anonymous apps on two
different simulators, preserving existing data. To prepare the sample manager on
first use, run `$letsgrow-ios-localhost both seed-manager`; this replaces the
sample manager fixture and its data. To deliberately clear the entire local
database and recreate the manager fixture, run
`$letsgrow-ios-localhost both reset-db`.

Use `manager` or `anonymous` instead of `both` for one simulator. You can specify
the simulator names in the same request. These commands are instructions for the
agent, not terminal commands. The agent needs a working native Xcode MCP
connection, Docker, and the existing local Firebase configuration.

## First-time setup

From the monorepo root, with Docker running:

```sh
./scripts/ios-backend localhost
./scripts/e2e-admin seed-manager-with-data > /dev/null
```

The first command builds and starts the local API and Postgres while preserving
existing database volumes. Existing local Firebase configuration must be present
in `ios-app/App/Config/secrets.xcconfig` and the backend environment.

The second command prepares `mock-manager-with-data` with sample activities and
feedback. **It resets that fixture account and its sample data**, so run it only
for initial preparation or when you deliberately want to reset the fixture. The
token it returns is discarded. Other launches do not seed or reset data.

## Run from Xcode

1. Open `ios-app/Feedback.xcodeproj`.
2. Choose **Feedback Localhost Manager**, select your first iPhone simulator,
   and press Run. The app fetches a fresh test token from the local backend and
   signs in as `mock-manager-with-data` before loading the app's account state.
3. Detach Xcode's debugger from the first run to leave that app running.
4. Choose **Feedback Localhost Anonymous**, select a different iPhone simulator,
   and press Run. No manual account creation is needed.
5. Create a session on the manager simulator. Enter its PIN on the anonymous
   simulator and submit feedback, then inspect the results as the manager.

Each simulator keeps its own login. Keep using the same two simulators to retain
the manager's changes and the anonymous user's participation history. The
anonymous scheme preserves an existing anonymous identity; if you use it on a
simulator currently signed in as a manager, it signs out and creates a new
anonymous identity. Switching back to Manager restores the seeded manager.

The ordinary **Feedback Localhost** scheme keeps the normal startup behavior and
the simulator's saved login.

## Troubleshooting

- Connection error: start the local backend and check `http://localhost:8080`.
- Test-login endpoint unavailable: local Compose must enable
  `FEEDBACK_ENABLE_TEST_ADMIN_ENDPOINTS` (the local override already does).
- Missing manager access: prepare the fixture with the seed command above and
  rerun. Seeding deliberately replaces the fixture's data.
- Missing schemes: reopen the project and check Xcode's scheme menu.

The schemes contain only the non-secret `LETSGROW_LOCAL_TEST_ACCOUNT` selection
(`manager` or `anonymous`). Tokens are fetched at launch and held in memory.
The launch code exists only in DEBUG builds and rejects any API URL other than
`http://localhost:8080`; TestFlight and production Release behavior is unchanged.
Tests do not inherit the account selection.
