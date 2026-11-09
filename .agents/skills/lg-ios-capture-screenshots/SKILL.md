---
name: lg-ios-capture-screenshots
description: Capture and compare the curated LetsGrow iOS catalog through app-hosted Point-Free SnapshotTesting and native Xcode MCP.
---

# Capture and review iOS screenshots

Follow the [iOS policy](../../../ios-app/AGENTS.md), [visual review rules](SKILL.md#visual-review), and [capture documentation](../../../docs/ios/screenshots/README.md). Point-Free SnapshotTesting owns catalog capture. Keep SwiftUI previews for interactive development; do not use them to generate review images or silently fall back to another renderer.

For a one-command local capture, run `./scripts/ios/capture-screenshots.py` from the repository root (`--no-open` skips opening the gallery). It uses Apple's native `xcrun mcpbridge`, builds and captures through Xcode MCP, and publishes only after the capture test passes. Xcode may require first-use permission for this command-line client. Do not automate that permission dialog. The steps below describe the same workflow through the connected tools.

1. Run `python3 scripts/ios/manage-snapshot-catalog.py --generate` if selected previews or screenshot selection changed, then `--check`. Only previews with a `// Screenshot: <reason>` comment directly above them enter the capture inventory; generated factory sections reuse the real feature fixtures. Do not hand-edit generated sections or maintain a second state list.
2. Discover this checkout's Xcode workspace through native MCP. Select `Feedback Localhost`, keep the active eligible iPhone simulator, and select the `ScreenSnapshots` test plan. Build with `BuildProject(buildForTesting: true)`.
3. Discover and run `ScreenSnapshotTests/testCaptureCatalog()` with native Xcode MCP. The catalog test captures all selected states, including the native alert, once using Point-Free SnapshotTesting after bounded layout readiness checks. The alert is verified for presentation and text before its image is written to the same batch.
4. Stop publication if either test fails. Report the exact failing state and diagnose it; do not substitute a previous capture, change tolerances, mask pixels, or accept images automatically.
5. On success, run `python3 scripts/ios/manage-snapshot-catalog.py --publish screenshots/capture`, then `ios-app/.build/screenshot-tools/bin/python scripts/ios/review-screenshots.py`. Follow the README's venv/dependency setup if needed. The approved PNGs under `docs/ios/screenshots/catalog/` remain untouched.
6. Review all current screenshots manually or with an agent, recording IDs/hashes and meaningful findings or uncertainty beside the report. Do not use pixel equality as the decision gate. Report reviewed/pending, added, and removed counts, `screenshots/index.html`. Full-content states retain their own canvas dimensions.
7. Return to the normal `UnitTests` plan. Continue simulator verification for behavior and native presentations; snapshot images verify fixture layouts.
8. Only after explicit approval, run the review script's `--accept screen.id ...` or `--accept-all` for the approved report. Never commit or push unless separately requested.

Select one representative layout per screen; include extra states only for meaningful content/layout differences. Keep routine loading, saving, disabled, partial-input, and individual answer-value variants as unmarked interactive previews. Prefer full-content coverage over duplicate standard-height images.

For capture-harness changes, verify the full catalog including the native alert, inspect representative controls and the alert PNG, and run the Python tooling tests. Alert readiness requires an attached presentation with no active transition and stable layout; the bounded timeout must name the state and phase. Optional pixel diagnostics may help investigate captures, but tiny numerical differences do not block visual review. Baseline acceptance remains an explicit user decision.

## Visual review

The human owns manual visual review after implementation. Run this procedure when screenshots or visual testing are explicitly requested; it is not an implementation completion gate. Capture the complete catalog and generate the before/after report for requested UI review, including shared design changes. Preserve approved baselines and report capture blockers rather than presenting older captures as fresh evidence.

Keep [simulator verification](../../../ios-app/AGENTS.md#simulator-verification) for behavior and native presentations; app-hosted snapshot tests verify fixture layouts. Native alerts belong to the same catalog, with presentation and text assertions before capture.
