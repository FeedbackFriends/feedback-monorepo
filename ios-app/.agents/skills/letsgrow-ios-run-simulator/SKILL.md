---
name: letsgrow-ios-run-simulator
description: Run the LetsGrow iOS app on the iPhone 17 Pro, iOS 26.4 simulator using Xcode command-line tooling. Use when the user asks to launch, run, or verify the iOS app on that exact simulator.
---

# LetsGrow iOS Simulator Run

Run the iOS app on the exact simulator target:

- Project: `Feedback.xcodeproj`
- Scheme: `Feedback Localhost`
- Device: `iPhone 17 Pro`
- OS: `iOS 26.4`

## Hard Rule

Use Xcode command-line tooling:

- `xcrun simctl` for simulator discovery, booting, install, and launch.
- `xcodebuild` for project build and build-settings inspection.
- `open -a Simulator` only when needed to make the booted simulator visible.

Do not use MCP/XcodeBuildMCP as the primary path for this skill. Do not use AppleScript or manual Xcode steps.

## Required CLI Capabilities

Before building, confirm the local Xcode CLI can do all of:

1. Find an exact simulator whose name is `iPhone 17 Pro` and runtime is `iOS 26.4`.
2. Build the `Feedback Localhost` scheme from `Feedback.xcodeproj` for that simulator.
3. Locate the built `.app`, install it on the simulator, and launch it by bundle identifier.

If any of these are unavailable, stop and report the exact missing or failing step.

## Workflow

1. List simulators with `xcrun simctl list devices available --json`.
2. Select the exact device where `name == "iPhone 17 Pro"` and the runtime key represents `iOS 26.4`.
3. If the simulator is not booted, run `xcrun simctl boot <udid>`. If needed, run `open -a Simulator`.
4. Build with:

   ```bash
   xcodebuild \
     -project Feedback.xcodeproj \
     -scheme "Feedback Localhost" \
     -destination "platform=iOS Simulator,id=<udid>" \
     -configuration Debug \
     build
   ```

5. Resolve build output with:

   ```bash
   xcodebuild \
     -project Feedback.xcodeproj \
     -scheme "Feedback Localhost" \
     -destination "platform=iOS Simulator,id=<udid>" \
     -configuration Debug \
     -showBuildSettings
   ```

   Use `BUILT_PRODUCTS_DIR`, `WRAPPER_NAME`, and `PRODUCT_BUNDLE_IDENTIFIER` from the app target's build settings. The app path is `<BUILT_PRODUCTS_DIR>/<WRAPPER_NAME>`.

6. Install and launch:

   ```bash
   xcrun simctl install <udid> "<app-path>"
   xcrun simctl launch <udid> <bundle-id>
   ```

7. If Maestro MCP device list/screenshot capability is available after launch, use it only for optional verification.

## Parsing Notes

- Prefer structured JSON parsing for `simctl` output when possible.
- For `xcodebuild -showBuildSettings`, read the app target values. If several targets appear, choose the target whose `WRAPPER_NAME` ends in `.app`.
- Use the exact simulator UDID in all `xcodebuild` and `simctl` commands.
- Keep command output concise in the final response; summarize only the selected simulator, build result, install result, and launch result.

## Reporting

On success, report:

- The CLI path used.
- The simulator target.
- Whether the app launched successfully.

On failure, report the precise missing or failing CLI step, such as:

- `No iPhone 17 Pro, iOS 26.4 simulator was found by simctl.`
- `xcodebuild failed: <short error summary>.`
- `The built .app path could not be resolved from build settings.`
- `simctl install failed: <short error summary>.`
- `simctl launch failed: <short error summary>.`
