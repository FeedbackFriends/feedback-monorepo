# iOS development

Setup, configuration, manual testing, and notifications. Agent constraints live in [iOS policy](../../ios-app/AGENTS.md); reusable launch and capture procedures live in [skills](../shared/skills.md).

## Setup and tooling

Start at the monorepo root. [Repository harness architecture](../../HARNESS.md) owns shared instructions, skill provenance, and hooks. [iOS policy](../../ios-app/AGENTS.md) routes platform work.

### Prerequisites and manual development

Open `ios-app/Feedback.xcodeproj` from the monorepo root. `ios-app/Modules/Package.swift` owns module dependencies. Use Xcode 27 with Swift 6.2 or newer and an installed iOS 27 simulator runtime. Install SwiftLint (`brew install swiftlint`) and Python 3.

For manual development, select the `Feedback Localhost` scheme and an iOS simulator in Xcode, then Build & Run. Run the shared `UnitTests` plan from the same scheme. Other schemes target different configurations; `Feedback Production` is the production scheme.

Live authentication requires managed Supabase and Google configuration in the app's Info.plist, populated through `App/Config/secrets.xcconfig`; see [Supabase setup](../shared/authentication.md#supabase-auth-setup-and-cutover). Firebase configuration is still used for push and crash reporting. Keep that file local and ignored by Git. See [configuration](development.md#configuration) and [local testing](development.md#manual-testing-with-two-simulators) for local backend addressing and test-account login.

Firebase Crashlytics is the iOS crash and nonfatal-error reporter; OSLog retains
local diagnostics. Firebase is configured before the logging clients start.
Xcode Cloud device builds upload dSYMs with the resolved Firebase SDK and the
existing `FIREBASE_GOOGLE_APP_ID`. Upload failures fail the build so missing
symbols are visible. Local and simulator builds skip uploads.

Sentry is no longer used, including its performance tracing. Remove the obsolete
`SENTRY_DSN_URL`, `SENTRY_DSN_SCHEME`, `SENTRY_AUTH_TOKEN`, `SENTRY_ORG` and
`SENTRY_PROJECT` values from Xcode Cloud and local configuration if present;
the app requires no replacement Sentry credentials.

The backend owns the API contract. Regenerate the committed contract and both clients from the monorepo root using `./scripts/shared/generate-api-artifacts.sh`; do not hand-edit generated Swift sources.

### Project configuration format

`Feedback.xcodeproj/project.xcproj` is Xcode's native JSON project configuration. Xcode 27 or later is required to open it; Xcode 27.2 performed the migration from `project.pbxproj`. The `.xcodeproj` bundle, shared schemes, test plans, and command entry points retain their existing paths. The format permits trailing commas; use Xcode or format-aware tools when editing it.

