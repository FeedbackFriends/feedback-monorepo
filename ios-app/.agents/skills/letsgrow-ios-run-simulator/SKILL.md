---
name: letsgrow-ios-run-simulator
description: Build, test, launch, and verify LetsGrow iOS changes through native Xcode MCP. Defaults to Feedback Localhost; supports an explicitly requested Feedback Production launch. Use for simulator requests and verification after implementing iOS changes; honor build-only or launch-only requests.
---

# Run LetsGrow on a Simulator

Follow [the iOS policy](../../../AGENTS.md). Setup and configuration ownership are in [the harness overview](../../../Docs/agent-harness.md). Use native `mcp__xcode` tools. Default to `Feedback Localhost`; an explicitly requested production run uses `Feedback Production` (Release). A request only to launch or build does not require the full verification sequence below. For backend preparation, use the root `letsgrow-ios-localhost` or `letsgrow-ios-production` skill as appropriate.

## Apple's current guidance

Discover the native Xcode MCP capabilities available in the current session. Load relevant Apple-provided skills or instructions through the discovery/read mechanisms actually exposed by the client or referenced in tool responses. Do not assume a particular Apple skill name, filesystem location, or version, and do not install or copy skills merely because a tool mentions one.

Use Apple's available guidance for tool syntax and operation. Resolve tool names and arguments from the current tool descriptions; the names below describe the existing workflow rather than pinning an Xcode API version.

If a tool response references guidance that the client does not expose, continue directly through native Xcode MCP when its tool descriptions provide enough information to perform the task. A referenced skill or suggested delegation is not by itself a blocker or a requirement to spawn another agent. Delegate only when authorized by the user or applicable repository instructions. Report a blocker when the required native capability, permission, or operational information is actually unavailable; distinguish this from a missing optional instruction resource. Never invent interaction syntax or replace native Xcode MCP with another automation backend.

## Workflow

1. Discover the workspace with `XcodeListWorkspaces`, matching the absolute `ios-app/Feedback.xcodeproj` path in the current checkout. Other LetsGrow or Dinero windows may be open. Open the project with `XcodeOpenWorkspace` only when absent; list again if opening times out. Pass the discovered identifier to later workspace tools.
2. Select the chosen scheme using `XcodeSwitchScheme` (`Feedback Localhost` by default, `Feedback Production` for an explicit production run). Confirm the destination with `XcodeListRunDestinations`. Keep the active eligible simulator unless the user chooses another; if none is active, select an eligible simulator explicitly and report it. Never run on a physical device implicitly.
3. For tests, use `Feedback Localhost`, inspect `XcodeListTestPlans`, and select `UnitTests` with `XcodeSwitchTestPlan` if needed. `GetTestList` must discover enabled tests from both `AppTests` and `InsightsTests`; inspect its full list file when inline results are truncated. Missing plans, targets, or zero discovered tests are blockers, not a passing test run. Do not switch schemes to hide configuration failures. A production launch does not run tests; if tests were also requested, run them on Localhost and explicitly reselect Production before the production build/run.
4. After implementation, build with `BuildProject` and run tests relevant to the changed behavior with `RunSomeTests`, using identifiers from `GetTestList`. Suite names (the prefix before `/` in a discovered identifier) can select an entire suite, including when MCP rejects an individual Swift test name containing backticks/spaces. Use `RunAllTests` for shared behavior or test-harness changes. A requested build-only operation needs only `BuildProject`.
5. Run the changed-line lint check defined in `AGENTS.md` when Swift files changed. It covers staged, unstaged, and untracked files relative to the supplied base. A lint-script or lint-configuration change also needs a check of the script's behavior. Never autofix as part of verification.
6. Choose one launch route per build: `RunProject` for an ordinary run, or the interactive install/run in step 7. Do not call `RunProject` immediately before `DeviceInteractionInstallAndRun`; repeated launches can create extra Device Hub windows. For authenticated **localhost** checks, launch directly through [the login skill](../letsgrow-ios-login/SKILL.md), which supplies fresh per-launch arguments without resetting fixtures. Do not duplicate that credential procedure here or use it against production. Production login uses the normal app UI.
7. For changed user-facing behavior, start `DeviceInteractionStartWorkspaceSession`, install/launch using `DeviceInteractionInstallAndRun` (or the login skill), and inspect/interact using `DeviceInteractionSynthesize`. Check the affected path against the task's expected behavior. Base taps on the latest hierarchy; use screenshots when layout needs inspection. Close the session with `DeviceInteractionEndSession`, including on failure. An error alert makes the check failed or inconclusive; launch success alone is not UI verification.
8. On build failure, retrieve error entries with `GetBuildLog`; use narrowly filtered `GetConsoleOutput` for runtime failures. Return concise errors and artifact paths instead of entire logs. Report a blocked operation and continue independent checks where possible.

Do not fall back to XcodeBuildMCP, Xcode CLI, simulator CLI, AppleScript, or another UI automation tool. Do not automate Xcode permission dialogs. If native Xcode MCP is blocked, report the blocking operation.

Report only observed results, marking omitted checks `not run` with a reason:

```text
Scheme / simulator: <selected scheme> / <destination>
Build: passed | failed | blocked
Tests: <passed/failed/skipped counts and targets, or reason not run>
Lint: <command and result, or reason not run>
Launch / login: <separate observed outcomes>
UI: passed | failed | inconclusive | not run — <steps and expected behavior>
Blockers / artifacts: <only when relevant>
```
