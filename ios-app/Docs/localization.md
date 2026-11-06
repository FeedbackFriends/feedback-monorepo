# iOS localization

The localization migration is complete. App-owned copy, errors, formatting, and notification resources use the Localization module with Danish and English translations. The migration task was closed on 2026-11-06 at the user's request; remaining manual acceptance is the user's testing, with new problems captured as separate tasks. This does not claim those manual checks passed.

## Supported languages

Danish (`da`) is the catalog source and app development language; English (`en`) is also supported. The current catalogs contain 307 app entries and six notification entries, translated in both languages. Native device/app language preferences select the language; there is no in-app language picker. Saved user content is never retranslated.

Foundation owns language matching and fallback. `L10n.locale` follows `Bundle.module.preferredLocalizations` for app-owned formatting and the SwiftUI environment. `String(appStrings:locale:)` resolves through the resource bundle; its optional locale controls formatting. For an explicit test language, create `LocalizedStringResource(appStrings:)`, set its `locale` to `en_US` or `da_DK`, then call `String(localized:)`. Do not assume an unsupported explicit resource locale always selects Danish when English is available.

UnitTests and ScreenSnapshots explicitly select Danish/Denmark for deterministic regression expectations. The screenshot host supports both languages and follows `L10n.locale`. To capture English, temporarily select English/US in ScreenSnapshots, then restore Danish/Denmark. Follow the [screenshot workflow](../.agents/skills/lg-ios-screenshots/SKILL.md) for capture and review; preserved capture batches under `screenshots/english-capture/` and `screenshots/danish-capture/` are historical artifacts, not fresh verification.

## Resources and access

The independent `Modules/Sources/Localization` target owns editable translations and formatting. `Resources/AppStrings.xcstrings` is processed by [Package.swift](../Modules/Package.swift), which declares Danish as the default localization. There is no custom language enum, registry, or manual `.lproj` lookup.

XCStrings Tool's binary build plugin is pinned to 1.2.0. The module's `xcstrings-tool-config.json` configures public access and Danish development language. Xcode's native generated symbols were insufficient for ordinary cross-module access, so the build plugin generates the public interface used by features. All handwritten accessors and the duplicate key registry have been removed.

Generated `AppStrings.swift` lives in DerivedData's build-tool-plugin intermediates. Do not edit or check it in. Enable the plugin in Xcode when prompted. `L10n.swift` owns native locale selection; `LocalizedFormat.swift` owns formatting.

```swift
import Localization

let saveTitle = String(appStrings: .commonSave)
let sessions = String(appStrings: .activitySessionCount(2))
let progress = String(appStrings: .feedbackQuestionProgress(1, 3))
let message = String(appStrings: .sessionInviteMessage(title, pinCode, link))
let score = L10n.Format.number(4.5)
```

Resolved strings can be passed to SwiftUI `Text` or TCA `TextState`. `RootFeatureView` supplies the selected locale to its SwiftUI tree and presentations. App-owned support paragraphs and retained debug controls use the catalog; user content, sample data, technical diagnostics, brands, and identifiers remain explicit exceptions under the [localization conventions](../../docs/ios-localization-conventions.md).

## Adding a string

1. Add a semantic key and translator comment to `AppStrings.xcstrings`, with Danish and English values. Count-sensitive copy uses `variations.plural` with `one` and `other` forms. For multiple numeric arguments, use explicit substitutions with `argNum` and `formatSpecifier` to identify the plural-driving argument; see `insights.comparison`.
2. Build in Xcode. XCStrings Tool generates public `String.AppStrings` properties/functions. Dotted keys become camel-case members (`common.save` → `.commonSave`); inspect generated signatures for named parameters such as `.insightsComparison(sessions: count, responses)`.
3. Use `%lld` for `Int`, `%@` for `String`, and `%%` for a literal percent sign. Positional arguments (`%1$lld`, `%2$@`) allow translated order. Use `L10n.Format` for other numeric/date values before passing string arguments when needed.
4. Use `String(appStrings:)`, `LocalizedStringResource(appStrings:)`, or `Text(appStrings:)`. Add behavior tests for grammar and parameter-sensitive behavior; there are no handwritten declarations to synchronize.
5. From the repository root, run `python3 ios-app/scripts/validate-localization.py` and `python3 ios-app/scripts/check-localized-copy.py`. The compiler validates generated consumer signatures; the catalog validator checks translations, comments, plural branches, substitutions, and argument signatures.

The copy guard rejects direct literal prose in common presentation APIs, including `Text(verbatim:)`, control titles, help, and accessibility values. Its brand/preview exceptions are file/value/count specific; stale exceptions fail. It does not parse Swift or follow indirect/custom-component values, so review those and complex interpolation when changing copy. New app-owned prose belongs in the catalog rather than the exception list.

Regression commands:

```sh
python3 -m unittest discover -s ios-app/scripts/tests -p test_validate_localization.py
python3 -m unittest discover -s ios-app/scripts/tests -p test_localized_copy.py
```

Runtime resource/formatting coverage lives in [LocalizationTests.swift](../Modules/Tests/AppTests/UnitTests/LocalizationTests.swift) and `GeneratedLocalizationTests` in [DateTests.swift](../Modules/Tests/AppTests/UnitTests/DateTests.swift). Run through native Xcode with `Feedback Localhost` / `UnitTests`.

## Adding a language later

Translate every key in both catalogs and declare the language in app localization configuration. Keep package, app, and screenshot-host supported languages aligned. Foundation selects supported languages natively; no language enum or feature-code changes are required. Add regional-matching, plural, resource-lookup, and layout tests for the new language.

