# Feedback iOS Design System Reference

Source of truth: `Modules/Sources/DesignSystem/`

## Core Direction

- Build on shared SwiftUI primitives rather than styling feature views inline.
- Invoke the `feedback-ios-design-system` skill before any work on a SwiftUI file in this app, including adding, editing, reviewing, or refactoring a view.
- Reuse semantic tokens and component APIs instead of hardcoding colors, fonts, radii, or assets.
- Keep new DesignSystem additions near similar code:
  `Resources/` for tokens and assets, `Styles/` for style wrappers, `ReusableViews/` for packaged UI, `ViewModifiers/` for cross-cutting behavior.

## Typography

Files:
- `Modules/Sources/DesignSystem/Resources/Fonts/Font.swift`
- `Modules/Sources/DesignSystem/Resources/Fonts/FontName.swift`
- `Modules/Sources/DesignSystem/Styles/OtherStyles/TextStyles.swift`
- `Modules/Sources/DesignSystem/Resources/Images/Images.swift`

Rules:
- Typography is Montserrat-only through `Font.FontName`.
- App UI should use public text-style modifiers instead of direct Montserrat font calls.
- App UI outside `Modules/Sources/DesignSystem/` should not call `.font(...)` directly. SwiftLint warns on direct font modifiers outside DesignSystem; use text-style modifiers for text and sized image helpers for symbol sizing.
- Direct `.font(.montserrat...)` calls are reserved for DesignSystem style files, `AppTheme`, and font infrastructure.
- Use explicit foreground overrides after a text-style modifier when text needs stateful, sentiment, gradient, or otherwise semantic color:
  ```swift
  Text(opinion.localized)
      .bodyTextStyle()
      .foregroundStyle(opinion.color)
  ```
- UIKit surfaces use `UIFont.font(...)` and are registered from bundled `.otf` files.

Public text styles:
- `.largeTitleTextStyle()`: prominent screen/display titles, Montserrat Bold 28 with `themeText`
- `.titleTextStyle()`: modal, card, overlay, and empty-state titles, Montserrat ExtraBold 18 with `themeText`
- `.rowTitleTextStyle()`: list rows, settings rows, selectable options, and compact headings, Montserrat SemiBold 15 with `themeText`
- `.bodyTextStyle()`: normal readable copy, Montserrat Regular 14 with `themeText`
- `.supportingTextStyle()`: secondary/help/explanatory copy, Montserrat Regular 13 with `themeTextSecondary`
- `.captionTextStyle()`: metadata, dates, small labels, and counters, Montserrat Medium 12 with `themeTextSecondary`
- `.badgeTextStyle()`: badge/pill text, Montserrat Bold 10 with `themeOnPrimaryAction`
- `.sectionHeaderStyle()`: section headers, Montserrat Medium 13 with `themeTextSecondary`

Icon sizing:
- Keep SF Symbol font sizing inside `Images.swift` helpers, such as `Image.copyActionIcon` or `Image.onboardingIcon(...)`. Put icon weight on the icon call site with `.fontWeight(...)` when needed.

Available weights:
- `montserratBlack`
- `montserratBold`
- `montserratExtraBold`
- `montserratExtraLight`
- `montserratItalic`
- `montserratMedium`
- `montserratRegular`
- `montserratSemiBold`
- `montserratThin`

Observed usage patterns:
- Large/prominent titles: bold or extra-bold.
- Section/action text: medium or semi-bold around 13 to 16 points.
- Supporting/body text: regular around 12 to 14 points.

## Color Tokens

Files:
- `Modules/Sources/DesignSystem/Resources/Colors/Colors.swift`
- `Modules/Sources/DesignSystem/Resources/Colors/Colors.xcassets/`
- `Modules/Sources/DesignSystem/DomainColors.swift`

Layout tokens:
- `Theme.cornerRadius = 18`
- `Theme.padding = 18`

Semantic color surface:
- `themePrimaryAction`: primary action green, asset `primaryAction`, roughly `#27AB85`
- `themeOnPrimaryAction`: white text on primary action
- `themeBackground`: warm off-white in light mode, very dark gray in dark mode
- `themeSurface`: slightly elevated neutral surface with dark variant
- `themeSurfaceSecondary`: darker secondary surface with dark variant
- `themeText`: dark brown text in light mode, near-white in dark mode
- `themeTextSecondary`: muted gray text in both modes
- `themeNeutral`: alias of `themeTextSecondary` for neutral sentiment or empty-state fills
- `themeSad`: orange tone
- `themeVerySad`: stronger red-orange tone
- `themeHappy`: bright mint tone
- `themeVeryHappy`: green tone
- `themeSuccess`: alias of `themeVeryHappy`
- `themeBlue`: accent blue
- `themeGradientRed`: pale warm gradient stop with dark variant
- `themeGradientBlue`: pale cool gradient stop with dark variant
- `themeChartHighlighted`
- `themeChartBackground`
- `themeHoverOverlay`

