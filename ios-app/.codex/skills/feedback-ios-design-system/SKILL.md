---
name: feedback-ios-design-system
description: Expert guidance for the Feedback iOS app design system in `Modules/Sources/DesignSystem/`, including reusable SwiftUI components, button styles, view modifiers, typography, colors, images, Lottie assets, and theme conventions. Use when building, reviewing, or refactoring UI in this app and you need to reuse or extend the existing DesignSystem instead of inventing new styling.
---

# Feedback iOS Design System

Use `Modules/Sources/DesignSystem/` as the source of truth. Prefer reusing existing tokens, styles, and reusable views before introducing new UI primitives.

## Workflow

1. Read `references/design-system.md` for the inventory of components, tokens, and conventions.
2. Inspect the exact source files you plan to use or change before making UI edits.
3. Reuse existing `Color`, `Font`, button style, reusable view, and modifier APIs where they fit.
4. Add new DesignSystem code only when the existing surface clearly does not cover the need.

## Rules

- Use `Color.theme...` tokens from `Resources/Colors/Colors.swift`. Do not hardcode new colors in feature code.
- Use Montserrat through the DesignSystem font helpers such as `.font(.montserratSemiBold, 16)`. Do not introduce ad hoc font families.
- Prefer existing button styles from `Styles/ButtonStyles/` over custom inline button styling.
- Prefer existing reusable views from `ReusableViews/` for common empty, error, banner, close, picker, and event-info UI.
- Use `Theme.cornerRadius`, `Theme.padding`, and `Constants.maxWidthForLargeDevices` instead of duplicating those layout constants.
- Use `.isLoading(...)` when working with loading-aware button styles.
- Keep app-facing UI code free of raw asset names when `Image` helpers already exist in `Resources/Images/Images.swift`.
- When extending the design system, put new code in the matching DesignSystem subfolder and follow the established API shape.

## Reference Files

- Read `references/design-system.md` for the current public surface, tokens, and design conventions of this module.