## Notification and system-string packaging

Editable notification text lives in `Modules/Sources/Localization/AppBundleResources/Localizable.xcstrings`. Main-app `Resources/Localizable.xcstrings` is a relative symbolic link to that catalog. Edit the module-owned source and preserve the link. `Package.swift` excludes AppBundleResources from the package target because APNs looks in the main app's `Localizable` table. The native Xcode resource phase compiles the linked catalog into the app's Danish and English resource tables; no custom copy script or second editable catalog is needed.

All six payload keys remain. The current backend sends `notification_feedback_received_title` and `notification_feedback_received_body` with two string arguments: count, then session title. The four legacy start-feedback/team-invitation keys remain for queued/external compatibility. Preserve string argument types/order, leading-zero identifiers, user titles, and percent signs; APNs keys must not point at the package-only AppStrings table.

The Danish body uses `feedbacksvar` to agree with all counts. The English body is count-neutral: `New feedback for ‘…’ · Responses: …`. The project declares `developmentRegion = da` and supports Danish/English. That configuration fixes the earlier raw-key fallback defect.

Validate the source catalogs and, after a native build, the actual bundled notification resources:

```sh
python3 ios-app/scripts/validate-localization.py
python3 ios-app/scripts/validate-localization.py --app-bundle /absolute/path/to/App.app
```

The validator checks 313 keys, language agreement, the APNs signature, single-source resource link, and compiled values/development language. `--catalog /path/to/catalog.xcstrings` validates one catalog. There is no app-owned notification purpose-string key; the authorization dialog's wording belongs to the system.

The [notification E2E runner](../.maestro/notifications/README.md) uses the real local backend, existing manager login, normal app startup, and real temporary activities/sessions. It verifies English notification text and session navigation, then deletes its own activity. Existing data is preserved; only explicit `--seed-manager` replaces the sample manager. There are no offline app fixtures or substituted notification dependency clients. Owner startup requests permission through the live NotificationClient; anonymous users are not prompted.

The runner validates the built bundle before injection. It tests foreground/background/terminated scenarios on an isolated simulator. Foreground verification checks the persistent Notification Center entry rather than transient banner timing. Simulator injection does not verify FCM/APNs network transport or physical-device provisioning. Hosted CI covers unit/reducer/catalog/compiled-resource checks; backend-dependent delivery runs explicitly in the local E2E environment.

## Error presentation

Use `AlertState(error:)` or `error.localized`. [Domain/Error+Extension.swift](../Modules/Sources/Domain/Error+Extension.swift) prefers complete backend `userTitle`/`userMessage` pairs for API failures, then maps known domain/network/local failures to generated resource accessors. The [API error-copy contract](../../docs/api-error-copy.md) defines backend business-copy ownership and compatibility. Arbitrary NSError/API diagnostic descriptions remain diagnostics. Add local resources for client-owned failures and compatibility mappings; keep SDK-specific normalization in Adapters and preserve silent user-cancelled sign-in behavior.

`APIErrorMiddleware` preserves HTTP failures before generated success accessors discard status. It reads at most 1 MiB of an error body, decodes existing DTOs for known domain codes, and uses safe HTTP presentation for malformed/unknown payloads. Successful responses pass through unchanged. `withAuthorization` unwraps generated ClientError values. Generated transport sources are not edited for localization.

## Formatting and section identity

`L10n.Format` centralizes dates, intervals, relative time, durations, counts, decimals, and percentages using the selected language and the user's time zone. Pass an explicit time zone/reference date in deterministic tests. `sessionDate(start:durationMinutes:timeZone:)` handles the existing 1440-minute all-day marker and native intervals across midnight. Percent formatting accepts ratios (`0.42` means 42 percent); duration input is whole minutes. Relative-time wording comes from Foundation's full-unit formatter.

Plural accessors receive numeric counts. Whole sentences retain independent count/title parameters. Templates are localized before becoming editable questions; saved questions are never rewritten on language changes. `EventListSection.SectionID` keeps navigation independent of translated headings.

## Completion and verification

Implementation is closed; no known localization implementation defect was identified in this closeout. The [source inventory](../../docs/ios-localization-inventory.md) records implementation ownership and exceptions. Historical migration experiments and phase logs remain in Git history rather than an open task.

Latest recorded native evidence from 2026-11-04: build-for-testing and 226 AppTests/InsightsTests cases passed. Danish and English catalog captures passed, including the recorded 56-screen English review. Real-backend count-99 notification text/navigation passed in foreground, background, and terminated states with cleanup; see the [delivery evidence](../.maestro/notifications/README.md#backend-dependent-verification). Earlier offline delivery runs are superseded. Counts 0/1/2 were not rerun against the replacement backend-dependent flow.

Closeout checks on 2026-11-06: all 313 catalog keys/signatures validate, the direct-copy guard passes across 215 Swift files, and all 70 Python tooling tests pass. Targeted literal/source inspection found reviewed preview, brand, numeric, user-data, and diagnostic cases rather than a new implementation issue. No Swift code changed, and no new native build, app interaction, screenshot capture, or delivery run is claimed.

Broader manual owner/anonymous journeys in both languages, device/provider UI, local/transient notification presentation, and physical-device/production push transport remain the user's testing. Accessibility verification was excluded by the user. These are coverage limits, not passing results or a retained task checklist; report newly found problems as new prefixed files in root `tasks/`.
