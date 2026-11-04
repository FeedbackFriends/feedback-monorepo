# iOS localization

## Supported languages

The iOS app now supports Danish (`da`) and English (`en`) using native device/app language preferences. Danish remains the catalog source and development language. All 307 app entries and six notification entries have both translations. The generated Swift interface and feature call sites are shared across languages; no in-app language picker is needed. Saved user content is never retranslated.

`String(appStrings:locale:)` resolves the bundle-selected language; its optional locale controls formatting. For an explicit language in a test, create `LocalizedStringResource(appStrings:)`, set its `locale` to `en_US` or `da_DK`, then call `String(localized:)`. Native preference matching and fallback remain Foundation-owned; do not assume an unsupported explicit resource locale always selects Danish when English is also available.

The UnitTests and ScreenSnapshots plans explicitly select Danish/Denmark to keep existing regression expectations deterministic. English runtime cases exercise generated resources, counts 0/1/2/99, complex substitutions, invitations, errors and templates. The separate screenshot host declares both supported languages and its rendering environment follows `L10n.locale`. Temporarily selecting English/US in the ScreenSnapshots plan produces English captures; restore Danish/Denmark afterward. The final English gallery is `screenshots/index.html`; English and Danish capture batches are retained under `screenshots/english-capture/` and `screenshots/danish-capture/`.

The notification runner already launches with English preferences. Its delivery assertions now expect the English title and count-neutral body (`New feedback for ‘…’ · Responses: …`). This preserves both existing string arguments and grammatical wording for every count. Earlier Danish-only offline delivery evidence below is historical; current backend-dependent English verification is recorded in the review follow-up. Built app resources for both languages pass validation.

The independent `Localization` Swift package target owns editable translations, typed presentation strings, language selection, and locale-aware formatting. Its initial development language is Danish (`da`). Foundation selects a supported localization from the bundled String Catalog resources using native app/device language preferences; unsupported preferences use Danish. Formatting helpers use that selected language locale. No global user defaults or device language settings are modified.

## Resources and access

Editable text lives in `Modules/Sources/Localization/Resources/AppStrings.xcstrings`, with Danish as the source language. `Modules/Package.swift` processes these resources and declares Danish as the default localization. XCStrings Tool generates public accessors that look up text in `Bundle.module`; Foundation performs native localization selection and development-language fallback. There is no custom language enum, registry, or manual `.lproj` lookup. `L10n.locale` follows the bundle’s `preferredLocalizations` for app-owned formatting and the SwiftUI locale.

Use the generated interface from views, reducers, and presentation helpers:

```swift
import Localization

let saveTitle = String(appStrings: .commonSave)
let sessions = String(appStrings: .activitySessionCount(2))
let progress = String(appStrings: .feedbackQuestionProgress(1, 3))
let message = String(appStrings: .sessionInviteMessage(title, pinCode, link))
let score = L10n.Format.number(4.5)
```

Resolved strings can be passed directly to SwiftUI `Text` or TCA `TextState`. User content and identifiers stay verbatim. Format dates/intervals using the user's time zone by default; pass an explicit time zone for deterministic tests. Percent formatting accepts a ratio (`0.42` means 42 percent), and durations accept whole minutes. Relative time uses numeric full units to avoid the current Foundation spelled-out Danish output `for et time siden`.

`RootFeatureView` provides the selected locale to its SwiftUI tree, including presentations. Error presentation and the remaining copy/formatting call sites are migrated in Phases 3–4. App-owned text, including support paragraphs and retained debug controls, uses the catalog; technical dumps, sample/user data, brands and identifiers remain explicit exceptions. Notification packaging/delivery and final runtime acceptance remain in Phases 5–6.

## Adding a string

