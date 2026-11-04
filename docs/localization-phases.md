# Danish localization: iOS implementation phases

Status: Phases 1–4 implemented; Phase 5 in progress (Danish fallback and background/terminated delivery verified; foreground acceptance outstanding; user reports physical-device Danish verification complete); Phase 6 in progress (catalog validation and source-copy guard verified; runtime acceptance outstanding). Phase 4 live UI acceptance remains in Phase 6. Scope confirmed: iOS app only. Updated: 2026-11-04.

Source inventory and design: [iOS localization audit and migration plan](localization-plan.md).

## Objective and boundaries

Make every LetsGrow-owned user-visible iOS string Danish and move all translations—including existing Danish text—into the existing `ios-app/Modules/Sources/Localization` module. Prepare the module for additional languages while shipping Danish initially.

Include UI, reducer alerts, validation, errors, accessibility, share/invite text, app-owned question templates, local/push notification resources, and date/number formatting. Preserve user-authored content, brand names, URLs, identifiers, and technical diagnostics.

Web and backend implementation, the hosted privacy policy, server email templates, API schemas, and generated API client changes are outside this task. Localize API failures within iOS using the existing contract. The app-owned privacy-policy link label is included.

## Progress

- [x] Phase 1: Finalize iOS inventory and conventions
- [x] Phase 2: Establish the Localization module
- [x] Phase 3: Replace iOS error presentation
- [x] Phase 4: Migrate all iOS copy and formatting
- [ ] Phase 5: Migrate notification resources and verify delivery
- [ ] Phase 6: Complete iOS verification and regression checks

## Phase 1 — Finalize iOS inventory and conventions

**Depends on:** nothing.

- [x] Refresh the iOS findings in the source audit against the current codebase.
- [x] Include all hardcoded Danish text as well as English text.
- [x] Check App, feature views, reducers, model presentation helpers, DesignSystem, default templates, share/invite text, accessibility, and resources/images.
- [x] Track findings as pending, migrated, obsolete, development-only, or externally owned; verify reachability before deleting old helpers.
- [x] Establish plain Danish terminology: aktivitet, session, feedback, and PIN-kode, with other terms added where needed.
- [x] Define semantic keys, namespaces, typed parameters, and plural conventions.
- [x] Define Danish as the initial/default language, including for unsupported device preferences; defer the language picker.
- [x] Identify system/identity-provider-owned UI and available locale controls.

**Complete when:** the iOS inventory and localization conventions are ready for implementation. The iOS-only scope is already confirmed.

**Deliverables:** [Refreshed inventory](ios-localization-inventory.md) and [localization conventions](ios-localization-conventions.md). The static audit covers 212 repo-owned Swift files plus resources/configuration. Runtime, asset visual QA, and push delivery remain assigned to later phases. No app code was changed in Phase 1.

## Phase 2 — Establish the Localization module

**Depends on:** Phase 1.

- [x] Populate `ios-app/Modules/Sources/Localization` with Danish string catalogs/resources and a typed public interface.
- [x] Configure Swift package resources, default localization, and explicit consumer dependencies.
- [x] Ensure lookups use the correct resource bundle and the runtime app locale is consistent. Coordinate main-app development-language metadata with notification migration in Phase 5.
- [x] Keep Localization independent of modules that consume it to avoid dependency cycles.
- [x] Use native String Catalog / Bundle.module language selection and centralize formatting for dates, intervals, relative time, durations, counts, and decimals.
- [x] Support complete parameterized sentences and plural forms.
- [x] Establish validation for missing keys and mismatched placeholders.
- [x] Define how notification and any required system-string resources reach the main app bundle from the module-owned source without duplicate editable translations.

**Complete when:** representative plain, parameterized, and plural messages resolve in Danish through the module on an English-configured device.

**Deliverables:** Foundation-only Localization target with Danish catalog, eight typed accessors, native bundle language selection and formatting helpers, consumer dependencies, and root SwiftUI locale. Usage and notification packaging are documented in [iOS localization](../ios-app/Docs/localization.md). Main-app notification catalog and development-region migration remain together in Phase 5; the runtime/module policy is Danish now.

