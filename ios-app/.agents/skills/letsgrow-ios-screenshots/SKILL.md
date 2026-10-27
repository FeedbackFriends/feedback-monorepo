---
name: letsgrow-ios-screenshots
description: Refresh LetsGrow's complete iOS screen and state screenshot set using named SwiftUI previews, native Xcode MCP rendering, and the full-size PNG publisher.
---

# Refresh the iOS screenshots

Follow [the iOS policy](../../../AGENTS.md) and [screenshot notes](../../../Docs/screenshots/README.md). Use the native Xcode MCP server for every preview render; do not substitute Xcode command-line tools, simulator automation, or a browser.

1. Discover the open Xcode workspace and select the checkout at `ios-app/Feedback.xcodeproj`. Use `Feedback Localhost` and the active eligible iPhone simulator. Never choose a physical device implicitly.
2. Run `python3 ios-app/scripts/publish-preview-catalog.py --plan` from the repository root. The plan discovers each named `#Preview` and its zero-based Xcode definition index from feature `ScreenCatalogPreviewView.swift` files. Do not maintain a second preview list.
3. Render every plan entry through `mcp__xcode__RenderPreview`, sequentially, passing its arguments and the discovered `workspaceIdentifier`. Record the elapsed time and the tool's `structuredContent` for each result. Stop the batch if a render fails, reports an error, or returns a `displayName` that differs from the requested ID. Inspect screenshots when names or UI contents appear stale; Xcode may retain a preceding preview image.
4. Write the complete array of `{id, seconds, result}` records to `ios-app/.build/preview-catalog/captures.json`, then run `python3 ios-app/scripts/publish-preview-catalog.py --captures ios-app/.build/preview-catalog/captures.json`.
5. Confirm `ios-app/Docs/screenshots/catalog/` contains one PNG per plan entry and no HTML gallery, Markdown index, manifest, or benchmark artifacts. The publisher validates every PNG before copying its original bytes; it never resizes or recompresses images.

If adding a screen, create a uniquely named preview in the owning feature module, using fixed fixture data and an inert reducer. Shared sample models belong in `Modules/Sources/Domain/PreviewCatalogFixtures.swift`. For long screens, add a named `.fixedLayout` preview ending in `.full-content`. Capture sheet contents directly and identify them as sheet contents; switching native sheet previews has retained stale presentation images.