1. Add a semantic resource key and translator comment to `AppStrings.xcstrings`. Supply translated Danish and English values. Use `variations.plural` with `one` and `other` forms for count-sensitive copy. If multiple numeric arguments appear in a plural, use explicit substitutions with `argNum` and `formatSpecifier` so the plural-driving argument is unambiguous; see `insights.comparison`.
2. Build in Xcode. The pinned XCStrings Tool plugin generates the public `String.AppStrings` properties/functions automatically. Dotted keys become camel-case members (e.g. `common.save` → `.commonSave`). Inspect code completion for the signature; substitutions produce named arguments such as `.insightsComparison(sessions: count, responses)`.
3. Use `%lld` for `Int`, `%@` for `String`, and `%%` for a literal percent sign. Multiple arguments use positional placeholders such as `%1$lld` and `%2$@`; translations may reorder them. Format other numeric/date types with `L10n.Format` before passing string arguments where needed.
4. Use `String(appStrings: .commonSave)` for resolved strings, `LocalizedStringResource(appStrings: .commonSave)` for resources, or `Text(appStrings: .commonSave)` in SwiftUI. Add behavior tests for new grammar or parameter-sensitive behavior. There are no handwritten key declarations or accessor files to update.
5. Run `python3 ios-app/scripts/validate-localization.py` from the repository root. It validates translated values, translator comments, plural branches, explicit substitutions and matching argument signatures across languages. Danish source signatures come directly from the catalog; the Xcode generator/compiler validates consumer names and argument types.

Validator regression checks: `python3 -m unittest discover -s ios-app/scripts/tests -p test_validate_localization.py`. Runtime coverage lives in `LocalizationTests.swift` and `GeneratedLocalizationTests` (in the existing `DateTests.swift` source). Run it through native Xcode with `Feedback Localhost` and `UnitTests`.

Run `python3 ios-app/scripts/check-localized-copy.py` before adding UI copy. CI also runs this guard. It rejects direct literal prose in common presentation APIs, including `Text(verbatim:)`, control titles, help and accessibility values. Brand/preview exceptions in the script are file/value/count specific; removed or unused exceptions fail too. Regression checks: `python3 -m unittest discover -s ios-app/scripts/tests -p test_localized_copy.py`. The guard does not parse Swift or follow indirect values/custom-component parameters; review those call sites and complex interpolation manually. New app-owned prose belongs in the catalog rather than in the exception list.

The build-tool plugin is pinned in `Modules/Package.swift` and uses `xcstrings-tool-config.json` beside the Localization sources (`public` access, `da` development language). New developers must enable the plugin in Xcode when prompted. Generated `AppStrings.swift` lives only in DerivedData's build-tool-plugin intermediates and must not be checked in or edited. `L10n.swift` now owns only native locale selection; `LocalizedFormat.swift` owns the shared formatting helpers.

## Adding a language later

Add its translations for every key in the Xcode String Catalog and declare that language in the app’s localization configuration during rollout. Keep the module and main-app supported localizations aligned, including notification resources. Foundation selects supported languages natively; no Swift enum or language-registration code changes are required. Add tests for regional matching, plural grammar, and resource lookup. Feature code continues to use the generated interface; no extra key registry is maintained.

## Notification and system-string packaging

Current E2E setup uses the real local backend and the existing local manager login. The offline `NotificationTestLaunch` entry point, dependency substitutions and cache/status-file protocol have been removed. The runner creates real activities/sessions, verifies bootstrap persistence, injects the existing APNs payload with the real session ID, checks notification text/tap navigation, and deletes its own activity after each case. Backend volumes and existing sample data are preserved; only explicit `--seed-manager` replaces the sample manager fixture. Normal owner startup now handles the existing notification-permission delegate action through the live authorization client. Hosted iOS CI retains unit/resource checks; these E2E cases run explicitly with a configured local backend. See the [current notification guide](../.maestro/notifications/README.md). Earlier offline setup/results below are historical and superseded.


Notification translations now live in `Modules/Sources/Localization/AppBundleResources/Localizable.xcstrings`. The existing main-app `Resources/Localizable.xcstrings` path is a relative symbolic link to that file. Edit the real module-owned file; do not replace the link with another editable copy. `Package.swift` excludes `AppBundleResources` from the package target because APNs requires the main app's `Localizable` table. The normal Xcode resource phase compiles the linked catalog into `da.lproj/Localizable.strings` in the app bundle. Native compilation declares/computes its resource inputs and outputs; no custom copy/generation script or checked-in generated `.strings` file is needed.