**Validation (2026-11-04):** native Xcode build-for-testing passed on `Feedback Localhost` / `LetsGrow Manager` (iOS 27.2). Full unit run: 191 passed, one new relative-time wording assertion failed; corrected the formatter and reran all nine localization cases successfully. Catalog validation and eight Python validator tests passed. Changed-line SwiftLint: zero violations. English-preference app launch succeeded. UI inspection was inconclusive: native Xcode reported the interaction session missing, then reported that the same session still owned the simulator; closing it also reported it no longer existed. No alternate simulator tooling was used.

**Native localization revision (2026-11-04):** removed the custom language enum and manual language-bundle lookup. String lookup now uses `Bundle.module`, with native `preferredLocalizations` supplying the formatting/SwiftUI locale. Adding languages requires catalog translations and app configuration rather than Swift registration. All nine localization cases passed again; catalog validation and changed-line SwiftLint passed. Native Xcode rebuilt and launched the app successfully after this revision; no renewed UI-inspection claim is made.

## Phase 3 — Replace iOS error presentation

**Depends on:** Phase 2.

- [x] Replace presentation in `Domain/Error+Extension.swift` with explicit localized mappings.
- [x] Cover all six existing domain error codes using the existing API contract.
- [x] Map available HTTP failures, offline/timeouts, auth SDK codes, and known local/cache/invitation failures to localization keys.
- [x] Use a safe Danish generic message for unknown errors, unknown codes, or malformed responses.
- [x] Prevent raw API messages, `URLError.localizedDescription`, and NSError descriptions from becoming customer copy.
- [x] Ensure arbitrary NSError text cannot overwrite mapped messages.
- [x] Preserve diagnostics in logs and appropriate cancellation/retry behavior.
- [x] Localize error titles, retry actions, logout actions, and alert buttons; remove inappropriate error-title decoration.
- [x] Update `PresentableErrorTests` and relevant adapter/reducer tests to verify intentional Danish presentation, including English diagnostic input.

**Complete when:** all app error surfaces display deliberate Danish messages without requiring backend or API schema changes.

**Delivered (2026-11-04):** 34 additional module-owned strings (42 typed keys total). Explicit Danish mappings cover six domain codes, offline/timeouts/connection/authentication failures, HTTP 401/403/404/408/409/429/5xx, cache mutation, missing session IDs and invitation links. Known domain codes take priority over HTTP status. Unknown codes, malformed payloads and arbitrary NSError descriptions cannot supply user copy. `APIErrorMiddleware` preserves HTTP status and decodes existing generated error DTOs before success-only accessors lose response details; adapters unwrap OpenAPI errors and normalize Firebase/Apple/Google SDK failures. Generated sources and backend contracts are unchanged. Cancellation types and silent Apple/Google cancellation behavior are preserved. Shared alert/retry/logout actions, refresh failure and account-deletion logout failure use Localization; remaining confirmation/success copy stays in Phase 4.

**Validation:** Native build-for-testing passed on `Feedback Localhost` / `LetsGrow Manager` (iOS 27.2). Full unit run: 196 passed, two failures (an old English logout assertion and an incorrectly cased new wire-value fixture); both fixed, then affected adapter/deletion suites passed 10/10. A final adapter suite rerun passed 6/6 after preserving body-read cancellation. Presentable-error, sign-in cancellation, cache and remaining regression cases passed in the full run. Catalog validation and eight Python validator tests passed. `python3 ios-app/scripts/lint-swift-changes.py --base HEAD`: zero changed-line violations in 27 Swift files; `git diff --check` passed. Native ordinary build/launch succeeded. UI inspection remains unavailable: `DeviceInteractionStartWorkspaceSession` returned a key, but InstallAndRun reported the session did not exist; closing it also reported it no longer existed. Consequently the attempted English-argument launch was not performed; the successful ordinary launch does not certify English-preference UI. Manual journey, screenshots and runtime error-surface checks remain in Phase 6.

## Phase 4 — Migrate all iOS copy and formatting

**Depends on:** Phases 2 and 3.

