# iOS agent harness

Start agent sessions at the monorepo root. [Root guidance](../../AGENTS.md) routes iOS work to [iOS policy](../AGENTS.md) and the [simulator workflow](../.agents/skills/letsgrow-ios-run-simulator/SKILL.md), so an iOS task does not depend on nested skills appearing in the initial skill picker.

## Ownership

| Location | Owns |
| --- | --- |
| `ios-app/AGENTS.md` | iOS architecture, tool boundaries, and verification policy |
| `ios-app/.agents/skills/letsgrow-ios-run-simulator/SKILL.md` | Build, test, launch, and UI verification procedure and report |
| `ios-app/.agents/skills/letsgrow-ios-login/SKILL.md` | Local test-account login and credential handling |
| `.codex/config.toml` | Codex project MCP connections |
| `.agents/config.toml` | Compatibility MCP definitions for other harnesses |
| `ios-app/scripts/lint-swift-changes.py` | Non-mutating changed-line lint gate used locally and in CI |
| `.github/workflows/ios.yml` | iOS app build and unit tests on GitHub Actions |

Keep a rule or procedure in its owning file and link to it elsewhere. This page describes setup; it does not replace those instructions. No edit hook runs SwiftLint or changes Swift files. The old `swiftlint-fix-changed.sh` path remains a non-mutating compatibility entry point and requires the same `--base` argument as the lint script.

## Xcode MCP setup

Use Xcode 27 with the installed iOS 27 simulator runtime, complete Xcode's first-launch setup, and select the intended Xcode installation in its command-line tools settings. Install SwiftLint (`brew install swiftlint`) and Python 3. Open this repository as a trusted Codex project.

The checked-in project configuration starts Apple's native server using `xcrun mcpbridge`. After configuration changes, restart the MCP client. In Codex CLI, `/mcp` shows active connections and `codex mcp list` shows configured servers. See [official MCP configuration documentation](https://learn.chatgpt.com/docs/extend/mcp?surface=cli).

Verify the connection with `XcodeListWorkspaces`. Match this checkout's absolute `ios-app/Feedback.xcodeproj` path; use `XcodeOpenWorkspace` if absent. Follow Xcode's authorization prompts yourself if required. A missing connection or denied operation is a blocker to report, not a reason to switch local automation tools.

## Tests and local services

### Device Hub windows

Keep the current simulator and use one launch route per build. An ordinary run uses `RunProject`; interactive verification or local auto-login launches directly with `DeviceInteractionInstallAndRun`. Avoid doing both in succession, creating simulator clones, or separately opening Device Hub just to launch an app.

The currently exposed native Xcode MCP launch tools have no Device Hub window identifier or reuse-window parameter. Reusing the simulator therefore does not guarantee reusing its viewer window. Apple's [Device Hub documentation](https://developer.apple.com/documentation/xcode/device-hub) describes compact windows on simulator launch; its [WWDC session](https://developer.apple.com/videos/play/wwdc2026/260/) also describes viewing devices in tabs. The [Xcode 27.2 RC release notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-27_2-release-notes) list Device Hub settings/input fixes, but do not document a fix or setting for reusing an existing window on repeated launch (checked 2026-10-27). Treat window reuse as unverified, not as a guaranteed benefit of upgrading Xcode.

Do not quit Device Hub or close unrelated windows to hide duplicates. Report duplicate-window behavior if native launch creates it; do not invent a private preference or switch automation tools to work around it.

### Test environment

For self-service manual testing, use the [two-simulator guide](local-testing.md).
The shared `Feedback Localhost Manager` and `Feedback Localhost Anonymous`
schemes select their account before the app starts observing authentication.
The manager scheme fetches a fresh local token; normal launches never seed or
reset fixtures. These schemes do not require agent tooling or manual signup.

The shared `Feedback Localhost` scheme uses `DebugLocalhost` for launch and tests. Its default `UnitTests` plan includes `AppTests` and `InsightsTests`. Tests do not inherit app launch arguments, including temporary auto-login credentials. The simulator workflow verifies discovery before running tests.

Unit/reducer tests use injected dependencies and do not require resetting or seeding the backend. Authenticated live UI checks need the local backend and working local Firebase configuration; follow the login skill. The Localhost app addresses `http://localhost:8080` directly from the simulator, while the login helper calls `http://localhost:8080`. No proxy is required. No new developer-managed runtime environment variables or services are introduced by this harness.