Domain mappings:
- `Opinion.color` maps strongly negative to `themeVerySad`, negative to `themeSad`, positive to `themeHappy`, strongly positive to `themeVeryHappy`, neutral to `themeNeutral`.
- `Int.ratingColor` maps `0...2`, `3...4`, `5`, `6...7`, `8...10` to the same sentiment palette, with `5` using `themeNeutral`.

Rules:
- Use only semantic colors exposed from `Colors.swift`, not SwiftUI/UIKit system colors, raw palette colors, or raw color math, in app code.
- Avoid platform color/style shortcuts such as `.secondarySystemBackground`, `.systemGray`, `.secondary`, `.tertiary`, `.green`, `Color.gray`, `Color.black`, `Color.white`, and `UIColor.white`; map them to the closest `theme...` token or add a new semantic token in the DesignSystem first.
- Reuse the sentiment colors for ratings and opinion UI to stay consistent with existing meaning.

## App Theme

File:
- `Modules/Sources/DesignSystem/AppTheme/AppTheme.swift`

Behavior:
- Centralizes UIKit appearance setup.
- Navigation large title: `montserratBold` 27 with `themeText`.
- Navigation title: `montserratBold` 16 with `themeText`.
- Segmented control: `montserratMedium` 12 with `themeText`.
- Bar button items: `montserratMedium` 15 with `themeText`.

Use `AppTheme.setUp()` as the app-level bridge between DesignSystem tokens and UIKit chrome.

## Shared Layout Constants

Files:
- `Modules/Sources/DesignSystem/Resources/Colors/Colors.swift`
- `Modules/Sources/DesignSystem/Constants.swift`

Available constants:
- `Theme.cornerRadius`
- `Theme.padding`
- `Constants.successOverlayDuration`
- `Constants.maxWidthForLargeDevices = 550`

Rules:
- Use these before introducing new duplicate radii, paddings, or width caps.

## Button Styles

Files:
- `Modules/Sources/DesignSystem/Styles/ButtonStyles/LargeButtonStyle.swift`
- `Modules/Sources/DesignSystem/Styles/ButtonStyles/LargeBoxButtonStyle.swift`
- `Modules/Sources/DesignSystem/Styles/ButtonStyles/PrimaryTextButtonStyle.swift`
- `Modules/Sources/DesignSystem/Styles/ButtonStyles/SecondaryToolbarButtonStyle.swift`
- `Modules/Sources/DesignSystem/Styles/ButtonStyles/OpacityButtonStyle.swift`
- `Modules/Sources/DesignSystem/Styles/ButtonStyles/ScalingButtonStyle.swift`

Inventory:
- `LargeButtonStyle`: primary capsule CTA with loading support, width cap, scale-on-press behavior, default gradient/primary-action styling.
- `LargeBoxButtonStyle`: full-width capsule row button on `themeSurface`, with primary and secondary text weight variants and loading support.
- `PrimaryTextButtonStyle`: compact prominent text button, typically for toolbar or retry actions.
- `SecondaryTextButtonStyle`: quieter toolbar-style text button.
- `OpacityButtonStyle`: simple pressed-opacity interaction.
- `ScalingButtonStyle`: simple pressed-scale interaction.

Rules:
- Prefer these styles instead of rebuilding button interactions, disabled states, and loading spinners.
- Loading-aware button styles rely on the `\.isLoading` environment value, so supply `.isLoading(isLoading)` from the caller. The style swaps the label for a `ProgressView` automatically — keep the title stable. Canonical pattern (same inside or outside `ToolbarItem`):
  ```swift
  Button("Save") { store.send(.saveTapped) }
      .buttonStyle(PrimaryTextButtonStyle())
      .isLoading(store.requestInFlight)
      .disabled(store.isDisabled)
  ```

## Reusable Views

