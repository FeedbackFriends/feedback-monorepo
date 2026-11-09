# iOS development

Setup, configuration, manual testing, and notifications. Agent constraints live in [iOS policy](../../ios-app/AGENTS.md); reusable launch and capture procedures live in [skills](../shared/skills.md).

## Setup and tooling

Start at the monorepo root. [Repository harness architecture](../../HARNESS.md) owns shared instructions, skill provenance, and hooks. [iOS policy](../../ios-app/AGENTS.md) routes platform work.

### Prerequisites and manual development

Open `ios-app/Feedback.xcodeproj` from the monorepo root. `ios-app/Modules/Package.swift` owns module dependencies. Use Xcode 27 with Swift 6.2 or newer and an installed iOS 27 simulator runtime. Install SwiftLint (`brew install swiftlint`) and Python 3.

For manual development, select the `Feedback Localhost` scheme and an iOS simulator in Xcode, then Build & Run. Run the shared `UnitTests` plan from the same scheme. Other schemes target different configurations; `Feedback Production` is the production scheme.

Live authentication requires managed Supabase and Google configuration in the app's Info.plist, populated through `App/Config/secrets.xcconfig`; see [Supabase setup](../shared/authentication.md#supabase-auth-setup-and-cutover). Firebase configuration is still used for push and crash reporting. Keep that file local and ignored by Git. See [configuration](development.md#configuration) and [local testing](development.md#local-employee-testing) for local backend addressing and test-account login.

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

## Local employee testing

Use one iPhone simulator with **Feedback Localhost**. The scheme signs in an
employee through Supabase anonymous auth, preserving that identity and its team
membership across launches. If the simulator still has a leader session, the
local launch signs it out and creates an employee session. Leaders use the web.

From an agent session, invoke `$lg-ios-run-local`. It starts the local backend
and launches the employee app on one simulator, preserving database contents.
Use `login-only` to skip backend startup when it is already running.

From Xcode:

1. Run `./scripts/ios/prepare-backend.sh localhost` from the monorepo root.
2. Open `ios-app/Feedback.xcodeproj`, select **Feedback Localhost** and one
   iPhone simulator, then press Run.
3. Join a team using its employee invitation code when needed. Membership is
   retained for the next launch; no sample manager fixture is required.

Configure nonproduction Supabase and Firebase in `App/Config/secrets.xcconfig`
and the backend environment; see [authentication setup](../shared/authentication.md).
If startup fails, check the local backend at `http://localhost:8080` and the
Supabase configuration. Employee authentication does not require test-admin login.
The scheme's account selection is DEBUG-only and is not inherited by tests.

## Notifications

The app uses Firebase Cloud Messaging. [AppDelegate](../../ios-app/App/AppDelegate.swift) handles registration/token callbacks; [entitlements](../../ios-app/App/Entitlements.entitlements) enable push. Firebase configuration comes from Info.plist and local `App/Config/secrets.xcconfig`; see [configuration](development.md#configuration).

The [localization guide](localization.md#notification-and-system-string-packaging) owns APNs keys, string arguments, and linked main-app resources. Preserve that contract when changing payloads.

Use [lg-ios-test-notifications](../../.agents/skills/lg-ios-test-notifications/SKILL.md) for notification verification. The [backend-dependent runner](../../ios-app/.maestro/notifications/README.md) documents setup, data cleanup, and delivery limits. Simulator injection verifies presentation/navigation, not production FCM/APNs transport or device provisioning. A [sample payload](push_notifications/new_feedback_received.apns) remains available for manual inspection; local agent simulator operations follow [native Xcode policy](../../ios-app/AGENTS.md#xcode-and-simulator-workflows).