- [x] Extract sign-in, profile, settings, account deletion, and notification-permission copy.
- [x] Extract activity/session management, participant feedback, insights, invitations, and share content.
- [x] Extract reusable component labels, reducer alerts, empty states, banners, confirmations, and validation.
- [x] Extract accessibility labels/hints and chart descriptions, plus app-owned template/default text.
- [x] Translate remaining English labels such as `New`, `Time`, `All day`, and duration wording.
- [x] Replace presentation strings in model helpers with localization-backed presentation code where appropriate.
- [x] Apply the centralized language/formatting policy to all date, relative-time, duration, count, and decimal presentations.
- [x] Preserve the user's time zone and all user-authored content.
- [x] Localize app-owned external-link labels; keep destination pages outside the migration.
- [x] Inspect assets for embedded English and replace app-owned assets where needed.
- [x] Classify development-only controls explicitly; extract retained visible app labels and use Danish sample content in customer-facing screenshots.
- [x] Verify affected features through the documented iOS test/build and screenshot workflows.

**Complete when:** all app-owned iOS production prose uses Localization and the app remains Danish with English device preferences.

**Delivered (2026-11-04):** 265 additional catalog entries (307 typed keys total), originally with handwritten namespaced accessors (subsequently replaced by XCStrings Tool generation). Migrated sign-in/profile/settings/deletion, notification permission/history, activity/session management, all five feedback types, insights, templates, support drafts, shared defaults/actions, accessibility and retained debug controls. Technical diagnostics, brands, identifiers, preview names and sample/user content remain explicit exceptions. Danish sample data replaces English preview examples. The visual audit also found the profile version fallback and support-device headings; both are now localized. App-generated support paragraphs use typed arguments while device values remain verbatim.

Dates, intervals, relative time, durations, question/session/response counts, chart decimals and percentages follow the module locale and preserve the device time zone. Native date intervals fix the former multi-day helper that displayed the end time in place of the start time. Activity section identity is stable (`SectionID`); navigation no longer compares translated headings. Added spoken labels for close, share-link and share-PIN controls. Opinion chart labels/percentages and question headers were adjusted after visual review to prevent clipping.

**Validation:** Native `Feedback Localhost` / `LetsGrow Manager` (iOS 27.2) build passed. Full UnitTests run: **200 passed, zero failures** across AppTests and InsightsTests. After the final fallback/support additions, all **11 localization cases** passed again. Three complete screenshot captures passed as visual findings were corrected; the final **56 current screens were reviewed, zero pending**, with the final hashes recorded in [review findings](../screenshots/review/localization-phase4-findings.json). [Review gallery](../screenshots/index.html): 3 added IDs and 92 historical baseline-only IDs; these reflect the existing curated-catalog comparison, not deletion of 92 screens in this task. No baseline was accepted or changed. All raster assets and four bundled PDF icons were inspected; only exempt brand words/provider glyphs and calendar numerals were found. Nine Python validator tests and catalog validation passed; changed-line SwiftLint: zero violations. Final ordinary build/launch also passed.

**Outstanding runtime acceptance:** Launch with `-AppleLanguages (en)` / `-AppleLocale en_US` succeeded. Live interaction could not be verified: Xcode reported the session missing on inspection/cleanup, while a new session reported the simulator still reserved by `Verify Danish App Copy`. No fallback automation was used. The final ordinary launch does not establish English-preference behavior. Native bundle-language fallback is tested; owner/participant journeys, VoiceOver, Dynamic Type, provider/system language and English-device UI acceptance remain explicit Phase 6 checks. Phase 4 implementation and fixture review are complete; this limitation is not a claim of full runtime acceptance.