Apple documents the conversion and rollback in [Updating your Xcode project configuration file format](https://developer.apple.com/documentation/xcode/updating-your-xcode-project-configuration-file-format). Its [open source format library](https://github.com/apple/xcode-project-format) describes the schema.

### Xcode MCP setup

Complete Xcode's first-launch setup and select the intended Xcode installation in its command-line tools settings. Open this repository as a trusted project in Codex or Claude Code.

The checked-in project configurations, `.codex/config.toml` and root `.mcp.json`, start Apple's native server using `xcrun mcpbridge`. After configuration changes, restart the MCP client. In either client, `/mcp` shows connections; `codex mcp list` or `claude mcp list` shows configured servers. Claude project servers may await approval before connecting. See [shared client setup](../../HARNESS.md#claude-code-setup), [Codex MCP configuration](https://learn.chatgpt.com/docs/extend/mcp?surface=cli), and [Claude MCP configuration](https://code.claude.com/docs/en/mcp).

Verify the connection with `XcodeListWorkspaces`. Match this checkout's absolute `ios-app/Feedback.xcodeproj` path; use `XcodeOpenWorkspace` if absent. Follow Xcode's authorization prompts yourself if required. A missing connection or denied operation is a blocker to report, not a reason to switch local automation tools.

### Apple skills setup

Export guidance from the selected Xcode directly into the shared skills folder:

```sh
python3 scripts/shared/update-xcode-skills.py
```

Run this on a fresh checkout and after switching or upgrading Xcode. The helper uses `xcrun agent skills export --output-dir` to stage and validate guidance before updating Apple-owned folders directly in `.agents/skills/`. It creates Claude discovery symlinks under `.claude/skills/` and removes stale Apple skills and aliases. Generated `.gitignore` files keep Apple content and aliases local; `.agents/skills/.apple-skills.json` records export ownership and is also ignored. Custom and community skills remain tracked in the same shared folder; `skills-lock.json` owns community provenance.

The native export currently supplies 11 skills with Xcode 27.2. It does not include the plugin packages' translation and accessibility specialist skills. Export contents follow the selected Xcode. No plugin marketplace registration or client-specific package installation is needed. If migrating an existing installation, uninstall the old `xcode-integration@letsgrow-xcode` plugin in each client's plugin manager to prevent duplicate guidance; removing repository catalogs does not uninstall cached plugins.

Open a fresh session and confirm exported guidance appears in the skill catalog. Separately call `XcodeListWorkspaces` to verify the existing MCP connection. Export and symlink checks establish local installation, not session activation, a build, or device interaction.

Use loaded Apple guidance for native operations and the [simulator guide](../../ios-app/AGENTS.md#xcode-and-simulator-workflows) for LetsGrow schemes, tests, login, and verification. Repository and higher-priority client instructions retain precedence, including delegation authorization. Tool names and arguments come from current MCP descriptions. Optional missing guidance does not block operations whose tool descriptions are sufficient.

## Configuration

The app reads runtime configuration from `Info.plist` using `InfoPlistConfig` and `InfoPlistReader`.

### Keys

| Key | Example | Purpose |
| --- | --- | --- |
| `API_BASE_URL` | `api.myhost.com` | Backend host |
| `API_SCHEME` | `https` | Backend scheme |
| `WEB_BASE_URL` | `app.myhost.com` | Web deep link host |
| `WEB_SCHEME` | `https` | Web scheme |
| `SUPPORT_EMAIL` | `support@myhost.com` | Support link |
| `APPSTORE_ID` | `1234567890` | App Store links |

See `ios-app/App/InfoPlist/Info.plist` and scheme‑specific `.xcconfig` files under `ios-app/App/Config/`.

### Schemes

The default local scheme is `Feedback Localhost`; `Feedback Production` targets production. See [setup and workflows](development.md#setup-and-tooling) for running and testing.

Runtime accessors are implemented in [`InfoPlistConfig`](../../ios-app/Modules/Sources/InfoPlist/InfoPlistConfig.swift); inspect the source when adding configuration keys.

## Manual testing with two simulators

Use the shared **Feedback Localhost Manager** and **Feedback Localhost Anonymous**
schemes to test against the same local backend without manual signup or copying
login tokens. Both schemes run the real app with `DebugLocalhost`.

### Agent command

From an agent session in this repository, invoke:

```text
$lg-ios-run-local both
```

This starts the backend and launches the manager and anonymous apps on two
different simulators, preserving existing data. To prepare the sample manager on
first use, run `$lg-ios-run-local both seed-manager`; this replaces the
sample manager fixture and its data. To deliberately clear the entire local
database and recreate the manager fixture, run
`$lg-ios-run-local both reset-db`.

Use `manager` or `anonymous` instead of `both` for one simulator. You can specify
the simulator names in the same request. These commands are instructions for the
agent, not terminal commands. The agent needs a working native Xcode MCP
connection, Docker, and nonproduction Supabase configuration. Firebase remains required for push and crash reporting.

### First-time setup

From the monorepo root, with Docker running:

```sh
./scripts/ios/prepare-backend.sh localhost
./scripts/shared/manage-test-data.sh seed-manager-with-data > /dev/null
```

The first command builds and starts the local API and Postgres while preserving
existing database volumes. Configure the nonproduction Supabase project in
`ios-app/App/Config/secrets.xcconfig` and the backend environment; see
[authentication setup](../shared/authentication.md). Firebase remains used for push
and crash reporting.

The second command prepares `mock-manager-with-data` with sample activities and
feedback. **It resets that fixture account and its sample data**, so run it only
for initial preparation or when you deliberately want to reset the fixture. The
token it returns is discarded. Other launches do not seed or reset data.

### Run from Xcode

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

### Troubleshooting

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

## Notifications

The app uses Firebase Cloud Messaging. [AppDelegate](../../ios-app/App/AppDelegate.swift) handles registration/token callbacks; [entitlements](../../ios-app/App/Entitlements.entitlements) enable push. Firebase configuration comes from Info.plist and local `App/Config/secrets.xcconfig`; see [configuration](development.md#configuration).

The [localization guide](localization.md#notification-and-system-string-packaging) owns APNs keys, string arguments, and linked main-app resources. Preserve that contract when changing payloads.

Use [lg-ios-test-notifications](../../.agents/skills/lg-ios-test-notifications/SKILL.md) for notification verification. The [backend-dependent runner](../../ios-app/.maestro/notifications/README.md) documents setup, data cleanup, and delivery limits. Simulator injection verifies presentation/navigation, not production FCM/APNs transport or device provisioning. A [sample payload](push_notifications/new_feedback_received.apns) remains available for manual inspection; local agent simulator operations follow [native Xcode policy](../../ios-app/AGENTS.md#xcode-and-simulator-workflows).
