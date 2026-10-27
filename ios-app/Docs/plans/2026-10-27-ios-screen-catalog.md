# Native Xcode screen catalog

Date: 27 October 2026
Status: 145 named screen and state previews captured.

The earlier five-preview proof of concept established Xcode 27's native `RenderPreview` as a reliable source of real SwiftUI snapshots. An unchanged warm five-image batch took 1.80 seconds; a same-environment concurrency check measured 1.69 seconds sequentially and 1.66 seconds concurrently. The difference was too small to justify concurrent capture. These are cached observations, not clean-build timings.

The catalog now covers app startup and sign-in; manager, participant, and anonymous tabs; profile and settings; activity lists, overviews, creation and editing; session creation, details and invitation; participant sessions; notifications; the question editor; and every feedback answer type and result. It includes representative empty, populated, saving, offline, error, and success states, with longer content snapshots where the initial phone viewport would omit important content.

Every preview uses fixed fixtures and an inert reducer, so capture does not require login or call the backend. Xcode MCP renders previews; the Python publisher validates the full batch and copies the original PNG bytes to `Docs/screenshots/catalog/`. The output folder contains the image files only. The current workflow and its coverage limits are in [the screenshot instructions](../screenshots/README.md).

Native modal framing and system-owned alerts are not captured. Foundation date strings follow the preview host locale, even though SwiftUI's locale and time zone are fixed. The tall full-content images use a different layout from phone captures.
