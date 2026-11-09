# Answer-type icons

The five editable sources are native SVG image sets in
`ios-app/Modules/Sources/DesignSystem/Resources/Images/Images.xcassets/answer-type-*.imageset/`.
`Images.swift` exposes them through the existing `feedbackType...` image helpers.
The image sets preserve vectors and render as monochrome templates, so callers
supply semantic tint. Xcode compiles the SVGs directly; no conversion command,
runtime SVG renderer, font, or additional dependency is required.

All sources use a 64×64 viewBox, rounded strokes, and a 24pt intrinsic size.
Explicitly resizable callers can display them at other sizes. The motifs are:

| Type | Motif |
| --- | --- |
| Emoji | Sad, neutral and happy faces |
| Comment | Speech bubble with text lines |
| Thumbs | Both thumbs up and thumbs down |
| Opinion | Five discrete choices from minus to plus |
| Rating | Numeric 0–10 endpoints and a slider |

Numeric endpoints are paths, so asset rendering does not depend on installed fonts.
Black source strokes are replaced by template tint. Labels remain alongside icons;
the icon is never the only accessible description of an answer type.

The `answer-type-icons.sizes-and-themes` screen catalog fixture shows all five assets
at 24 and 32pt against light and dark semantic surfaces. The `answer-type-picker.*`
fixtures cover the temporary-choice sheet and participant previews. Follow the
[visual review workflow](../../.agents/skills/lg-ios-capture-screenshots/SKILL.md#visual-review) to capture and inspect
the current native renderings without accepting baselines automatically.
