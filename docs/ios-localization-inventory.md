# iOS localization inventory

Phase 1 source baseline: 2026-11-04, Git HEAD `1fff97f`. All paths below are relative to `ios-app/` unless noted. Static audit only; runtime/screenshot and notification delivery checks belong to later phases.

## Coverage and tracking

Scanned 212 repo-owned Swift files under `App` and `Modules/Sources`, excluding generated OpenAPI sources. Reviewed literal-bearing UI/reducer/model code, dynamic error/formatting paths, package/Xcode localization configuration, the string catalog, Info.plist, launch storyboard, asset references, and Lottie text layers. Tests and preview/fixture text were classified separately from production copy.

| Source area | Swift files scanned |
| --- | ---: |
| App | 3 |
| ActivityFeature | 39 |
| Adapters | 39 |
| DesignSystem | 43 |
| Domain | 32 |
| EnterCodeFeature | 3 |
| FeedbackFlowFeature | 16 |
| MoreFeature | 8 |
| RootFeature | 5 |
| SignUpFeature | 3 |
| TabbarFeature | 7 |
| Utility | 6 |
| InfoPlist / Localization / Logger / OpenAPI input | 8 |

Inventory rows group a source/surface, not unique strings; listed text is representative and the entire source group's app-owned prose must migrate. The original [English-string audit](../tasks/ios-localization.md#ios-english-ui-copy) retains detailed English examples. Phase 1 migrated no strings. Phase 2 added eight seed catalog entries and the module/locale foundation; existing screen-copy migration remains pending.

Statuses: **pending** = planned migration/verification; **development-only** = debug/preview/fixture surface; **externally owned** = platform, provider, user content, or deliberate technical/brand exemption; **migrated** = implemented and verified; **obsolete** = confirmed unused and removed. IOS-01 is migrated as a foundation group; copy and formatting groups migrated in Phase 4 are marked below. No item is declared obsolete. A missing production caller alone does not authorize deletion.

## App, access, and shared presentation

| ID | Status | Source / surface | Text or work to cover | Namespace / phase |
| --- | --- | --- | --- | --- |
| IOS-01 | migrated | `Modules/Sources/Localization`; `Modules/Package.swift` | Phase 2 replaced empty target with Danish AppStrings catalog, typed facade, formatting, dependencies and resource validation; native build and localization tests passed | Foundation / 2 |
| IOS-02 | migrated | `App/FeedbackApp.swift`, Xcode project | Root SwiftUI/module locale, project development region and supported language are Danish. Rebuilt main-app fallback validation and English-preference background/terminated notification acceptance passed in Phase 5 | Foundation / 2 |
| IOS-03 | migrated | `Modules/Sources/RootFeature/StartupLoadingView.swift` | `Lets Grow. Indlæser.` accessibility label | `startup` / 4 |
| IOS-04 | migrated | `RootFeature/RootFeatureView.swift` | `Log ud` through Localization; startup/account/session error screens use deliberate Danish shared presentation | `common`, `errors` / 3–4 |
| IOS-05 | migrated | `SignUpFeature/SignUpView.swift` | Dine aktiviteter; account explanation; Fortsæt med Apple/Google; Profil | `signIn`, `profile` / 4 |
| IOS-06 | migrated | `TabbarFeature/TabbarView.swift` | Giv feedback, Aktiviteter, Profil, Indstillinger; toolbar consumes feedback title | `navigation`, `profile` / 4 |
| IOS-07 | migrated | `TabbarFeature/DeleteAccount.swift` | Logout failure title/message/actions migrated in Phase 3. Phase 4 migrated deletion confirmation/completion copy | `account.delete`, `errors`, `common` / 3–4 |
| IOS-08 | migrated | `TabbarFeature/NotificationPermissionView.swift` | English explanation, Give permission, Messaging, Not now; only preview/catalog call sites found | `notifications.permission` / 4; retain pending until migration confirms lifecycle |
| IOS-09 | migrated | `EnterCodeFeature/EnterCodeView.swift`, `ActivityFeature/Events/JoinEvent/JoinEventView.swift` | Indtast PIN-kode, Start, Svar på feedback, Fortsæt, Session fundet | `feedback.join`, `common` / 4 |
| IOS-10 | migrated | `MoreFeature/AccountSection/ModifyAccountView.swift` | Name, Email, Phone number, calendar-account help, Edit profile, Save | `profile.edit`, `common` / 4 |
| IOS-11 | migrated | `MoreFeature/AccountSection/ProfileSettingsView.swift` | Not found; settings/communication headings; notification/mail explanations; Log ud/Slet konto | `profile`, `settings`, `common` / 4 |
| IOS-12 | migrated | `MoreFeature/MoreSection/MoreSectionView.swift` | General/contact/support sections; privacy, notifications, feedback/report-bug actions; app-sharing CTA | `more`, `support`, `common` / 4 |
| IOS-13 | migrated | `MoreFeature/MoreSection/MoreSection.swift` | Email subjects Feedback/Bug; multiline `<Add your message here>` and `Device info` headings in both draft bodies | `support.feedback`, `support.bug` / 4 |
| IOS-14 | migrated | `DesignSystem/ReusableViews/ErrorView.swift`, `EmptyStateView.swift` | Retry and error title migrated in Phase 3; emoji removed. Phase 4 migrated the reusable default to `Intet at vise endnu.` | `common`, `errors`, `emptyState` / 3–4 |
| IOS-15 | migrated | `DesignSystem/ReusableViews/DeleteConfirmationViewSheet.swift`, `PinCodeTextFieldView.swift`, `EventInfoView.swift` | Annuller, PIN-kode accessibility, Dato, Arrangør; event/date/owner content stays dynamic | `common`, `session`, `accessibility` / 4 |
| IOS-16 | migrated | `DesignSystem/ReusableViews/CloseView.swift` and icon-only invitation controls | Native close role supplies its label; verify selected locale. Invite icon has an identifier but no explicit spoken label: add appropriate localized action label during accessibility migration | `accessibility`, `common` / 4 |

