# iOS naming and forms

Paths are relative to `ios-app/` unless stated otherwise.

## Naming

- SwiftUI views must use the `View` suffix.
- The reducer associated with a view should use the same base name without `View`.

Examples:

| View | Reducer |
| --- | --- |
| `FocusListView` | `FocusList` |
| `SettingsView` | `Settings` |
| `ProfileView` | `Profile` |

## Form Validation

- Disable Continue/Next/Create/Save actions until all required inputs are valid, and while submission is in flight.
- Do not enable invalid form actions just to show missing-field errors after tapping. Mark required fields clearly and preserve optional fields as optional.
- Apply the same validation guard in reducers or submission handlers so keyboard/programmatic actions cannot bypass it. Keep API and network error reporting.

## Reusable UI

Use the shared `DesignSystem` components before adding local styling:

- `.surfaceCard(padding:)` owns card padding, surface color, rounded clipping, and hit shape. Apply it to the content inside a button; keep navigation and actions in the feature.
- `PillTagView` owns metadata pills and status badges. Use `.metadata` for labels and counts, `.badge` for unread counts, and `.compactBadge` for compact new-status labels. Its content builder supports labels with icons.
- `CircleIconView` owns resizable icons with circular backgrounds. Features supply the image and semantic colors.
- `ContentSectionView` groups a section header, optional trailing action, and vertically stacked content.
- `PinCodeTextFieldView` owns PIN entry appearance, number keyboard, focus binding, and input validation. Features own submission, request state, and focus synchronization.
- Use `.successMessage(_:isPresented:)` for transient success confirmations. It presents the shared `SuccessMessageView` as a glass overlay at the top of the content, below navigation controls. Features own visibility, timers, and navigation; the component never dismisses a screen or dims its background.

Keep domain-aware compositions such as `FeedbackTypeTagView` and session cards in their feature. Compose them from shared primitives rather than duplicating their visual styling. SwiftUI `Form`, `Section`, `Label`, and `ContentUnavailableView` remain suitable native building blocks.

For activity/session mutations, the destination owns `SuccessConfirmation`. Queue the message when navigating, then start its timer from completed navigation (`onNavigationTransitionCompleted`) or sheet `onDismiss`. Close delete confirmation sheets before delegating navigation. Chain sheet dismissal and navigation through callbacks, never fixed sleeps.
