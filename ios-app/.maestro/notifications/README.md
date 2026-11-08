# Notification E2E tests

The notification runner uses the real local backend, Firebase authentication and
normal app startup. Simulator push injection supplies the APNs alert; tapping it
must fetch and open the matching backend session through the production reducers.
There are no in-app notification fixtures or substituted dependency clients.

From the repository root:

```bash
python3 scripts/ios/test-notifications.py --counts 0 1 2 99
```

The runner starts the backend through `scripts/ios/ios-backend localhost`, preserving
Compose volumes. It requires the existing `mock-manager-with-data` account. On
first use, explicitly prepare that standard sample fixture:

```bash
python3 scripts/ios/test-notifications.py --seed-manager --counts 0 1 2 99
```

`--seed-manager` replaces only the standard sample manager and its sample data.
It never calls `/admin/reset`. Without this option, existing sample data is
preserved. Test-admin endpoints and the normal local Firebase configuration must
be enabled; missing/invalid login is a setup failure, not a fallback to fixtures.

To reuse a running backend and an app already built through native Xcode:

```bash
python3 scripts/ios/test-notifications.py \
  --skip-backend-start --app '/absolute/path/to/App.app' --counts 99
```

By default, the command builds Feedback Localhost and creates an isolated iOS
simulator, deleting only that simulator afterward. Local agent Xcode builds use
native Xcode MCP; use `--app` to supply that build. `--device <uuid>` reuses an
existing simulator without erasing its app data or Keychain. Previously denied
notification permission causes delivery assertions to fail; use a fresh simulator.
The runner retries only the simulator's specific installation-promise startup error.

For each foreground/background/terminated case, the runner:

1. Creates a unique activity and session through authenticated local API requests.
2. Confirms that session exists in the real manager bootstrap.
3. Launches with the existing `LETSGROW_LOCAL_TEST_ACCOUNT=manager` mechanism,
   which obtains Firebase credentials from the local backend inside the app.
4. Handles the normal system notification prompt and requires authenticated owner UI.
5. Injects the localized APNs payload containing the real session ID and unique title.
6. Asserts the complete English notification text, rejects raw keys, taps the
   notification, and requires the matching session detail screen.
7. Deletes only the activity created for that case, including after a failure.

Counts 0/1/2/99 exercise payload rendering; they do not submit that many feedback
responses. Foreground cases inject while the app is visible, then return to the Home screen and inspect the
persistent notification in Notification Center using the system hierarchy. This does not measure transient
banner timing. Background/terminated navigation is never replaced by direct app
or deep-link launches. The system Open action handles selected notification stacks.

Results, screenshots and Maestro logs are written to
`ios-app/.build/notification-tests/` (override with `--output`). Credentials are
kept in memory; they are not launch arguments or artifact contents. Each payload
records the real session ID. Setup, authorization, delivery, navigation and cleanup
failures return nonzero exit status.

GitHub-hosted iOS CI runs unit/reducer tests and source/compiled-resource
validation. This backend-dependent suite runs explicitly in the configured local
E2E environment; hosted CI has no local API or Firebase test configuration.
The earlier offline-fixture runs in localization history are superseded and do
not establish that this backend-dependent flow passes.

Simulator injection does not verify FCM/APNs network transport or physical-device
provisioning. Reducer payload/navigation cases remain in `NotificationTests` under
the UnitTests plan. Tooling checks:

```bash
python3 scripts/ios/validate-localization.py
python3 -m unittest discover -s scripts/ios/tests -p test_notification_runner.py
```

## Backend-dependent verification

Count 99 passed in foreground, background and terminated states on isolated iOS
26.5 simulators using the existing local manager fixture, real API sessions and
normal Firebase startup. No database reset or reseed was performed. Background
and terminated cases passed in `notification-tests-real-backend/`; the corrected
foreground case passed in `notification-tests-real-backend-foreground-final/`.
The combined summary is `ios-app/.build/notification-tests-real-backend-summary.json`.
All tested sessions were confirmed removed from the backend after cleanup.
The foreground flow returns to Home after injection before inspecting the system
hierarchy; screenshots had shown the correct notification while Maestro was
incorrectly inspecting the underlying app. Exact notification text and matching
session navigation remain mandatory. Counts 0/1/2 were not rerun in this follow-up.