**Historical follow-up experiment (2026-11-04, superseded by migration below):** Native Xcode symbol generation already produces internal `LocalizedStringResource.AppStrings` accessors for the package. A real Domain compilation probe confirmed that both namespace and member are inaccessible across module boundaries. The failing probe was removed; final build and all 13 localization cases passed, including native generated plain/parameter/plural lookups and English-locale Danish fallback. Public `L10n` accessors remain unchanged; no dependency was added. See [native-generation evidence](../ios-app/Docs/localization.md#native-generated-symbol-experiment-2026-11-04).

**Completed generator migration (2026-11-04):** XCStrings Tool 1.2.0 now generates the public interface from the catalog. All iOS consumers migrated; removed all 307 handwritten accessors and the duplicate key enum. `L10n` retains formatting and native locale selection. Explicit session-count substitution fixes the complex-plural warning. Native build and all 210 runtime cases passed; 12 validator regression tests, 307 catalog keys and changed-line lint passed. See [migration evidence](../ios-app/Docs/localization.md#completed-accessor-migration-2026-11-04).

## Phase 5 — Migrate notification resources and verify delivery

**Depends on:** Phases 2–4.

- [x] Translate feedback-received notification titles and bodies.
- [x] Audit start-feedback and team-invitation senders; no current repository sender found. Retain the four translated keys for queued/external payload compatibility.
- [x] Preserve all six push keys and both string arguments in count/title order; keep the existing backend payload.
- [x] Package the required notification resources into the main app bundle from the module-owned source through a linked catalog and native Xcode compilation.
- [x] Align the project development language with Danish and pass the compiled-bundle fallback check.
- [x] Localize in-app notification history and app-owned local notifications (history and retained debug sender migrated in Phase 4; delivery remains below).
- [ ] Verify title/body arguments and navigation in foreground, background, and terminated states.
- [x] Verify Danish text with English device preferences.
- [ ] Remove superseded resource files and duplicated editable strings after bundle and delivery checks pass.

**Complete when:** notification resources resolve correctly, displayed text is Danish, and existing payloads/deep links continue working. Record any unavailable real-delivery check as outstanding.

**Automated notification setup (2026-11-04):** Native build, 216 iOS runtime
cases, 20 validator cases and changed-line lint passed. The
[notification runner](../ios-app/.maestro/notifications/README.md) now builds the
app, creates an isolated simulator, sets up an offline owner/session fixture,
handles permission, injects APNs payloads with `simctl push`, and runs Maestro
assertions for background/terminated states. No manual push, backend or login is
required. CI runs counts 0/1/2/99 and uploads artifacts. An automatic iOS 26.5 run
prepared and delivered both cases; screenshots/hierarchy showed raw localization
keys, and both Danish title assertions failed. This confirms the existing app
fallback defect. Resource/notification acceptance remains open until fixed. A temporary literal-Danish control passed text assertions
and tap navigation to the matching session in both states on iOS 26.5. The
checked-in runner retains localized payloads; the control is not an acceptance
pass for the unresolved fallback defect.

**Implementation and verification (2026-11-04):** The six-entry Danish notification catalog is module-owned, projected through a relative link at the existing main-app catalog path, and compiled by the normal Xcode resource phase. No custom script or second editable catalog. `feedbacksvar` permits grammatical singular/plural without changing APNs string arguments. The validator checks 313 keys, APNs signatures, supported languages and link ownership; optional `--app-bundle` checks actual binary resources and development language. All 19 validator regression cases and 210 iOS runtime cases passed; build passed; changed-line lint reports zero violations.

**Fallback fix (2026-11-04):** Edited the project's `developmentRegion` and `knownRegions` directly to `da`. Rebuild passed, and the compiled-bundle validator now passes Danish development metadata and all notification translations. No manual Xcode configuration is required. The runner now checks compiled resources before installation/delivery, retaining the localized APNs payload and Danish text/navigation assertions. All 20 validator regression tests pass. Foreground coverage and production-device delivery remain outstanding. See [packaging details](../ios-app/Docs/localization.md#notification-and-system-string-packaging).

**Automated acceptance after the fallback fix (2026-11-04):** The final full matrix passed **8/8 cases**, exit status 0, on an isolated iOS 26.5 simulator. Counts 0/1/2/99 passed in background and terminated states with English launch preferences: Danish title and complete body, raw-key rejection, original count/title preservation, notification opening and matching session navigation. Results and screenshots: `ios-app/.build/notification-tests-fallback-matrix/`. The preceding fresh two-state count-99 smoke also passed. Earlier diagnostic runs failed on Notification Center gestures; the final flow targets the title and, when necessary, swipes the matching card right and taps the system Open action, with bounded retries and no direct app/deep-link launch. A separate fresh simulator failed installation before delivery; the runner now retries only the installation-promise startup error, with **3 regression tests passed**. No Swift changes were needed for this fix. Foreground presentation, physical-device transport and Phase 6 acceptance remain open.

## Phase 6 — Complete iOS verification and regression checks

**Depends on:** Phases 1–5.

- [ ] Re-scan iOS production source for inline prose and unresolved English findings.
- [x] Add resource validation for missing keys, invalid parameters, and plural definitions.
- [x] Add targeted checks against new hardcoded user-visible prose with explicit exceptions for brands, identifiers, user data, and diagnostics.
- [ ] Run the [iOS acceptance matrix](localization-plan.md#acceptance-tests).
- [ ] Exercise owner and anonymous participant journeys on Danish- and English-configured devices.
- [ ] Verify 0/1/many counts, one/multiple hours, all-day/multiday sessions, relative dates, and decimals.
- [ ] Verify English user-authored content stays unchanged inside Danish UI.
- [x] Review Danish screenshots, wrapping, and truncation. Accessibility verification (including Dynamic Type and VoiceOver) is excluded by user request.
- [ ] Run affected iOS tests/build and changed-line Swift lint using repository guidance; use relevant mobile journeys for regression-sensitive flows.
- [ ] Demonstrate a temporary second-language resource on a representative flow without editing feature code.
- [x] Document how to add a language and how to add new localized copy.
- [ ] Resolve all inventory entries and record externally owned/development-only exceptions.

**Complete when:** all iOS acceptance tests and required checks pass, all inventory items are resolved, and future app copy can be added through Localization.

**Regression guard (2026-11-04):** `check-localized-copy.py` scans 216 non-generated Swift files under App and Modules/Sources. It rejects direct literal prose in common SwiftUI/TCA presentation APIs, including verbatim text, control titles, navigation subtitles, help and accessibility labels/hints/values. Reviewed brand/preview exceptions are limited by file, literal and occurrence count; missing files and unused exceptions also fail. Seven guard regression tests cover English/Danish/multiline copy, comments, interpolation, generated accessors, exception scope and stale allowances. The iOS workflow runs the guard alongside catalog validation and tooling tests. This targeted check is not a Swift parser and cannot certify indirect/custom-component text or replace the outstanding production-source and runtime reviews.

**Native runtime blocker (2026-11-04):** Xcode reported no open workspaces. Opening this checkout's `ios-app/Feedback.xcodeproj` timed out waiting for `hasResolvedInitialRunDestination`; listing again still returned no workspaces. Build, iOS tests, launch and live interaction were therefore not run in this continuation. No alternative simulator automation was used. Foreground delivery, owner/participant journeys, Dynamic Type/VoiceOver and the temporary second-language demonstration remain unchecked.

**Tooling validation:** All **62 Python tooling tests passed** using the existing `ios-app/.build/screenshot-tools/bin/python` environment. The initial system-Python run lacked Pillow for two screenshot test modules; the existing tooling environment resolved that dependency without installation. All 313 catalog keys and the 216-file source guard pass. `python3 ios-app/scripts/lint-swift-changes.py --base HEAD` reports zero changed-line violations in 97 Swift files; `git diff --check` passes. This continuation changes validation tooling/documentation, with no additional Swift or rendered-copy changes.

## English language implementation (2026-11-04)

English is now a shipping localization alongside Danish, selected through native device/app language preferences. Danish remains the source and development language. All 307 app keys and six notification keys have English translations, preserving existing argument signatures and user data. English plurals cover session/question/hour/response counts; complex insight substitutions remain compatible with the generated interface. APNs keeps its count/title string arguments and uses the grammatical count-neutral English body `New feedback for ‘…’ · Responses: …`.

Registered English in the Xcode project. Existing unit/snapshot plans explicitly select Danish/Denmark for stable regression expectations. The snapshot host now declares Danish and English, and catalog containers/manifest follow the actual selected module locale. A temporary English/US capture configuration was restored to Danish/Denmark; Xcode is back on UnitTests. The English review found truncated agreement labels, fixed by widening their columns; final English and Danish captures pass with complete labels. The gallery contains 56 reviewed English screens, zero pending, 3 added and 92 historical baseline-only IDs. These comparison counts do not represent feature removal. Final image hashes and findings: `screenshots/review/english-localization-findings.json`; no approved baselines changed. Preserved user-authored Danish fixture text inside English UI is intentional.

Native validation on Feedback Localhost / LetsGrow Manager (iOS 27.2): build-for-testing passed. Full unit run executed 223 runtime cases: 222 passed and one new unsupported-locale expectation failed. Foundation selected English for that unsupported explicit locale; the incorrect test was replaced with explicit supported-language checks. The final affected generated-localization suite passed 13/13, including English counts 0/1/2/99, independently varying complex counts, invitations, templates and errors. Native English and Danish full-catalog captures both passed, including alert assertions. All 64 Python tooling tests pass, as do both source catalogs, built Danish/English notification resources, and the 216-file copy guard. Changed-line SwiftLint (`--base HEAD`) reports zero violations in 98 files; `git diff --check` passes.

The notification runner retains its English launch preferences and now asserts English title/body text, with independent regression coverage for 0/1/2/99 and user-title escaping. English delivery has not been rerun. Native English launch succeeded, but hierarchy inspection failed with `Session not found`; cleanup reported that the session no longer existed. This is not a live owner/participant acceptance pass. Accessibility verification is excluded by user request. Earlier physical-device Danish verification is user-reported and does not establish English delivery. No commits or pushes were created.

## Review follow-up: real backend notification E2E

Removed the debug-simulator notification launch branch, `NotificationTestLaunch.swift`, its Xcode references, and the cache/status-file fixture protocol. Notification E2E now uses the data-preserving local-backend startup, the existing manager login, authenticated activity/session creation, and real bootstrap/session fetching on notification taps. Test activities are deleted individually after each case, including failed cases; the database is never reset. Sample-manager reseeding requires `--seed-manager`.

The previous offline path had hidden an ignored notification-permission delegate action. Owner startup now requests authorization through the existing live NotificationClient; anonymous users are not prompted, and failures use shared localized error presentation. Hosted iOS CI retains unit/reducer/catalog/compiled-resource checks; notification E2E is an explicit local workflow because that hosted job has no backend or Firebase test configuration. Earlier offline acceptance records above are historical and do not certify this replacement.

**Verification (2026-11-04):** Native Feedback Localhost / LetsGrow Manager (iOS 27.2) build-for-testing passed; all 226 AppTests/InsightsTests runtime cases passed. All 70 Python tooling tests passed, including real-backend ID preparation, missing-manager/missing-session failures, cleanup after failed preparation, and credential-free launch arguments. Changed-line SwiftLint (`--base HEAD`): zero violations in 99 files. Source catalogs (313 keys), built notification resources, the 215-file copy guard and `git diff --check` pass.

Real-backend count-99 delivery/navigation passed for foreground, background and terminated states on isolated iOS 26.5 simulators, without reseeding or resetting existing data. The first smoke run passed background/terminated but failed an obsolete notification-card app-name assertion in foreground. A subsequent foreground run exposed Maestro reading the underlying app's hierarchy while Notification Center was visible, despite screenshots showing correct English text. The final flow returns to Home after injection before inspecting the system hierarchy; exact title/body and matching-session assertions remain. The targeted foreground rerun passed, exit 0. All tested session IDs were confirmed absent from the real backend bootstrap after cleanup. Combined latest passing evidence: `ios-app/.build/notification-tests-real-backend-summary.json`; original two passing cases: `notification-tests-real-backend/`; final foreground: `notification-tests-real-backend-foreground-final/`. Counts 0/1/2 were not rerun in this follow-up. No static UI/copy changed, so no catalog recapture was needed.

## Delivery

Each phase is reviewable independently. Mark work complete only after verification; keep unavailable external checks visible. Implementation stays within iOS source/resources and its validation tooling, using existing API and notification contracts.

Phases 1–4 implemented the inventory, conventions, module foundations, error presentation, copy and formatting migration. Notification packaging/delivery and remaining runtime acceptance continue in Phases 5–6. No commits, pushes, or deployments have been created.
