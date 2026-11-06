# Danish localization: iOS audit and migration plan

Status: Phases 1–4 implemented; notification packaging/delivery and final runtime acceptance pending. Scope confirmed by the user: iOS app only. Updated: 2026-11-04.

## Goal and scope

Make all LetsGrow-owned text presented by the iOS app Danish, including errors, accessibility labels, notifications, validation, sharing text, and date/number presentation. Move all existing Danish and English copy into the existing dedicated `ios-app/Modules/Sources/Localization` module so another language can be added later.

Danish is the only initially supported language and the default on devices with unsupported language preferences. No language picker is required initially.

This task covers iOS source, resources, app configuration, and iOS validation tooling. Web pages (including the linked privacy policy), backend messages, API schemas, generated API clients, and outgoing server email templates are outside its scope. Errors received from the existing API are translated at the iOS presentation boundary using existing codes and HTTP status information.

User-authored names, activity/session titles, questions, comments, and calendar content remain verbatim. Brand names, URLs, identifiers, logs, and developer diagnostics do not require translation. App-owned templates and defaults are localized before becoming user-owned content. Translate app-owned link labels, including the privacy-policy link, without changing the destination page.

## Findings from the source audit

The initial static audit was performed on 2026-11-01 and refreshed in Phase 1 on 2026-11-04. The current migration ledger is the [iOS localization inventory](ios-localization-inventory.md); implementation follows the [localization conventions](ios-localization-conventions.md). This is not runtime certification. Older views/model helpers need reachability checks. SDK/server messages cannot be exhaustively listed and must be handled at the iOS presentation boundary.

Paths below are relative to the repository root.

### iOS: English UI copy

| Source | English text or group | Proposed Danish direction |
| --- | --- | --- |
| `ios-app/Modules/Sources/MoreFeature/AccountSection/ModifyAccountView.swift` | `Name`, `Email`, `Phone number`, `Edit profile`, `Save`; `Use the same email as your calendar account (Google, Outlook, etc.).` | Navn, E-mail, Telefonnummer, Rediger profil, Gem; Brug samme e-mailadresse som til din kalenderkonto … |
| `ios-app/Modules/Sources/MoreFeature/AccountSection/ProfileSettingsView.swift` | `Not found` for name/email/phone | Ikke angivet |
| `ios-app/Modules/Sources/TabbarFeature/NotificationPermissionView.swift` | `Please allow notifications so we can send you important messages.`, `Give permission`, `Messaging`, `Not now` | Concrete notification explanation; Tillad notifikationer, Notifikationer, Ikke nu |
| `ios-app/Modules/Sources/TabbarFeature/DeleteAccount.swift` | `Are you sure?`, `Delete account`, `Cancel`, `All data related to your account will be deleted and cannot be restored. ⚠️`, `Account deleted.`, `Close`, `Thank you for using Lets Grow.`, `Logout failed.`, `Log out`, `Please try again.` | Danish confirmation, irreversible-delete explanation, completion, and logout failure copy |
| `ios-app/Modules/Sources/RootFeature/RootFeatureView.swift` | `Log out` | Log ud |
| `ios-app/Modules/Sources/DesignSystem/ReusableViews/ErrorView.swift` | `Try again`; adds a poop emoji to the displayed error title | Prøv igen; use a plain error title |
| `ios-app/Modules/Sources/ActivityFeature/Events/EventDetail/FeedbackCommentRowView.swift` | `New` badge | Nyt |
| `ios-app/Modules/Sources/ActivityFeature/Activities/ManageEvent/ManageEventView.swift` | `Time` in the date-only picker branch | Dato, matching what that control selects |
| `ios-app/Modules/Sources/Domain/Models/API/Bootstrap.swift` | `Event`, `All day`, `1 hour`, interpolated `… hours`, and date-range connectors `at` / `to`; duplicated across model helpers | Session, Hele dagen, plural-aware hours and localized date intervals |

Phase 1 additionally identified:

- `MoreFeature/MoreSection/MoreSection.swift`: support-email subject `Bug`, `<Add your message here>`, and `Device info` in both mail-draft bodies.
- `DesignSystem/ReusableViews/EmptyStateView.swift`: default `Nothing here yet.`; migrate even though current production callers provide a title.
- `Domain/Models/API/FeedbackSession.swift`: literal `Event` reaches the live participant navigation title. `ParticipantEvent.title` also contains this literal.
- Existing Danish templates, status confirmations, accessibility/chart text, support/invite messages, and opinion/role labels all require extraction; see the inventory for source groups.
- `ActivityDetailContentView.swift` compares `section.title` with `Aktuelt`; replace title-based behavior with stable identity as part of UI migration.

