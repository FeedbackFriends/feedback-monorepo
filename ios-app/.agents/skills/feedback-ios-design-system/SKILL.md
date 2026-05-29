---
name: feedback-ios-design-system
description: Expert guidance for the Feedback iOS app design system in `Modules/Sources/DesignSystem/`, including reusable SwiftUI components, button styles, view modifiers, typography, colors, images, Lottie assets, and theme conventions. Use for any work on SwiftUI files, including building, reviewing, or refactoring UI in this app, and reuse or extend the existing DesignSystem instead of inventing new styling.
---

# Feedback iOS Design System

Use `Modules/Sources/DesignSystem/` as the source of truth. Prefer reusing existing tokens, styles, and reusable views before introducing new UI primitives.

## Invocation Rule

If you are touching a SwiftUI file in this app, invoke this skill first. This includes adding a view, editing a view, refactoring a view, reviewing SwiftUI code, or changing UI styling in a `.swift` file that contains SwiftUI.

## Workflow

1. Read `references/design-system.md` for the inventory of components, tokens, and conventions.
2. Inspect the exact source files you plan to use or change before making UI edits.
3. Reuse existing `Color`, `Font`, button style, reusable view, and modifier APIs where they fit.
4. Add new DesignSystem code only when the existing surface clearly does not cover the need.

## Rules

- Use only semantic colors exposed from `Resources/Colors/Colors.swift`, such as `Color.theme...` and UIKit bridges defined there. Do not use SwiftUI/UIKit system colors or raw palette colors in app UI, including `.secondarySystemBackground`, `.systemGray`, `.secondary`, `.tertiary`, `.green`, `Color.gray`, `Color.black`, `Color.white`, or `UIColor.white`.
- Use Montserrat through the DesignSystem font helpers such as `.font(.montserratSemiBold, 16)`. Do not introduce ad hoc font families.
- Prefer existing button styles from `Styles/ButtonStyles/` over custom inline button styling.
- Prefer existing reusable views from `ReusableViews/` for common empty, error, banner, close, picker, and event-info UI.
- Use `Theme.cornerRadius`, `Theme.padding`, and `Constants.maxWidthForLargeDevices` instead of duplicating those layout constants.
- Use `.isLoading(...)` when working with loading-aware button styles.
- Keep app-facing UI code free of raw asset names when `Image` helpers already exist in `Resources/Images/Images.swift`.
- When extending the design system, put new code in the matching DesignSystem subfolder and follow the established API shape.

## Reference Files

- Read `references/design-system.md` for the current public surface, tokens, and design conventions of this module.
