# iOS screenshots

The [catalog folder](catalog/) contains one full size PNG per named screen or UI state. Filenames use stable IDs such as `home.populated.png` and `feedback.emoji.very-happy.png`. Xcode supplies the image dimensions; the publisher copies those PNG files without resizing or recompressing them. Full-content captures use taller layouts and may have different dimensions from phone captures.

## Regenerate

Ask the iOS screenshot workflow to refresh the catalog. It uses native Xcode `RenderPreview` for every named `#Preview`, checks each returned display name, then runs the filesystem publisher. To inspect the render plan from the monorepo root:

```sh
python3 ios-app/scripts/publish-preview-catalog.py --plan
```

The native render calls require an open Xcode workspace for this checkout and the `Feedback Localhost` scheme. The publisher accepts their structured results as JSON and copies only PNG files to this folder:

```sh
python3 ios-app/scripts/publish-preview-catalog.py --captures ios-app/.build/preview-catalog/captures.json
```

The screen inventory is discovered from named previews in each feature module's `ScreenCatalogPreviewView.swift`. Add a uniquely named preview there to extend it. Shared deterministic fixtures live in `Modules/Sources/Domain/PreviewCatalogFixtures.swift`; each feature module builds its own real view with explicit state. Preview reducers are inert, so captures do not log in, call the backend, or change app data.

The captures cover the current screens and representative empty, populated, error, saving, and answer states. Native sheets are captured by rendering their contents directly because Xcode could retain a prior preview's presentation image. The images do not include native sheet framing or system-owned alerts. Normal phone captures show the initial viewport; selected long screens also have `full-content` captures.

These are Xcode native preview snapshots, with device masking and Xcode's output resolution. Foundation date formatting follows the preview host locale. The fixture environment is Danish, light appearance, large Dynamic Type, and a fixed Copenhagen reference date.