Files:
- `Modules/Sources/DesignSystem/ReusableViews/Banner.swift`
- `Modules/Sources/DesignSystem/ReusableViews/CloseView.swift`
- `Modules/Sources/DesignSystem/ReusableViews/EmptyStateView.swift`
- `Modules/Sources/DesignSystem/ReusableViews/ErrorView.swift`
- `Modules/Sources/DesignSystem/ReusableViews/EventInfoView.swift`
- `Modules/Sources/DesignSystem/ReusableViews/ListItemView.swift`
- `Modules/Sources/DesignSystem/ReusableViews/UserTypePickerView.swift`

Inventory:
- `banner(unwrapping:)`: top banner for offline or server-error states.
- `CloseButtonView`: standardized dismiss button wrapper (`Button(role: .close)` tinted with `themeText`).
- `EmptyStateView`: icon plus title/message empty state.
- `ErrorView`: presentable error with optional retry button and loading support.
- `EventInfoView`: packaged event details screen using surface, padding, and typography tokens.
- `listElementView(...)`: lightweight list row helper with optional loading indicator.
- `UserTypePickerView`: opinionated role picker built from `LargeBoxButtonStyle`.

Rules:
- Reuse these for the matching UI shape before creating a new feature-local version.
- Follow their composition patterns when designing new reusable views: DesignSystem image helpers, Montserrat typography, semantic colors, shared paddings, and capsule or rounded-surface containers.
- Sheet/modal dismissal in toolbars uses `CloseButtonView` in the `.cancellationAction` slot:
  ```swift
  .toolbar {
      ToolbarItem(placement: .cancellationAction) {
          CloseButtonView { dismiss() }
      }
  }
  ```

## View Modifiers And Environment

Files:
- `Modules/Sources/DesignSystem/ViewModifiers/SuccessOverlayModifier.swift`
- `Modules/Sources/DesignSystem/ViewModifiers/PinCodeInputValidationModifier.swift`
- `Modules/Sources/DesignSystem/ViewModifiers/FocusStateSynchronize.swift`
- `Modules/Sources/DesignSystem/ViewModifiers/LightShadow.swift`
- `Modules/Sources/DesignSystem/EnvironmentValues/IsLoading.swift`

Inventory:
- `.successOverlay(...)`: transient success overlay that can auto-dismiss.
- `.pinCodeInputValidation(...)`: constrains `PinCodeInput` while typing.
- `.synchronize(...)`: keeps a binding and `FocusState` binding in sync.
- `.lightShadow(...)`: subtle shared shadow helper.
- `.isLoading(...)`: injects loading state into the environment for styles/components.

Rules:
- Prefer these modifiers when the needed behavior matches, especially for button loading and common form behavior.

## Images And Motion

Files:
- `Modules/Sources/DesignSystem/Resources/Images/Images.swift`
- `Modules/Sources/DesignSystem/Resources/Lottie/LottieFile.swift`
- `Modules/Sources/DesignSystem/Resources/Lottie/LottieView.swift`

Image helpers expose:
- Brand assets: `letsGrowIcon`, `letsGrowIconTab`, `letsGrowText`
- Sentiment assets: `verySad`, `sad`, `happy`, `veryHappy`
- Social auth assets: `iconGoogle`, `iconFacebook`, `iconApple`, `iconMicrosoft`
- Many SF Symbol wrappers for feedback, settings, navigation, and status UI

Lottie surface:
- `LottieFile.fiveStars`
- `LottieFile.messagePermission`
- `LottieFile.loading`
- `LottieView(lottieFile:loopMode:)`

Rules:
- Use the provided `Image` and `LottieFile` helpers rather than repeating raw asset names in features.

## Special-Purpose UIKit Bridge

File:
- `Modules/Sources/DesignSystem/FirstResponderField.swift`

Use:
- `FirstResponderFieldView` provides a UIKit-backed first-responder text field, defaulting to `.numberPad`.
- The non-UIKit fallback is intentionally empty.

Use this only when SwiftUI focus handling is insufficient and immediate first-responder behavior is required.

## Extension Guidance

- Add new tokens in `Resources/` when they are truly shared and semantic.
- Add new `ButtonStyle`, `GroupBoxStyle`, or `ViewModifier` wrappers when multiple features need the same interaction or presentation.
- Add new reusable views only when the composition is stable enough to deserve a shared API.
- Keep feature-specific product copy and one-off layouts outside the DesignSystem.
- When unsure whether something belongs here, first try composing existing DesignSystem pieces in the feature.
