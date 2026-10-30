# iOS screenshot catalog

The catalog now captures a curated set of **57 screen/state images, including the native sign-in alert** through the app-hosted Point-Free SnapshotTesting target. The alert uses the same capture and review pipeline, with presentation, title, message, and OK action checks before capture. Interactive SwiftUI previews remain available for development, but `RenderPreview` is no longer the screenshot generator.

Approved images remain in `Docs/screenshots/catalog/`. Capture and review commands never replace those images automatically. The initial comparison against Xcode-generated screenshots shows changes because the new capture profile has different dimensions and framing; those images need a one-time visual review before approving the new baseline.

## Capture profile and inventory

Named `#Preview` declarations with a `// Screenshot: <reason>` comment directly above them in each feature's `ScreenCatalogPreviewView.swift` are the capture inventory. Unmarked previews remain available in Xcode without being captured.

Select one representative layout per screen. Add empty, error, role, or presentation variants only when they materially change content or layout. Loading, saving, disabled buttons, partial input, and each individual answer value do not need screenshots on every screen. Keep a representative example where the visual design itself needs coverage (such as the startup loading screen). Use standard-height captures; full-content variants are excluded from the catalog. New previews are excluded from capture until explicitly selected with a reason. Shared fixtures live in `Domain/PreviewCatalogFixtures.swift`. `screen-catalog.json` describes the capture profile.

Generate the test factories after changing a selected preview or its screenshot selection:

```sh
python3 ios-app/scripts/screen-catalog.py --generate
python3 ios-app/scripts/screen-catalog.py --check
python3 ios-app/scripts/screen-catalog.py --plan
```

The generator writes marked sections into the existing feature catalog files, where factories can use the same private helpers as previews. Never hand-edit those generated sections. The compiler and generated-factory check must pass before capturing.

The host uses a 402 × 874 point canvas at 3× scale, standard-range sRGB output, light appearance, large text size, Danish fixture locale, and fixed Copenhagen reference time. Full-content states use their declared width and height. The output is the original PNG; no hardware mask, resizing, recompression, or pixel masking is applied. Keep the Xcode version, simulator/runtime, host locale, and host timezone consistent. Foundation date strings still follow the host locale in some app formatting paths.

Catalog-only focus suppression prevents automatic keyboards. Feedback content mounts directly in its final navigation state. Relative-time labels and session grouping use the fixture reference time. Native picker/scroll animations are settled before readback; the chart plot is rasterized as one SwiftUI drawing group during capture. App-owned glass styling is retained by hierarchy rendering. Live navigation and focus behavior do not use these catalog-only overrides.

Generated output paths beginning with `screenshots/` are relative to the monorepo root. That folder is gitignored. Python dependencies remain in the app’s build cache.

## One-command capture

From the repository root in Warp:

```sh
./ios-app/scripts/screenshots
```

This checks the generated inventory, builds and runs the catalog capture test using Apple's native Xcode MCP bridge, publishes the complete successful batch, generates the current screenshot grid, and opens it in your default browser. Xcode must have MCP access enabled and an eligible iPhone simulator selected. On first use, Xcode may ask you to approve the command-line client and project folder. Allow that prompt in Xcode. The script creates the local screenshot-tools virtual environment and installs its requirements if it does not exist. It returns the Localhost scheme to the `UnitTests` plan after capture and never accepts baselines.

Use `./ios-app/scripts/screenshots --no-open` to skip opening the browser. The command works from any directory when invoked by its full path.

- Original captures: `screenshots/capture/`
- Native alert: `screenshots/capture/sign-in.error.png` (included in the same gallery)
- Review gallery: `screenshots/index.html`
- Approved baselines: `Docs/screenshots/catalog/` (only changed by explicit acceptance)

## Generate screenshots

Use **native Xcode MCP** for every build and test operation; do not substitute command-line Xcode tools or simulator automation.

1. Discover this checkout's `Feedback.xcodeproj`, select `Feedback Localhost`, and retain the active eligible iPhone simulator. Never implicitly select a physical device.
2. Select the `ScreenSnapshots` test plan, then build with `BuildProject(buildForTesting: true)`.
3. Discover tests with `GetTestList`. Run `ScreenSnapshotTests/testCaptureCatalog()` through `RunSomeTests`.
4. The capture test renders each automated state once through Point-Free SnapshotTesting and writes `screenshots/capture/` and a capture manifest. Before capture, the host polls for stable layout, yielding to initial SwiftUI tasks between checks without a fixed startup delay. Alert capture additionally waits for a presented, attached UIAlertController with no active transition. The readiness wait is bounded to three seconds and reports the state and phase on timeout. Animation time is frozen only after readiness, at the current presentation time. The alert is written as `capture/sign-in.error.png` in the same batch. The capture test must pass before publication. A failed capture must not be replaced with old images or presented as fresh verification.
5. Publish the complete successful batch and generate the review:

```sh
python3 ios-app/scripts/screen-catalog.py --publish screenshots/capture
ios-app/.build/screenshot-tools/bin/python ios-app/scripts/review-preview-catalog.py
open screenshots/index.html
```

6. Return Xcode to the default `UnitTests` plan. Report capture/test status, screens awaiting visual review, added/removed counts, the review page link.

The publisher validates every expected image, dimensions, and the failure-free manifest before replacing the generated `current/` set. It preserves the original PNG bytes and approved baselines. The default review page includes every current screenshot in a responsive grid, with several screens visible side by side and links to the original PNGs. Optional `--pixel-diff` generates pink difference images and sliders as diagnostics.

## Comparison and approval

Install the local comparison dependency once:

```sh
python3 -m venv ios-app/.build/screenshot-tools
ios-app/.build/screenshot-tools/bin/pip install -r ios-app/scripts/screenshot-requirements.txt
```

Human or agent visual review is the decision step. Review every current screenshot for missing content, clipping, overlap, layout, typography, copy, and color changes. Record the reviewed IDs and hashes from `report.json`, meaningful findings, and uncertainty in a findings file beside the report. The agent recommends changes; it never automatically approves baselines. The first migration compares against historical Xcode captures with different framing and potentially stale content, so those differences require context.

Optional `--pixel-diff` and `--check-repeat FIRST SECOND` compare decoded RGBA pixels for investigation; numerical differences do not fail the workflow. Only after the user approves the displayed changes:

```sh
ios-app/.build/screenshot-tools/bin/python ios-app/scripts/review-preview-catalog.py --accept home.populated
# Only when all reported changes have been approved:
ios-app/.build/screenshot-tools/bin/python ios-app/scripts/review-preview-catalog.py --accept-all
```

Acceptance copies the exact reviewed images and rejects a changed baseline or modified review image. It does not commit or push anything. System alert appearance is not included in the pixel guarantee.

## Capture reliability

Capture failures, invalid images, missing states, readiness timeouts, and alert content failures block publication. Pixel equality is no longer a gate. Stable fixtures, fixed dates, suppressed focus, settled controls, and readiness checks keep screenshots useful without treating tiny native rendering noise as a regression. Historical repeatability studies remain in `.build/snapshot-trial/` and `.build/screen-catalog/`; they are diagnostic evidence, not the current approval policy.

Regression checks for inventory generation, publication safety, and comparison:

```sh
ios-app/.build/screenshot-tools/bin/python -m unittest discover -s ios-app/scripts/tests -p 'test_*catalog.py'
```