All six existing payload keys remain. The repository's backend currently sends only `notification_feedback_received_title` and `notification_feedback_received_body`, with **two string arguments, count then session title**. Legacy start-feedback/team-invitation keys have no current repository sender but remain for external/queued payload compatibility. The feedback body is `Du har modtaget %1$@ feedbacksvar på ‘%2$@’.`; `feedbacksvar` agrees with both singular and plural counts without changing the server's string argument into a numeric plural. The title is `Ny feedback 🔥`. User titles and percent signs remain verbatim.

The project declares Danish (`da`) as its development region, with Danish and English supported in `Feedback.xcodeproj/project.pbxproj`. This fixes the earlier English fallback that returned raw notification keys. No manual Xcode configuration is required. The notification runner validates the compiled bundle before installing or injecting payloads, so an incorrect fallback or missing translations fail setup automatically. Delivery acceptance remains tracked in Phase 5.

`python3 ios-app/scripts/validate-localization.py` now checks both catalogs (313 keys), supported-language agreement, the APNs argument contract, and the resource link. To check a native Xcode build, run:

```sh
python3 ios-app/scripts/validate-localization.py --app-bundle /absolute/path/to/App.app
```

This checks the built fallback language, all compiled notification values, and unexpected stale language tables. The rebuilt app passes this check with Danish development metadata. `--catalog /path/to/catalog.xcstrings` validates a single catalog independently. The main app plist contains no permission usage-description prose to extract. The notification permission alert has system-owned wording, with no custom purpose-string key.

Notification regression setup (2026-11-04): `NotificationTests` in `InsightsTests`
loads a complete APNs fixture and exercises the production notification tap action
for cold/warm reducer states, bootstrap refresh, deleted sessions and malformed
payloads. Native build and all **216 iOS runtime cases passed**; **20 Python
validator cases passed**. `python3 ios-app/scripts/lint-swift-changes.py --base HEAD`
reported zero violations in 96 files. CI now validates both source catalogs and
the built main-app notification table; the latter currently fails on the known
English development region. This is an active failure, not an ignored check.

The [automated notification runner](../.maestro/notifications/README.md) replaces
manual push preparation. `python3 ios-app/scripts/test-notifications.py` builds
the Localhost app, creates an isolated simulator, configures an offline owner and
session in debug-only fixture mode, handles system permission, injects the
localized APNs payload using `simctl push`, and runs Maestro text/tap assertions
for background and terminated app states. It removes the fixture and its own
simulator afterward. No backend, login or manual session ID is required. CI runs
counts 0/1/2/99 and publishes logs, payloads, screenshots and JSON results.

With an app built through native Xcode, the automated iOS 26.5 run completed
permission and push preparation in both states. Notification Center screenshots
and hierarchy confirmed raw title/body keys; Danish title assertions failed in
both cases. These are real acceptance failures, not skipped checks. The local
Maestro 2.5.1 driver timed out on the existing iOS 27 simulator, so the runner
prefers an isolated iOS 26 runtime when one is installed. Simulator injection does
not prove transport through FCM/APNs or production-device delivery. A temporary
literal-Danish control payload passed the complete text/tap/session flow in both
background and terminated states on iOS 26.5. That override was outside the
repository; the checked-in runner always uses the localized APNs fixture. The
control proves the harness can automate navigation, not that localization passes.

Verification on `Feedback Localhost` / `LetsGrow Manager` (iOS 27.2): native build-for-testing passed, **210 runtime tests passed** across AppTests and InsightsTests, **19 Python validator cases passed**, and changed-line SwiftLint reported zero violations in 95 files. The first suite-selected MCP response reported an unknown outcome; the subsequent full run provided complete passing results. The native build log confirms `CompileXCStrings` and `CopyStringsFile` produce the main-app Danish table and remove the old English table. Launch with `-AppleLanguages (en)` / `-AppleLocale en_US` succeeded, but native hierarchy inspection returned `Session not found`; cleanup reported that the session no longer existed. This establishes neither UI acceptance nor delivered notification behavior.

