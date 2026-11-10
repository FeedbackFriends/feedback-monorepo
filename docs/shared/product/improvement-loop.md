# Improvement loop: current foundation

The [product strategy](lets-grow-strategi-teamtrivsel.md) governs the intended improvement loop. This reference distinguishes current implementation boundaries from the agreed policies below. It does not establish a launch-ready anonymity guarantee.

## Existing suggestion flow

Approved employees open suggestions from `Mit team` in iOS. Problem and impact are required; a proposed solution is optional. Each text field has a 1,000 UTF-16-code-unit API limit. The backend trims inputs and rejects blank required fields. Suggestions are shared with the team immediately.

Employees can add or remove support, withdraw their own suggestion, and report content. Reporting sets a content flag; it does not hide the suggestion automatically. Organization owners and the team's assigned leader can review reported content on web and keep or remove it. Each managed team on web now has a suggestion inbox and a decision workflow alongside moderation. Employees read responses with suggestions in iOS.

## Access and ownership

- Suggestion listing, creation, support, withdrawal, and reporting require current team membership. A legacy Manager role does not grant participation.
- Withdrawal additionally requires authorship.
- Report review and moderation require current organization ownership or assignment as the team's leader.
- The backend checks database authority on requests. Account locks serialize employee mutations with membership removal; suggestion locks serialize support/report operations with withdrawal and moderation.
- iOS discards suggestion state and drafts when membership changes. Failed requests clear the feed; responses for a different team are ignored.

## Privacy boundary

The database retains author account links and supporter account links. This supports ownership and duplicate prevention; it is not technically unlinkable participation from database operators.

Employee responses contain suggestion text, an opaque suggestion ID, a five-supporter threshold flag, and caller-specific `mine` and `supportedByMe` flags. They do not include another employee's identity or submission timestamps. Report-review responses contain only suggestion IDs and text; reports retain no reporter identity, reason, or timestamp.

The iOS privacy explanation in Danish and English already discloses stored account links, the risk of identification through wording or small-team context, and that sensitive personal concerns should not be submitted here. API responses omit exact support counts. Below five supporters, neither app displays a count; at five or more, they display only “5+ supporters” (Danish: “5+ støtter”). Observing threshold crossings can still reveal participation; this is a risk reduction, not an anonymity guarantee.

Withdrawal or moderation removal replaces suggestion text with a content-free receipt and deletes support rows and decision content. The retained ID, team, and author association prevent delayed creation retries from republishing removed content. This is not deletion of every association. The schema nulls authorship and deletes support records when the referenced account is deleted; no suggestion-specific retention schedule is defined here.

## Retry and concurrency behavior

Creation uses a client-provided UUID. Retrying the same ID and normalized content returns the existing result; changed content conflicts. Reusing another author's ID is forbidden. Support is a desired boolean state, with one database row per suggestion/account pair. Repeated withdrawal is safe, while subsequent creation retries cannot restore the removed content.

These are source-level guarantees and focused test coverage, not a full production Postgres concurrency audit.

## Agreed policies

The following decisions were agreed on 10 November 2026. They define intended behavior; they are not all implemented yet.

- Retain internal account links for ownership and duplicate prevention. Explain that identities are hidden from colleagues and leaders, while LetsGrow retains database associations. Do not promise anonymity from database operators.
- Hide support counts below five supporters. At five or more, display only “5+ supporters”, never an exact live count. Threshold crossing and authored content can still reveal information; this reduces risk rather than guarantees anonymity.
- Publish evaluation aggregates only after at least five responses, without a live participation count. Result composition and release rules still need care to avoid exposing individuals.
- Keep moderation with current authorized team leaders and organization owners.
- Exclude confidential contact from this iteration, as explicitly requested. Preserve the existing warning against sensitive personal submissions. This is a scoped departure from the strategy's first-release confidential-route requirement, not a claim that the current warning provides such a route. LG-024 remains deferred.
- Retain suggestion data for 24 months after closure, then delete content and account links. Backup expiry must also be covered. Closure timestamps, retry-receipt treatment, and backup enforcement must be designed with the implementation so deletion cannot accidentally republish withdrawn content. This does not authorize an immediate purge.
- Use Received → Reviewing → Planned → Trying → Completed, with Deferred and Declined alternatives. Require explanations for decisions and an owner and date whenever follow-up is promised. Trial outcomes are continue, adjust, or stop.

## Leader decisions (phase 2)

Current organization owners and assigned team leaders can publish Reviewing, Planned, Deferred, or Declined responses. A suggestion without a response is Received. Trying and Completed belong to later trial and outcome phases. Support never selects a response automatically.

Every response includes an explanation and a responsible person selected from the team's current leaders and organization owner. The leader supplies the public name explicitly; employees receive that snapshot, never the account ID. Reviewing, Planned, and Deferred require a calendar follow-up date; Declined may include one when further follow-up is promised. Dates use ISO calendar dates and may represent overdue work.

Revisions append immutable, newest-first history with the status, explanation, public responsible name, follow-up date, and publication time. A departed responsible person's name remains in history; every new revision requires a currently eligible assignment. Withdrawal and moderation removal remove the history with the suggestion content.

Decision storage retains the public name and a SHA-256 fingerprint of the normalized, length-prefixed command instead of a historical account link. Management-only assignment choices include recognizable names or email addresses; employee responses never include those addresses.

Publication uses a client-generated UUID for unchanged retries and the last observed revision for concurrency protection. A stale revision conflicts instead of overwriting another response. Publication locks the suggestion and validates current authority; assignment validation locks the leadership row to serialize with removal. Current authorized leaders may retry an already published response after assignment departure without publishing it again.

The API change replaces `supportCount` with `hasFiveSupporters`; backend, web, and iOS artifacts must ship together. Previously installed iOS clients expecting `supportCount` need updating; no exact-count compatibility field is retained because it would violate the privacy rule.

## Remaining implementation design

Trial, evaluation, and published-result models do not exist yet. Evaluation format and eligibility, response editing, trial owner departure, and retention enforcement details must be resolved before dependent implementation. These do not reopen the agreed policies above.

## Source and verification map

- Backend entry: `backend/apps/api/src/main/kotlin/dk/example/feedback/controller/SuggestionController.kt`.
- Authorization and persistence: `SuggestionRepo.kt`, `TeamRepo.kt`, and `SuggestionTables.kt` under `backend/lib/persistence/src/main/kotlin/dk/example/feedback/persistence/`.
- API behavioral coverage: `backend/apps/api/src/test/kotlin/dk/example/feedback/tests/SuggestionTest.kt`. Covers current-member access, response-field privacy, validation, retries, concurrent duplicate support, withdrawal, and scoped moderation on H2 in PostgreSQL compatibility mode.
- iOS feature: `ios-app/Modules/Sources/TabbarFeature/TeamSuggestions.swift` and `TeamSuggestionsView.swift`; reducer coverage in `Modules/Tests/AppTests/ReducerTests/Tabbar/TeamSuggestionsTests.swift` and adapter coverage in `Modules/Tests/AppTests/APIClientLiveTests/SuggestionAdapterTests.swift`.
- Web inbox and moderation: `web/src/components/teams/TeamSuggestions.tsx` and `web/src/components/teams/TeamSuggestionReports.tsx`; mocked browser coverage in `web/tests/teams.spec.ts`.

Existing test sources describe coverage intentions. Only an actual test run establishes a result for a checkout; H2 tests do not prove native Postgres locking, and mocked web tests do not prove the complete deployed boundary.
