# iOS localization inventory

Original source baseline: 2026-11-04, Git HEAD `1fff97f`. All paths below are relative to `ios-app/` unless noted. The implementation is complete and the task was closed on 2026-11-06 at the user's request; broader manual acceptance continues independently. See [current usage and verification limits](../ios-app/Docs/localization.md).

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

Inventory rows group a source/surface, not unique strings. Listed examples describe the original migration scope, including copy that was subsequently replaced. The original audit and phase evidence remain in Git history; this inventory records implementation ownership and exceptions.

Statuses: **development-only** = debug/preview/fixture surface; **externally owned** = platform, provider, user content, or deliberate technical/brand exemption; **migrated** = implementation complete with the evidence/coverage limits summarized below; **obsolete** = confirmed unused and removed. No item is declared obsolete. A missing production caller alone does not authorize deletion. Migrated status does not imply every manual device/provider case has passed.

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
| IOS-08 | migrated | `TabbarFeature/NotificationPermissionView.swift` | English explanation, Give permission, Messaging, Not now; only preview/catalog call sites found | `notifications.permission` / 4; localized permission UI; owner startup authorization is covered by the recorded notification follow-up |
| IOS-09 | migrated | `EnterCodeFeature/EnterCodeView.swift`, `ActivityFeature/Events/JoinEvent/JoinEventView.swift` | Indtast PIN-kode, Start, Svar på feedback, Fortsæt, Session fundet | `feedback.join`, `common` / 4 |
| IOS-10 | migrated | `MoreFeature/AccountSection/ModifyAccountView.swift` | Name, Email, Phone number, calendar-account help, Edit profile, Save | `profile.edit`, `common` / 4 |
| IOS-11 | migrated | `MoreFeature/AccountSection/ProfileSettingsView.swift` | Missing-value placeholder; settings; Log ud/Slet konto. Unused communication section and its five Danish/English keys removed 2026-11-06 | `profile`, `settings`, `common` / 4 |
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
| IOS-21 | migrated | `ActivityFeature/Activities/ActivityDetail/Views/ActivityDetailHowItWorksView.swift` | Multiline calendar setup and account-email guidance; copy confirmation explicitly identifies the email address and instructs adding it as a calendar attendee (Danish/English); manual-create explanation; button names mentioned in prose | `activity.calendarSetup`, `activity.copyEmailTitle`, `activity.copyEmailMessage`, `common` / 4 |
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
| IOS-43 | migrated | `Adapters/APIClient/Live/*`, response error mappers, `Adapters/AuthClient/*`, `Domain/Services/AuthClient.swift` | Existing codes/HTTP/network/auth boundary migrated; complete backend userTitle/userMessage now take priority for API failures; API diagnostic message stays hidden; cancellation and local compatibility fallbacks preserved | `errors` / 3 |
| IOS-44 | migrated | `RootFeature`, `SignUpFeature`, `EnterCodeFeature`, `TabbarFeature`, activity/feedback reducers | Presentation sinks using `.init(error:)` / `error.localized` and already-Danish banners/refresh alert; verify every sink shares the policy | `errors` / 3 |

## Resources, development, and external content

