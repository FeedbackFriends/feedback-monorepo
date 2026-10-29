# iOS testing and linting

Paths are relative to `ios-app/` unless stated otherwise.

- Use Swift Testing, TCA `TestStore`, and snapshot tests for module behavior.
- Put tests under `Modules/Tests/`, mirroring source module names.
- Use Maestro for user-facing mobile journeys when appropriate.
- When changing Swift code, run `python3 ios-app/scripts/lint-swift-changes.py --base <merge-base>` from the monorepo root before finishing. Use the merge base with the task's target branch (normally `origin/main`); use `HEAD` for a check of uncommitted changes only.
- Fix lint violations on added or modified lines. Existing violations on untouched lines are not a gate; do not expand the task to clean them up. The script honors `.swiftlint.yml` exclusions and never modifies files. Do not run auto-fix commands unless the user explicitly asks.
- Final responses for Swift code changes should include the lint command result.

GitHub Actions uses command-line Xcode tools on its isolated macOS runner for the `iOS` workflow. This CI exception does not change the native Xcode MCP requirement for local agent work. Explicitly requested Maestro flows remain governed by [the Maestro flow guidance](../../.maestro/README.md) and may reset local fixture data.