The development-language defect is fixed in the project file, and the rebuilt app passes the compiled-bundle checks. The final localized-payload matrix passed **8/8 cases**, exit status 0, on an isolated iOS 26.5 simulator: counts 0/1/2/99 in background and terminated states with English launch preferences, Danish title/body assertions and matching session navigation. The flow uses the system Open action when tapping selects a stacked notification card. Artifacts: `ios-app/.build/notification-tests-fallback-matrix/`. All 20 validator tests and 3 installation-startup retry tests passed. Delivery/tap acceptance is tracked in [Phase 5](../../docs/localization-phases.md#phase-5--migrate-notification-resources-and-verify-delivery). CLI injection is automated with explicit user authorization; foreground coverage and physical-device/production transport remain outstanding. Do not point APNs keys at the module-only `AppStrings` table.

## Error presentation

Use `AlertState(error:)` or `error.localized` for customer-facing failures. `Domain/Error+Extension.swift` maps explicit domain/network/local failure categories to generated `.errors…` accessors; arbitrary `NSError` and API descriptions are diagnostics only. Add a catalog key and explicit mapping for a new customer-facing failure rather than displaying `localizedDescription`. Keep SDK-specific normalization in Adapters.

The live app installs `APIErrorMiddleware` to preserve HTTP failures before generated success accessors discard status. It reads at most 1 MiB of an error body, decodes the existing generated DTO for known domain codes, and falls back to safe HTTP presentation for malformed/unknown payloads. Successful responses pass through unchanged. `withAuthorization` unwraps generated `ClientError` values; auth normalization uses actual SDK constants. User-cancelled sign-in keeps its existing silent reducer path. Do not edit generated API sources to add localization.

## Formatting and section identity

Use `L10n.Format.sessionDate(start:durationMinutes:timeZone:)` for session ranges, including the existing 1440-minute all-day marker; native intervals include both dates for sessions crossing midnight. `dayMonth`, `date`, `integer`, `number`, `percent`, `duration` and `relativeTime` centralize app language while preserving the user's time zone. Utility date helpers delegate to this policy; explicit-locale relative-time overrides remain available for independent tests.

Plural accessors take numeric counts. Whole notification-history sentences retain the count and user-supplied title as separate arguments, and singular/new-response wording is intentional. App-owned templates are localized before becoming editable question content; saved questions are not retranslated. `EventListSection.SectionID` supplies stable section identity so translated titles never drive navigation.

## Native generated-symbol experiment (2026-11-04, historical)

Xcode 27.2 already generates `GeneratedStringSymbols_AppStrings.swift` in DerivedSources for the Localization Swift package. No additional package, build plugin, compiler flag, or checked-in generated file was required. The generated code uses `Bundle.module` and extends `LocalizedStringResource` with an **internal** `AppStrings` namespace. Examples inside Localization (or a test using `@testable import Localization`):

```swift
String(localized: .AppStrings.commonSave)
String(localized: .AppStrings.activitySessionCount(2))
String(localized: .AppStrings.feedbackQuestionProgress(2, 5))
```

A temporary probe in the existing Domain `Role.swift` file attempted ordinary cross-module use with `import Localization`. Native compilation failed with both `'AppStrings' is inaccessible due to 'internal' protection level` and `'commonSave' is inaccessible due to 'internal' protection level`. The probe was removed and the file restored; the final build-for-testing passed.

The Localization suite now verifies native plain, parameterized and plural accessors, invitation parameter preservation, and an explicitly English `LocalizedStringResource` locale resolving to Danish through the package bundle. All **13 runtime cases passed** on `Feedback Localhost` / `LetsGrow Manager` (iOS 27.2). Changed-line SwiftLint reported zero violations; the existing 307-key catalog validator and `git diff --check` passed. No app behavior changed, so a new app launch or screenshot capture was not needed for this experiment.

**Decision:** native generation works inside the resource-owning target, but it cannot directly replace the public `L10n` interface used by other feature targets. Existing accessors remain unchanged. Their key enum and public declarations are still manually maintained. The generated-symbol tests intentionally use `@testable`; production targets must not use that to bypass access control. A catalog-driven generator such as XCStrings Tool is the next option to evaluate for an automatically generated public interface. That native-only experiment added no dependency; the subsequent XCStrings Tool trial below adds a build plugin.

## XCStrings Tool trial (2026-11-04, historical)

The `Localization` target uses `XCStringsToolPlugin` from the official binary-plugin package, pinned to **1.2.0** (revision `bebb29f791e92f6ee5d9b6200f89c45249149957`). This avoids introducing the generator's source-build SwiftSyntax dependency into the app's dependency graph. The module-local `xcstrings-tool-config.json` sets `accessLevel` to `public` and development language to `da`. The user enabled the plugin in Xcode; no permission automation or validation bypass was used.

Xcode now generates `AppStrings.swift` automatically under DerivedData's `BuildToolPluginIntermediates/modules.output/Localization/XCStringsToolPlugin/XCStringsTool/Generated/` directory. Do not edit or check in that file. Its public `String.AppStrings` type provides static properties and typed functions derived directly from the catalog:

```swift
import Localization

String(appStrings: .commonSave)
String(appStrings: .activitySessionCount(2))
String(appStrings: .feedbackQuestionProgress(2, 5))
LocalizedStringResource(appStrings: .commonSave)
// In SwiftUI:
Text(appStrings: .commonSave)
```

`Domain/Models/Role.swift` now uses `String(appStrings: .profileRoleOwner)` with an ordinary `import Localization`. Native build-for-testing compiled this production consumer successfully, proving public access across modules. `GeneratedLocalizationTests` in the existing `DateTests.swift` source also uses an ordinary import and passed **5 runtime cases**: plain/parameterized strings; plural counts 0, 1 and 2, including mixed count/title parameters; and Danish fallback for an explicitly English locale using both String and LocalizedStringResource. Invitation tests preserve `100%` and leading-zero PIN `0012` verbatim.

Verification used `Feedback Localhost` / `UnitTests` / `LetsGrow Manager` (iOS 27.2). Build passed; the 307-key localization validator passed; changed-line SwiftLint (`python3 ios-app/scripts/lint-swift-changes.py --base HEAD`) reported zero violations in 112 Swift files; `git diff --check` passed. The trial preserves rendered copy, so a separate launch/UI/screenshot run was not performed.

**Decision:** XCStrings Tool supplies the public, catalog-generated interface that native generated symbols could not expose across modules. The plugin stays configured and the Domain role is a first migrated consumer. The remaining handwritten `L10n` accessors and `LocalizationKey` enum are still present. Their removal requires migrating remaining callers and updating the validator and adding-string instructions above. Keep `L10n.Format` and the shared locale policy (these perform formatting rather than declare catalog keys).

Before broad migration, fix the pre-existing Xcode warning for `insights.comparison`: its plural has two numeric arguments and needs an explicit substitution to identify the plural-driving argument reliably. The successful representative trial does not certify every complex catalog entry. Notification packaging and final runtime acceptance remain in Phases 5–6.

## Completed accessor migration (2026-11-04)

All iOS consumers now use the public, catalog-generated interface. Removed all 307 handwritten accessors, the `LocalizationKey` registry, the raw printf lookup wrapper, and the `L10n+*.swift` files. `L10n.locale` / `L10n.Format` remain as the native locale and formatting policy. No app-owned translations or parameter ordering changed.

`insights.comparison` now explicitly substitutes the session count; the Xcode ambiguity warning is gone. Runtime coverage varies sessions across 0/1/2 and responses independently across 0/1/2/42 to verify plural selection and argument preservation. The catalog validator derives signatures from Danish catalog values and compares every translated language and plural branch, including substitutions. Xcode's generated API and compiler check the actual consumer signatures.

Verification: native build-for-testing passed on `Feedback Localhost` / `LetsGrow Manager` (iOS 27.2); all **210 AppTests/InsightsTests runtime cases passed**, with no failures or skips. All **12 validator regression tests** and validation of all **307 catalog keys** passed. Changed-line SwiftLint reported **zero violations in 95 Swift files**, and `git diff --check` passed. An ordinary native Xcode app launch also passed. This changes accessor implementation while preserving rendered copy/layout; a fresh interactive UI/screenshot review was not run. Notification packaging and final runtime acceptance remain in Phases 5–6.