| ID | Status | Source / surface | Decision / work |
| --- | --- | --- | --- |
| IOS-45 | migrated | `Localization/AppBundleResources/Localizable.xcstrings`, linked from `Resources/Localizable.xcstrings` | Six Danish/English keys compiled into the main-app resources, preserving the two-string count/title contract and queued/external keys. Real-backend count-99 text/navigation passed in foreground/background/terminated states; full replacement-flow count matrix and physical-device transport are not claimed. |
| IOS-46 | migrated | `Adapters/NotificationClient/NotificationClientLive.swift` | Supplied local-notification title/body and the retained debug sender use app-owned localized copy. System permission is requested through the live owner startup path. Local/transient presentation and physical-device coverage remain manual testing limits. |
| IOS-47 | development-only | `App/DebugMenuView.swift`, `App/FeedbackApp.swift` | Overlay is guarded by `#if DEBUG`; translate retained app-owned controls, status headings/success messages, mock notification title/body. Raw session dumps, tokens, and diagnostics remain technical. |
| IOS-48 | development-only | `SignUpFeature/SignUp.swift`, `SignUpView.swift` | E2E sheet/actions/status gated by DEBUG and test-login settings; localize retained visible labels/status templates, keep injected-token/config identifiers unchanged. |
| IOS-49 | development-only | `ScreenCatalogPreviewView.swift` in features, `Domain/PreviewCatalogFixtures.swift`, `Domain/MockModels.swift`, inline `#Preview` blocks | English example comments/titles/Hello/Enabled/Disabled/Trigger Banner/Show sheet; use Danish screenshot examples. Preview names, fixture IDs and deliberately English user-data test cases remain identifiers/data. |
| IOS-50 | migrated | `Modules/Tests/AppTests/UnitTests/PresentableErrorTests.swift`, `DateTests.swift`, reducer/snapshot tests | Error tests now assert Danish and reject English/raw diagnostics (Phase 3). Keep explicit-English locale/date and user-content tests where they test independent behavior; Danish/English resource cases and both-language catalog captures are recorded in the completed implementation. |
| IOS-51 | externally owned | `DesignSystem/ReusableViews/LetsGrowFeedbackLogoView.swift`; `Resources/...` logos/provider images | Brand Lets Grow/Feedback wordmark and provider names stay unchanged. Inspected letsGrowText PNG contains only brand words. Keep spoken surrounding labels localized. |
| IOS-52 | externally owned | Asset catalogs / bundled PDFs and other raster icons | Asset references are brand/calendar/social/emoji icons, not localized UI screenshots. Phase 4 visually inspected all raster assets and four rendered PDF icons: brand/provider glyphs and calendar numerals only; no app-owned English prose to replace. |
| IOS-53 | externally owned | Launch storyboard and Lottie files | Storyboard contains no `text=` labels. loading/fiveStars/messagePermission animations contain no Lottie text layers. Internal layer names are not translated; new artwork should be checked for embedded app-owned prose when it changes. |
| IOS-54 | externally owned | `App/InfoPlist/Info.plist`, `InfoPlist/*`, Logger, non-presentation Utility and adapter constants | No usage-description prose in current app plist; config keys, bundle IDs, URL schemes, device values, API fields, symbol/resource names, raw enum values and logs remain technical. App language metadata still covered by IOS-02. |
| IOS-55 | externally owned | User/API/calendar content | Names, e-mail/phone details, session titles, questions, feedback comments, PINs and URLs stay verbatim. Do not localize API diagnostic messages; map failures at the iOS boundary. |
| IOS-57 | migrated | `Utility/DeviceInfo.swift` | Phase 4 visual review discovered the profile version/build fallback and device-summary headings in support drafts. Localized visible fallbacks and complete support sections; actual device/build/identifier values stay verbatim. |
| IOS-56 | externally owned | Apple/Google sheets, OS authorization/share/close controls, mail/settings/App Store/browser destinations | See the [ownership and control matrix](ios-localization-conventions.md#external-ui-and-documented-exceptions); localize LetsGrow-supplied labels/messages, record platform/provider behavior during QA. |

| IOS-58 | migrated | App and notification String Catalogs, project language configuration, screenshot host | Danish and English translations, generated public interface, regional/explicit-language tests, and both-language capture support are implemented. |

## Migration risks resolved into conventions

- Resource ownership uses the existing Localization target; notification output uses the linked main-app catalog, with one editable source.
- Section behavior must use stable identity rather than translated headings (IOS-20).
- `FeedbackEventDto.title` is a live English source, not just an old model helper (IOS-38).
- Support e-mail drafts are iOS-generated text even though the mail app is external (IOS-13).
- English reusable defaults must migrate even where current callers override them (IOS-14).
- Preview/catalog reachability does not establish production reachability; no unused view or notification key is declared obsolete in this phase.
- Locale-dependent snapshots cannot prove the production app's language policy. Recorded runtime checks and manual coverage limits are distinguished below.

## Delivery and verification

The completed architecture uses module-owned Danish/English catalogs, XCStrings Tool public accessors, native bundle language selection, shared formatting, localized domain error presentation, stable section identities, and linked main-app notification resources. No duplicate handwritten key registry or editable push catalog remains. See the [implementation guide](../ios-app/Docs/localization.md) and [conventions](ios-localization-conventions.md) for maintenance.

The latest recorded native run on 2026-11-04 passed build-for-testing and all 226 AppTests/InsightsTests cases. Danish and English catalog captures passed, including the recorded 56-screen English review. The real-backend count-99 notification run passed foreground/background/terminated text and matching-session navigation with cleanup. Its [delivery record](../ios-app/.maestro/notifications/README.md#backend-dependent-verification) supersedes the earlier offline-fixture evidence; counts 0/1/2 were not rerun in that replacement flow.

Closeout on 2026-11-06 passed validation of 313 catalog keys and signatures, the direct-copy guard over 215 Swift files, and all 70 Python tooling tests. A targeted inspection of literal-bearing presentation/return sites found reviewed preview, brand, numeric, user-data, and diagnostic cases. This is not a full Swift-parser analysis or a fresh runtime acceptance run.

The user will perform broader manual owner/anonymous, language/device/provider, local/transient-notification, and physical-device push testing, opening a new task for any problem found. Accessibility verification was excluded by the user. The former implementation task is removed; manual coverage is not represented as an open implementation blocker or a passing test.

Maintenance 2026-11-06: answer-type selection now uses an explicit temporary-choice sheet; `common.choose` supplies Danish “Vælg” and English “Choose” for opening/confirming that selection. Question text remains user data.