Sources without the `Modules/Sources/` prefix in the remaining tables are relative to that directory.

## Activities, sessions, questions, and insights

| ID | Status | Source / surface | Text or work to cover | Namespace / phase |
| --- | --- | --- | --- | --- |
| IOS-17 | migrated | `ActivityFeature/Activities/ActivityList/ActivityList.swift`, `ActivityListView.swift` | Activity create/save/delete confirmations; refresh-error alert; navigation/actions; first-activity empty state | `activity`, `errors`, `common` / 3–4 |
| IOS-18 | migrated | `ActivityFeature/Activities/ActivityList/Views/ActivityRowView.swift` | 1/many sessions, next-session sentence, no upcoming sessions, first-feedback waiting, response totals | `activity`, `counts` / 4 |
| IOS-19 | migrated | `ActivityFeature/Activities/ActivityDetail/ActivityDetail.swift`, `ActivityDetailView.swift` | Unknown activity; counts; mutation confirmations; Alle sessioner; activity deletion explanation/actions | `activity`, `common` / 4 |
| IOS-20 | migrated | `ActivityFeature/Activities/ActivityDetail/ActivityDetailSessionGrouping.swift`, `Views/ActivityDetailContentView.swift` | Aktuelt/Kommende/Tidligere; Opret/Se alle; edit/delete/how-it-works actions and accessibility. Phase 4 replaced title-based behavior with stable `SectionID` | `activity.sections`, `accessibility` / 4 |
| IOS-21 | migrated | `ActivityFeature/Activities/ActivityDetail/Views/ActivityDetailHowItWorksView.swift` | Multiline calendar setup and account-email guidance; copy confirmation; manual-create explanation; button names mentioned in prose | `activity.calendarSetup`, `common` / 4 |
| IOS-22 | migrated | `ActivityFeature/Activities/ActivityDetail/Views/ActivityDetailSupportViews.swift` | Chart axis/series names, score/no-rating summaries, selection/navigation accessibility, decimal values and dates | `insights`, `accessibility`, formatting / 4 |
| IOS-23 | migrated | `ActivityFeature/Activities/EventDetail/EventDetailFeature.swift`, `EventDetailFeatureView.swift` | Title fallback Session; response counts; full multiline invitation with title/PIN/link; deletion/invitation-unavailable states; confirmations and toolbar accessibility | `session`, `session.invite`, `accessibility` / 4 |
| IOS-24 | migrated | `ActivityFeature/Events/EventDetail/InviteView.swift` | Inviter; explanation; share/copy labels. Supplied link and share parameters remain verbatim | `session.invite`, `accessibility` / 4 |
| IOS-25 | migrated | `ActivityFeature/Activities/ManageActivity/ManageActivity.swift`, `ManageActivityView.swift` | Create/edit/save actions; step progress; naming help; template picker; question counts; replace-custom-questions alert | `activity.edit`, `common` / 4 |
| IOS-26 | migrated | `ActivityFeature/Activities/ManageActivity/FeedbackTemplate.swift` | Five template titles/subtitles and 12 default question texts for meeting/team/retrospective/workshop; SF Symbol names are identifiers | `templates` / 4 |
| IOS-27 | migrated | `ActivityFeature/Activities/ManageEvent/ManageEvent.swift`, `ManageEventView.swift` | Duration presets, new/edit session, optional location, start/time/date/all-day, inherited-feedback explanation, custom hours/minutes; English Time labels a date-only picker | `session.edit`, formatting / 4 |
| IOS-28 | migrated | `ActivityFeature/Activities/ManageEvent/QuestionPickerView.swift`, `QuestionsListView.swift` | Add/edit/save question, participant preview explanation, placeholder/hint, answer-type picker, empty state | `questions`, `common`, `accessibility` / 4 |
| IOS-29 | migrated | `ActivityFeature/Activities/ManageEvent/FeedbackType+Extensions.swift`, `Shared/FeedbackTypeTagView.swift` | Answer-type names, subtitles, detailed explanations; accessibility consumes titles | `questions.answerTypes` / 4 |
| IOS-30 | migrated | `ActivityFeature/Events/EventDetail/DetailSectionView.swift`, `QuestionSummaryViews.swift` | Detail/date/duration/location/calendar headings; PIN expired state; response/comment/question counts; opinion labels; percentage formatting | `session.detail`, `feedback`, formatting / 4 |
| IOS-31 | migrated | `ActivityFeature/Events/EventDetail/FeedbackCommentRowView.swift` | New badge, opinion labels from Domain, relative time uses view locale | `feedback`, formatting / 4 |
| IOS-32 | migrated | `ActivityFeature/Shared/Lists/EventListView.swift`, `Shared/FeedbackPercentageBar.swift` | Empty session/feedback states, new badges/accessibility, today/yesterday/tomorrow date phrases, response counts, complete row accessibility sentence | `session.list`, `accessibility`, formatting / 4 |
| IOS-33 | migrated | `ActivityFeature/Insights/ActivityInsightData.swift`, `ActivityInsightSectionsView.swift`, `InsightTrendView.swift` | Improvement/stable/declining/insufficient summaries; history/scale explanation; response/session counts; rating terminology; opinion/count accessibility | `insights`, `counts`, `accessibility` / 4 |
| IOS-34 | migrated | `ActivityFeature/Events/NotificationHistoryView.swift` | Empty state, new badge, whole new-feedback sentence with plural agreement, activity heading, relative time; only preview/catalog construction found | `notifications.history` / 4–5; retain pending until caller audit resolves lifecycle |