### iOS: errors

`ios-app/Modules/Sources/Domain/Error+Extension.swift` currently contains:

- `Error 💩` / `An unexpected issue occurred. Try again.`
- `Duplicate feedback` / `Feedback already submitted for this event.`
- `Already joined` / `You already joined this event.`
- `Invalid PIN code` / `The provided pin code does not match any active event.`
- `Not allowed` / `You cannot join your own event.`
- `Not allowed` / `You cannot give feedback to yourself.`
- `Not allowed` / `You do not have access to this resource.`

It also displays `URLError.localizedDescription` and arbitrary `NSError.userInfo[NSLocalizedDescriptionKey]`. The latter can overwrite a deliberately selected message. This allows SDK/OS text through in the device language and can expose technical errors.

Other errors potentially exposed through that path:

| Source | Text |
| --- | --- |
| `ios-app/Modules/Sources/ActivityFeature/Activities/EventDetail/EventDetailFeature.swift` | `Could not create invite link.` |
| `ios-app/Modules/Sources/ActivityFeature/Activities/ManageEvent/ManageEvent.swift` | `Missing event identifier.` |
| `ios-app/Modules/Sources/Adapters/APIClient/APIClientCache.swift` | `Could not update cache. Manager data is missing.`, `Could not update activity in cache. Activity with id … was not found.`, `Could not update event in cache. Event with id … was not found.` |

Suggested user messages include `Der opstod en fejl`, `Der opstod en uventet fejl. Prøv igen.`, `Du har allerede sendt feedback til denne session.`, `PIN-koden passer ikke til en aktiv session.`, and `Du har ikke adgang til dette indhold.` Technical diagnostics stay in logs; they do not need Danish translations.

### iOS: existing resources, formatting, and development surfaces

- Initial finding: the Localization target was empty and had no resources/consumers. Phase 2 replaced it with the typed facade, processed Danish catalog, formatting helpers, explicit dependencies, and Danish package default; see [implementation usage](../ios-app/Docs/localization.md).
- `ios-app/Resources/Localizable.xcstrings` has English as its source language and six English notification entries:
  - `notification_feedback_received_title`: `New feedback 🔥`
  - `notification_feedback_received_body`: `You have received %@ feedback on ‘%@’ `
  - `notification_start_feedback_title`: `It is time for feedback 🔥`
  - `notification_start_feedback_body`: `Nicolai really wants the feedback from you, tap to start the feedback session.`
  - `notification_team_invite_received_title`: `You received a team invitation🔥`
  - `notification_team_invite_received_body`: `Tap to accept the invite`
- The backend currently references the two feedback-received keys. Check whether the other four keys are still used before retaining obsolete product copy.
- The Xcode project uses `developmentRegion = en`. Date helpers in `Utility/Extensions/Date+Extension.swift` and direct `.formatted(...)` calls use the current locale. Numeric formatting also appears in insights and chart accessibility text. Danish preview settings do not establish the production app's locale.
- Development surfaces: `App/DebugMenuView.swift` contains English controls, success/error messages, and mock notification text. `SignUpFeature/SignUpView.swift` contains `Login with injected E2E token` and `E2E authentication`; its reducer has `No injected E2E token found`. Keep these explicitly development-only and extract app-owned visible labels if retained.
- Preview-only examples include `Hello`, `Enabled`, `Disabled`, `Trigger Banner`, `Show sheet`, `Session with feedback`, `Session empty feedback`, `Title`, `Message`, and English sample comments. These are not evidence of production UI; use Danish sample content where it appears in screenshots. Preview names, fixture identifiers, and test selectors remain identifiers.

## Localization module design

Use the existing `ios-app/Modules/Sources/Localization` Swift package target as the single owner of editable app translations, Danish string catalogs, typed lookup, and presentation formatting.