Fixture reset/creation is separate from login. [Maestro's explicit E2E runner](../.maestro/README.md) starts the local stack and resets data before each flow. Do not use it merely to launch or log in. Its CLI build/install operations are an exception for explicitly requested Maestro flows.

## Build and run workflows

Invoke either root skill from an agent session started at the monorepo root:

| Skill | Backend preparation | Simulator scheme |
| --- | --- | --- |
| `$letsgrow-ios-localhost` | Build local API image, start API/Postgres, wait for health; optional explicit fixture preparation/reset | `Feedback Localhost`, or Manager/Anonymous schemes with `manager`, `anonymous`, or `both` |
| `$letsgrow-ios-production` | Check the existing Coolify API's health | `Feedback Production` / `Release` |

The skills own the complete backend-to-simulator sequence. Both use native Xcode MCP for app build/install/launch and keep the current eligible simulator. They leave the app running for manual testing. Production mode targets the already deployed backend; it does not deploy services or publish an iOS build.

The supporting shell commands prepare/check only the backend:

```sh
./scripts/ios-backend localhost
./scripts/ios-backend production
```

Localhost preparation requires a local Docker daemon, Java/Gradle prerequisites, Python 3, curl, the existing root `.env` Compose contract, and iOS `App/Config/secrets.xcconfig` for live Firebase auth. It builds only `:api:jibDockerBuild`, uses Compose's `IMAGE_PLATFORM` for the Jib base image, and explicitly tags `nicolaidam/feedback-api:local`. It starts `db` and `api` with the root Compose files; existing web/scheduler services are left as they are. Postgres volume contents are preserved and ordinary Liquibase startup migrations still apply. Unlike `scripts/run`, it does not tear down containers, delete volumes, reset/seed fixtures, or regenerate API artifacts. Contract changes still require the root generation script separately.

The app's Localhost API host is now direct simulator loopback (`localhost:8080`), replacing the former `proxyman.debug:8080` dependency. Backend health uses the existing local port 8090. Physical-device access needs a separately chosen reachable host and is outside these simulator workflows.

Production preparation requires only Python 3, curl, and network access. The API address is checked against `production.xcconfig`; the expected endpoint is `https://api.letsgrow.dk`. No Coolify token or local backend is required. Production builds use normal app login; localhost admin tokens are not passed to Release builds. These workflows introduce no new runtime secrets, domains, ports, deployments, or hosting costs.

Run the backend helper's regression checks with `python3 -m unittest discover -s scripts/tests -v`. They use controlled command stubs and do not touch real services.

## Lint policy

From the repository root, run:

```sh
python3 ios-app/scripts/lint-swift-changes.py --base "$(git merge-base origin/main HEAD)"
```

Use the task's actual target branch instead of `origin/main` when different. `--base HEAD` checks only uncommitted work. The comparison includes staged, unstaged, and untracked Swift files. Deleted files are skipped; generated code and tests retain the exclusions in `ios-app/.swiftlint.yml`.

Violations on added/modified lines fail the check; existing violations on untouched lines do not. Fix issues deliberately and rerun. Exit codes are 0 for clean, 1 for changed-line violations, and 2 for tooling/configuration failure. Full-file lint remains available through `swiftlint lint --reporter xcode` from `ios-app/` for an explicitly requested broader audit.

## CI

The `iOS` workflow runs for pull requests and pushes to `main` touching `ios-app/**`, `scripts/ios-backend`, `scripts/tests/**`, or the workflow itself. It adds one macOS 26 job, capped at 45 minutes, with Xcode's latest stable installation, SwiftLint, and Python. This incurs macOS runner time only for matching changes. Since the workflow is path-filtered, do not make its check universally required on unrelated pull requests. The backend-helper regression checks use stubs and do not start Docker services or contact production in CI.

CI uses the same changed-line lint gate against the merge base and builds/tests `Feedback Localhost` with the `UnitTests` plan on an available iPhone simulator with iOS 26 or newer. It disables signing, validates macros non-interactively, and retains `.xcresult` artifacts for seven days. GitHub-hosted CI uses command-line Xcode tools; local agents use native Xcode MCP. No deployment, image, domain, port, or secret changes are required.

The existing `CI` workflow separately checks generated API artifacts; it is not the app's build/test gate. Xcode Cloud's existing `CI_scripts/` release hooks are separate from GitHub Actions and are not invoked by this workflow.