## Participant flow, model presentation, and errors

| ID | Status | Source / surface | Text or work to cover | Namespace / phase |
| --- | --- | --- | --- | --- |
| IOS-35 | migrated | `FeedbackFlowFeature/FeedbackFlowCoordinatorView.swift` | Afslut, Tak for din feedback, question progress, Send svar, Næste; event info uses shared component | `feedback.flow`, `common` / 4 |
| IOS-36 | migrated | `FeedbackFlowFeature/Views/FeedbackElaborationTextField.swift`, `OpinionFeedback/OpinionFeedbackView.swift`, `ZeroToTenFeedback/ZeroToTenFeedbackView.swift` | Uddyb gerne hvorfor, Skift, af 10, Vurdering; scale endpoints numeric; other answer views consume questions/inputs dynamically | `feedback.answer`, `common` / 4 |
| IOS-37 | migrated | `FeedbackFlowFeature/Views/RatingAlertView.swift`, `FeedbackQuestionIllustrationView.swift` | App-rating title/message/actions; full participant-example accessibility sentence with question parameter | `feedback.appRating`, `accessibility` / 4 |
| IOS-38 | migrated | `Domain/Models/API/FeedbackSession.swift`, `Bootstrap.swift` (`ParticipantEvent.title`) | Two literal Event titles; FeedbackEventDto title reaches live participant flow navigation through TabbarView/FeedbackFlowCoordinator | `session` / 4 |
| IOS-39 | migrated | `Domain/Models/API/Bootstrap.swift` (`Event` and `Activity` helpers), `Utility/Extensions/Date+Extension.swift` | Duplicated All day, hour(s), at/to date connectors; duration/provider labels; device-locale date/relative-time helpers | Formatting / 2–4; keep provider brands unchanged |
| IOS-40 | migrated | `Domain/Models/Feedback.swift`, `Domain/Models/Role.swift` | Five Danish opinion labels; Mødeejer presentation; enum raw values stay technical | `feedback.opinion`, `account.role` / 4 |
| IOS-41 | migrated | `Domain/Error+Extension.swift`, `Domain/AlertState+Extension.swift` | Generic and six domain-code titles/messages migrated; URLError/NSError raw text no longer displayed; localized OK action | `errors`, `common` / 3 |
| IOS-42 | migrated | `Adapters/APIClient/APIClientCache.swift`, local errors in `ManageEvent.swift` / `EventDetailFeature.swift` | Missing manager/activity/event cache, missing event ID/invite link now use safe module-owned Danish presentation; cache diagnostics retained | `errors` / 3 |
| IOS-43 | migrated | `Adapters/APIClient/Live/*`, response error mappers, `Adapters/AuthClient/*`, `Domain/Services/AuthClient.swift` | Existing codes/HTTP/network/auth failure boundary migrated; API messages stay diagnostic; cancellation preserved; unknown failures use safe Danish copy | `errors` / 3 |
| IOS-44 | migrated | `RootFeature`, `SignUpFeature`, `EnterCodeFeature`, `TabbarFeature`, activity/feedback reducers | Presentation sinks using `.init(error:)` / `error.localized` and already-Danish banners/refresh alert; verify every sink shares the policy | `errors` / 3 |

