# iOS localization

The [Localization module](../../ios-app/Modules/Sources/Localization) owns editable Danish (`da`) and English (`en`) copy and locale-aware formatting. Danish is the development language. Foundation matches native app/device language preferences through `Bundle.module.preferredLocalizations`; there is no custom language registry or in-app picker. Saved user content is never retranslated.

## Ownership and access

- Edit `Resources/AppStrings.xcstrings` in the module. XCStrings Tool, configured by [Package.swift](../../ios-app/Modules/Package.swift) and the module's `xcstrings-tool-config.json`, generates public accessors during the build. Generated Swift remains in build intermediates.
- Use `String(appStrings:)`, `LocalizedStringResource(appStrings:)`, or `Text(appStrings:)`. For example, `String(appStrings: .commonSave)` and `String(appStrings: .activitySessionCount(2))`. Pass resolved strings to TCA `TextState`; do not reinterpret them as keys.
- `L10n.locale` selects formatting language; `RootFeatureView` supplies the SwiftUI locale. `L10n.Format` owns date, interval, relative-time, duration, decimal, and percent formatting, preserving the user's time zone. Percent input is a ratio; duration input is whole minutes. Tests supply explicit time zones/reference dates.
- Localization depends on Foundation and its build plugin, not Domain, Utility, DesignSystem, or features. Reducers retain dependency ownership; localization adds no view dependencies.

## Adding a string

1. Add a dot-separated semantic key with lower-camel-case segments and a translator comment explaining context, units, argument order, and verbatim user content. Supply complete Danish and English sentences.
2. Define count-sensitive `one`/`other` plural forms. Use numeric counts, not preformatted strings. Multiple numeric substitutions need explicit `argNum` and `formatSpecifier`; inspect an existing catalog example such as `insights.comparison`.
3. Build through native Xcode to generate the accessor and inspect its signature. `%lld` represents `Int`, `%@` represents `String`, and `%%` represents a percent sign. Positional arguments permit translated order. Never add a handwritten key enum or accessor registry.
4. Use the accessor, test grammar/arguments and changed layouts in both languages, then run the checks below. Keep keys and logic independent: use stable enum/ID values rather than translated headings.

Translate app-owned presentation, retained debug labels, accessibility descriptions, errors, and complete share/support messages. Technical logs, IDs, URLs, brands, preview/fixture identifiers, empty field values, numeric scale endpoints, and user data remain verbatim. Template defaults are translated before copying into editable user questions; later language changes must not rewrite saved questions.

System/provider interfaces own their own wording: Apple/Google sign-in, permission dialogs, share destinations, native Mail chrome, Settings, and hosted pages. Localize the labels/messages supplied by LetsGrow and verify actual provider behavior when relevant. Native date controls receive the selected app locale. Product contact never automatically opens an external mail app; follow the [contact flow](../shared/product-contact.md).

## Terminology

Follow [product language](agents/product-language.md) for strategy and migration scope. Current technical `Activity`/`Event` names remain unchanged unless the task includes their migration. Existing Danish UI uses aktivitet, session (never technical `Event`), mødeejer, deltager, spørgsmål, feedbackskabelon, and feedbacksvar for counted responses. Use sentence case and concise actions; preserve PIN leading zeros, names, questions, comments, calendar text, and URLs verbatim.

## Notification and system-string packaging

Edit module-owned `AppBundleResources/Localizable.xcstrings`. The main-app `Resources/Localizable.xcstrings` is a relative symlink to it, compiled into the main app's `Localizable` table by Xcode. Preserve the link and the package exclusion of AppBundleResources; APNs cannot read the package-only AppStrings table.

The backend sends `notification_feedback_received_title` and `notification_feedback_received_body`. Body arguments are **strings, count then session title** (`%1$@` / `%2$@`). Preserve all existing payload keys, including legacy keys for queued/external compatibility. Use count-neutral notification wording rather than changing this contract to numeric plurals. The [Firebase sender](../../backend/lib/firebase/src/main/kotlin/dk/example/feedback/firebase/FirebaseServiceImpl.kt) owns outgoing keys and argument order.

After a native build, validate compiled resources as well as catalogs:

```sh
python3 scripts/ios/validate-localization.py
python3 scripts/ios/validate-localization.py --app-bundle /absolute/path/to/App.app
```

Run from the monorepo root. The optional bundle check verifies packaged translations and development language. The native authorization dialog is system-owned; it has no app-owned purpose-string key. See [notifications](NOTIFICATIONS.md) for delivery tests.

## Error presentation

Use `AlertState(error:)` or `error.localized`. [Domain error mapping](../../ios-app/Modules/Sources/Domain/Error+Extension.swift) prefers complete backend `userTitle`/`userMessage` pairs, then localized domain/network/local compatibility mappings. The [API error-copy contract](../shared/api-error-copy.md) owns backend copy and language negotiation. Diagnostic API messages, NSError descriptions, and `localizedDescription` are not production copy. Keep SDK normalization in Adapters and sign-in cancellation silent.

## Verification

From the monorepo root:

```sh
python3 scripts/ios/validate-localization.py
python3 scripts/ios/check-unlocalized-copy.py
```

The copy guard detects direct literal presentation APIs with narrow file/value/count exceptions; it does not parse all Swift or follow indirect/custom-component values. Review those values and interpolation manually. Catalog/formatting behavior tests live in [LocalizationTests](../../ios-app/Modules/Tests/AppTests/UnitTests/LocalizationTests.swift) and [DateTests](../../ios-app/Modules/Tests/AppTests/UnitTests/DateTests.swift); run through `Feedback Localhost` / `UnitTests`.

Use the [screenshot workflow](../../.agents/skills/lg-ios-capture-screenshots/SKILL.md) for fresh Danish/English layout evidence. UnitTests and ScreenSnapshots select Danish/Denmark by default; temporarily select English/US for English captures, then restore the default. Adding a language requires both catalogs, package/app/screenshot-host configuration, native matching tests, and layout checks.

Simulator notification injection verifies text and session navigation, not FCM/APNs transport or physical-device provisioning. Provider UI, full owner/anonymous journeys in both languages, and physical-device/production delivery need their own evidence. Historical migration runs do not establish that those checks pass on the current checkout.
