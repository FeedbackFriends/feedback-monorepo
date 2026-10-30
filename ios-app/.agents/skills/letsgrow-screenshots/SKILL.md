---
name: letsgrow-screenshots
description: Capture and compare the curated LetsGrow iOS catalog through app-hosted Point-Free SnapshotTesting and native Xcode MCP.
---

# Capture and review iOS screenshots

Follow the [iOS policy](../../../AGENTS.md), [visual review rules](../../../Docs/agents/visual-review.md), and [capture documentation](../../../Docs/screenshots/README.md). The user authorized migration from RenderPreview to Point-Free SnapshotTesting. Keep SwiftUI previews for interactive development; do not use them to generate review images or silently fall back to another renderer.

For a one-command local capture, run `./ios-app/scripts/screenshots` from the repository root (`--no-open` skips opening the gallery). It uses Apple's native `xcrun mcpbridge`, builds and captures through Xcode MCP, and publishes only after the capture test passes. Xcode may require first-use permission for this command-line client. Do not automate that permission dialog. The steps below describe the same workflow through the connected tools.

1. Run `python3 ios-app/scripts/screen-catalog.py --generate` if selected previews or screenshot selection changed, then `--check`. Only previews with a `// Screenshot: <reason>` comment directly above them enter the capture inventory; generated factory sections reuse the real feature fixtures. Do not hand-edit generated sections or maintain a second state list.
2. Discover this checkout's Xcode workspace through native MCP. Select `Feedback Localhost`, keep the active eligible iPhone simulator, and select the `ScreenSnapshots` test plan. Build with `BuildProject(buildForTesting: true)`.
3. Discover and run `ScreenSnapshotTests/testCaptureCatalog()` with native Xcode MCP. The catalog test captures all selected states, including the native alert, once using Point-Free SnapshotTesting after bounded layout readiness checks. The alert is verified for presentation and text before its image is written to the same batch.
4. Stop publication if either test fails. Report the exact failing state and diagnose it; do not substitute a previous capture, change tolerances, mask pixels, or accept images automatically.
5. On success, run `python3 ios-app/scripts/screen-catalog.py --publish screenshots/capture`, then `ios-app/.build/screenshot-tools/bin/python ios-app/scripts/review-preview-catalog.py`. Follow the README's venv/dependency setup if needed. The approved PNGs under `Docs/screenshots/catalog/` remain untouched.
6. Review all current screenshots manually or with an agent, recording IDs/hashes and meaningful findings or uncertainty beside the report. Do not use pixel equality as the decision gate. Report reviewed/pending, added, and removed counts, `screenshots/index.html`. Full-content states retain their own canvas dimensions. Explain the one-time format/framing change when comparing the migrated renderer with old Xcode baselines.
7. Return to the normal `UnitTests` plan. Continue simulator verification for behavior and native presentations; snapshot images verify fixture layouts.
8. Only after explicit approval, run the review script's `--accept screen.id ...` or `--accept-all` for the approved report. Never commit or push unless separately requested.

Select one representative layout per screen; include extra states only for meaningful content/layout differences. Keep routine loading, saving, disabled, partial-input, and individual answer-value variants as unmarked interactive previews. Prefer full-content coverage over duplicate standard-height images.

For capture-harness changes, verify the full catalog including the native alert, inspect representative controls and the alert PNG, and run the Python tooling tests. Alert readiness requires an attached presentation with no active transition and stable layout; the bounded timeout must name the state and phase. Optional pixel diagnostics may help investigate captures, but tiny numerical differences do not block visual review. Baseline acceptance remains an explicit user decision.