## Resources, development, and external content

| ID | Status | Source / surface | Decision / work |
| --- | --- | --- | --- |
| IOS-45 | in progress | `Localization/AppBundleResources/Localizable.xcstrings`, linked from `Resources/Localizable.xcstrings` | All six keys translated and compiled into main-app Danish resources; two-string count/title APNs contract preserved. No repository start-feedback/team-invite senders found; retained for external/queued compatibility. Danish development-language fallback and the localized 0/1/2/99 background/terminated matrix pass. Foreground and physical-device delivery remain outstanding. |
| IOS-46 | pending | `Adapters/NotificationClient/NotificationClientLive.swift` | Local notification accepts supplied title/body; only local sender found is DebugMenuView. Debug sender copy is localized; main-app resource fallback and remote background/terminated delivery pass. Local/foreground presentation and physical-device delivery remain unverified. |
| IOS-47 | development-only | `App/DebugMenuView.swift`, `App/FeedbackApp.swift` | Overlay is guarded by `#if DEBUG`; translate retained app-owned controls, status headings/success messages, mock notification title/body. Raw session dumps, tokens, and diagnostics remain technical. |
| IOS-48 | development-only | `SignUpFeature/SignUp.swift`, `SignUpView.swift` | E2E sheet/actions/status gated by DEBUG and test-login settings; localize retained visible labels/status templates, keep injected-token/config identifiers unchanged. |
| IOS-49 | development-only | `ScreenCatalogPreviewView.swift` in features, `Domain/PreviewCatalogFixtures.swift`, `Domain/MockModels.swift`, inline `#Preview` blocks | English example comments/titles/Hello/Enabled/Disabled/Trigger Banner/Show sheet; use Danish screenshot examples. Preview names, fixture IDs and deliberately English user-data test cases remain identifiers/data. |
| IOS-50 | migrated | `Modules/Tests/AppTests/UnitTests/PresentableErrorTests.swift`, `DateTests.swift`, reducer/snapshot tests | Error tests now assert Danish and reject English/raw diagnostics (Phase 3). Keep explicit-English locale/date and user-content tests where they test independent behavior; add Danish app-locale expectations and refresh snapshots in later phases. |
| IOS-51 | externally owned | `DesignSystem/ReusableViews/LetsGrowFeedbackLogoView.swift`; `Resources/...` logos/provider images | Brand Lets Grow/Feedback wordmark and provider names stay unchanged. Inspected letsGrowText PNG contains only brand words. Keep spoken surrounding labels localized. |
| IOS-52 | externally owned | Asset catalogs / bundled PDFs and other raster icons | Asset references are brand/calendar/social/emoji icons, not localized UI screenshots. Phase 4 visually inspected all raster assets and four rendered PDF icons: brand/provider glyphs and calendar numerals only; no app-owned English prose to replace. |
| IOS-53 | externally owned | Launch storyboard and Lottie files | Storyboard contains no `text=` labels. loading/fiveStars/messagePermission animations contain no Lottie text layers. Internal layer names are not translated; outlined glyphs still belong to later visual review. |
| IOS-54 | externally owned | `App/InfoPlist/Info.plist`, `InfoPlist/*`, Logger, non-presentation Utility and adapter constants | No usage-description prose in current app plist; config keys, bundle IDs, URL schemes, device values, API fields, symbol/resource names, raw enum values and logs remain technical. App language metadata still covered by IOS-02. |
| IOS-55 | externally owned | User/API/calendar content | Names, e-mail/phone details, session titles, questions, feedback comments, PINs and URLs stay verbatim. Do not localize API diagnostic messages; map failures at the iOS boundary. |
| IOS-57 | migrated | `Utility/DeviceInfo.swift` | Phase 4 visual review discovered the profile version/build fallback and device-summary headings in support drafts. Localized visible fallbacks and complete support sections; actual device/build/identifier values stay verbatim. |
| IOS-56 | externally owned | Apple/Google sheets, OS authorization/share/close controls, mail/settings/App Store/browser destinations | See the [ownership and control matrix](ios-localization-conventions.md#external-ui-and-documented-exceptions); localize LetsGrow-supplied labels/messages, record platform/provider behavior during QA. |

## Migration risks resolved into conventions

- Resource ownership uses the existing Localization target; notification output may need app-bundle packaging, with one editable source.
- Section behavior must use stable identity rather than translated headings (IOS-20).
- `FeedbackEventDto.title` is a live English source, not just an old model helper (IOS-38).
- Support e-mail drafts are iOS-generated text even though the mail app is external (IOS-13).
- English reusable defaults must migrate even where current callers override them (IOS-14).
- Preview/catalog reachability does not establish production reachability; no unused view or notification key is declared obsolete in this phase.
- Locale-dependent snapshots cannot prove the production app's language policy. Runtime checks remain required in later phases.

## Phase 1 result

Inventory and conventions are complete for planning. Migration status remains pending for app code/resources. There are no blocking scope or terminology questions for Phase 2. Packaging details, asset visual review, and runtime/provider language checks are assigned to their implementation/verification phases rather than represented as already verified.

## Phase 2 update

The Localization foundation (IOS-01) is implemented and verified through a native build and nine passing localization cases. The initial full test run passed 191 cases and exposed one relative-time wording issue; the corrected localization suite passed on rerun. Eight validator regression tests and catalog validation pass; changed-line SwiftLint reports zero violations. The app launched with English language preferences. Native UI inspection is inconclusive because Xcode lost the interaction session while retaining its device reservation; see [phase evidence](../tasks/ios-localization.md). At the end of Phase 2, error mapping, screen copy, model-formatting call sites, assets, and notifications were pending; Phase 3 progress is recorded below.

Phase 3: shared error presentation, six domain codes, HTTP/network/auth adapter boundaries and known local failures are migrated. Full regression run passed 196 cases; the two failed assertions were corrected and the affected suites passed 10/10, followed by 6/6 final adapter cases. Catalog validation, validator tests and changed-line lint passed; native build and launch passed. Native UI interaction could not retain its session, so runtime error-screen/English-preference inspection remains pending in Phase 6. See the phase checklist for evidence.

## Phase 4 update

App-owned production copy in IOS-03–40 and the remaining shared presentation sinks in IOS-44 are migrated, with brand/user-content boundaries preserved. The table retains baseline wording examples as audit history; “English”, “remaining”, or raw examples in that column describe what was found, not unresolved literals. Permission/history helpers remain retained even where only preview/catalog callers were found. No feature was removed based on apparent unreachability. IOS-47–49 remain development-only: retained app controls use Localization; diagnostic dumps/test status details and preview/fixture data are explicit exceptions, with Danish sample content for review. IOS-57 records a newly discovered surface rather than silently classifying visible device headings as technical data.

Catalog: 307 typed keys; full unit run 200/200; final localization suite 11/11; final catalog capture 56/56 screens reviewed. Native build and ordinary launch passed, as did an English-argument launch. Live hierarchy inspection was unavailable because Xcode lost the session while retaining its simulator reservation. See the [Phase 4 evidence](../tasks/ios-localization.md#phase-4--migrate-all-ios-copy-and-formatting) and [review gallery](../screenshots/index.html). IOS-02, IOS-45–46 (main-app language metadata/notification resources and delivery), plus Phase 6 runtime/accessibility checks remain outstanding. No screenshot baselines were accepted.

## Phase 5 progress

Notification copy and source ownership are migrated; native Xcode compiles the module-owned catalog through the main-app resource link. The latest build, 216 iOS tests and 20 validator cases pass, with zero changed-line lint violations. The [automated notification runner](../ios-app/.maestro/notifications/README.md) now prepares an offline fixture, grants permission, injects localized APNs payloads, and verifies Notification Center/tap behavior without manual input. Automatic background/terminated simulator runs delivered the payloads and captured raw localization keys; the Danish assertions correctly fail. IOS-02 and IOS-45–46 remain open until development language, passing localized delivery/navigation and remaining runtime acceptance are verified. This paragraph records the initial failing run; the subsequent fallback fix and passing delivery evidence are recorded below. See [Phase 5 blockers](../tasks/ios-localization.md#phase-5--migrate-notification-resources-and-verify-delivery).


## Phase 5 fallback and Phase 6 regression update

The project development region is now Danish; compiled-bundle validation passes. The actual localized APNs payload passed all eight background/terminated cases (counts 0/1/2/99) with English launch preferences, complete Danish text and matching session navigation. IOS-02 is migrated; IOS-45–46 retain delivery checks for foreground/local notifications and physical-device transport. Earlier raw-key failures above are historical, superseded by this result.

The Phase 6 direct-copy guard passes across 216 non-generated App/module Swift files, with narrow reviewed brand/preview exceptions and failure on stale exceptions. Catalog validation passes all 313 keys. The guard does not resolve indirect text or custom-component parameters, so it supplements the outstanding full production-source review. New native runtime acceptance is blocked by Xcode project opening timing out and no workspace being listed afterward; no new build, iOS test or UI pass is claimed. See the [current phase evidence](../tasks/ios-localization.md#phase-6--complete-ios-verification-and-regression-checks).


## English language update

IOS-58 (migrated): all 307 app entries and six module-owned push entries now include English. Project language registration and snapshot host metadata support Danish/English; Danish remains the source/development language. Native regional preference and explicit-resource tests cover both languages, with count-sensitive grammar and verbatim user-content preservation. Source/compiled-resource validation and 64 tooling tests pass. The final English screenshot gallery has 56 reviewed/zero pending screens; widened opinion labels prevent English truncation. Danish regression capture passes too. See the [English implementation evidence](../tasks/ios-localization.md#english-language-implementation-2026-11-04) for exact test outcomes and remaining live-English verification limits. Accessibility verification is excluded by user request; the user reports physical-device Danish verification complete.


## Review follow-up: notification tests use the local backend

The offline notification app entry point and substituted API client have been removed. Notification E2E creates and deletes its own real activity/session through the local API, launches using the existing local manager login, and exercises normal bootstrap fetching on taps. Existing backend data is preserved; sample-manager replacement requires explicit `--seed-manager`. The existing owner notification-permission delegate is now handled through the real authorization client; anonymous accounts are not prompted. Unit/compiled-resource validation stays in hosted CI, while this backend-dependent suite runs explicitly in the configured local environment. Earlier offline delivery results are historical. Current verification is recorded in the [review follow-up](../tasks/ios-localization.md#review-follow-up-real-backend-notification-e2e).