- Configure package resources and Danish default localization; expose typed keys and arguments to consumers.
- Add explicit module dependencies for features, DesignSystem, and presentation helpers that use localization.
- Keep the dependency graph acyclic: Localization must not depend on Domain, Utility, or features that consume it.
- Use semantic keys such as `common.save`, `profile.edit.title`, and `errors.pinNotFound.message`.
- Localize complete sentences with typed arguments and plural forms rather than assembling translated fragments.
- Centralize locale-aware date intervals, relative time, durations, counts, and decimal formatting. Preserve the user's time zone.
- Validate missing keys and invalid placeholders. Unsupported locales select Danish.
- Source any required main-app notification resources from the module-owned catalog without two editable copies. Verify resource resolution in the built app and delivered notifications before removing old resources.
- Apply the same ownership rule to any app-bundle system strings that need localization.
- Record system/identity-provider-owned UI and its supported language controls separately from app-owned copy.

## Error presentation design

1. Map all six existing `DomainCode` cases to Danish titles/messages from Localization.
2. Map existing HTTP status information, network errors, authentication SDK codes, and known local failures to deliberate localized messages within iOS.
3. Unknown codes/errors use a safe Danish generic message. Do not display raw API `message`, `localizedDescription`, or `NSLocalizedDescriptionKey` as user copy.
4. Ensure an arbitrary NSError description cannot overwrite a deliberately selected message. Keep technical diagnostics in logging.
5. Preserve appropriate cancellation behavior and existing error recovery actions.
6. Use the existing API contract. New backend codes or API schema changes are not a prerequisite for this task. Exercise unsupported/malformed responses through iOS test doubles and the adapter/presentation boundary.

## Implementation phases

The executable checklist lives in [iOS localization phases](localization-phases.md):

1. Finalize the iOS inventory and conventions.
2. Establish the Localization module and language/formatting policy.
3. Replace iOS error presentation.
4. Migrate all iOS UI and presentation copy.
5. Migrate iOS notification resources and verify delivery.
6. Complete iOS verification, regression checks, and language-addition documentation.

## Definition of done

- All app-owned production prose, including existing Danish copy, resolves through Localization or app-bundle resources derived from its source.
- Owner and anonymous participant flows render Danish on Danish- and English-configured devices.
- All existing domain codes, common auth/network failures, and unknown failures have Danish presentation; raw technical messages cannot override it.
- Push and in-app notification text is Danish with correct arguments and working navigation.
- Accessibility labels, app-owned permission explanations, dates, durations, plural counts, and decimal formatting follow the same language policy.
- User-authored content remains unchanged.
- A second test language can render a representative flow using resource additions and central locale registration, without editing feature code.
- Inventory items are resolved, resource checks and relevant iOS checks pass, and external/development-only exceptions are recorded.

## Acceptance tests

| ID | Preconditions and action | Expected result |
| --- | --- | --- |
| TC-1 | On an English-configured iOS device, launch, sign in as owner, create/edit an activity and session, invite, and submit participant feedback | App-owned labels, prompts, success states, and validation are Danish; account-free participant flow remains intact |
| TC-2 | Exercise every existing domain code, invalid/expired PIN, offline, timeout, auth failure, and unknown error using iOS tests; include an NSError carrying English text | Appropriate Danish message; raw English never overrides it; diagnostics remain available to developers |
| TC-3 | Remove profile fields; open settings, edit profile, deletion/cancel confirmations, and sign-out failure | Danish placeholders, explanations, actions, and alerts throughout |
| TC-4 | Render 0/1/many responses, one/multiple hours, same-day/multiday/all-day sessions, relative dates, and decimal scores | Correct Danish grammar and formatting with unchanged instants/time zones |
| TC-5 | Deliver feedback push to the foregrounded, backgrounded, and terminated app with English device preferences; open it | Danish title/body, correct arguments, working deep link |
| TC-6 | Inspect VoiceOver labels, charts, permission explanations, share/invite content, and privacy-policy link label | All app-owned text is Danish; externally hosted destination pages are outside this task |
| TC-7 | Simulate existing API 401/403, validation/conflict, 500, unknown-code, and malformed responses through iOS test doubles | Safe localized iOS presentation and appropriate recovery; API message text is not parsed or displayed |
| TC-8 | Use English user-authored session titles, questions, and feedback | Original data remains verbatim inside Danish UI |
| TC-9 | Introduce a missing key/mismatched placeholder; add a temporary second-language resource for a representative flow | Validation catches invalid resources; alternate text renders through the same interface |

Validation uses the repository's documented iOS tests/build, changed-line Swift lint, screenshot review, and relevant mobile journeys. Verify real push delivery separately from previews; record any unavailable delivery check explicitly. Phase 2 build, unit/resource checks, English-preference launch, and the native UI-inspection blocker are recorded in the [phase checklist](localization-phases.md).
