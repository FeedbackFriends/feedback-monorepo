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

Withdrawal or moderation removal replaces suggestion text with a content-free receipt and deletes support rows and decision content. The retained ID, team, and author association prevent delayed creation retries from republishing removed content. This is not deletion of every association. The schema nulls authorship and deletes support records when the referenced account is deleted; the retention implementation and its disabled operational gate are described below.

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

## Improvement lifecycle

Trial plans extend Planned decisions. Evaluations and outcomes now complete the loop. The policies below were authorized on 10 November 2026; the implementation and remaining operational limits are described in the following sections.

### Trials (phase 3)

A current team leader or organization owner can publish a trial from the latest Planned decision. A trial records the concrete change, intended benefit, public responsible name, inclusive start/end calendar dates, and follow-up date on or after the end. One suggestion has one active trial plan, with immutable newest-first revisions. Once a trial exists, ordinary suggestion decisions cannot contradict it; subsequent lifecycle decisions belong to the outcome workflow.

Trials use the same eligible responsible people as decisions. Unlike historical decisions, active trials retain an internal SHA-256 responsible-account fingerprint to detect departure. Employee responses never include it; this is a lookup fingerprint, not a claim of unlinkability from database operators. Departure preserves the public name, flags reassignment, and does not silently transfer responsibility. Every new revision requires a currently eligible responsible person; unchanged retries remain safe after departure. A deleted account is no longer eligible and therefore also triggers reassignment, without retaining a raw responsible-account ID. Withdrawal and moderation removal delete trial content along with decision history.

The fingerprint deliberately has no account foreign key: a publisher must not acquire a second account row lock after the suggestion lock. This preserves account-before-suggestion/assignment ordering when an owner concurrently removes the publishing leader. Publication is serialized by the suggestion lock, uses a client-generated retry UUID and normalized command fingerprint, and checks both the observed trial revision and latest decision ID. Web displays trial history, overdue follow-ups and the active-trial total, with guidance to keep few trials active rather than a hard limit. iOS displays trial plans and history through the existing membership-protected feed. Start dates are published plans; no background job silently changes their lifecycle status.

Deploy the backend migration/API before clients that require the new `trials` response field. Existing clients can ignore the additive field; the new iOS client requires the updated backend. No new runtime environment variables or services are introduced.

### Authorized recommendations for later phases

- Evaluations use one fixed question about whether the concrete change improved the working day, with Better / Unchanged / Worse / Cannot assess answers. Omit free-text employee comments in this iteration to reduce identifiable content and moderation burden.
- Snapshot eligible employees when evaluation opens. Continued current team membership is required to submit or edit; later joiners are excluded. Permit one editable response per eligible employee until a published closing deadline. Preserve already submitted responses after ordinary departure, with the same internal-account disclosure as suggestions; do not publish identities or individual responses.
- Publish aggregates once, after evaluation closure, only with at least five responses. Do not expose live participation counts, individual answers or breakdowns by employee groups. Suppress Cannot assess as a separate small subgroup; publish a single overall summary designed to avoid small-category disclosure. Exact release composition must be checked against concrete privacy tests during implementation.
- Leaders can publish Continue / Adjust / Stop with an explanation even when evaluation results are suppressed. Adjust starts a linked subsequent trial; preserve earlier plans and outcomes. Do not reopen a closed evaluation or alter its released results.
- Closed suggestions include Declined decisions without promised follow-up, published final outcomes, withdrawal and moderation removal. Reopening before retention expiry clears the retention deadline. Retention deletes content and account links 24 months after closure. Preserve only a content-free reserved UUID to reject delayed creation retries, without retaining author/team associations or command fingerprints. Implement this atomically with purge and retry checks before enabling deletion.
- Use an explicit maximum backup lifetime and purge restored data before serving it. No backup-expiry claim or destructive purge is enabled until the actual backup system and restore procedure have been verified.
- Meaningful notification candidates are a published decision, trial start or material plan change, evaluation opening, and published outcome. Send no support/submission counters or engagement-only reminders. Preserve privacy in lock-screen copy. Notification implementation must support recipients' current membership and existing opt-in rules.
- Keep existing legacy features and data while making improvement work directly reachable; coordinate retirement separately with LG-018. Pilot ownership and capacity remain operational commitments to confirm with actual pilot leaders; this authorization does not invent participants or permit outreach.

## Source and verification map

- Backend entry: `backend/apps/api/src/main/kotlin/dk/example/feedback/controller/SuggestionController.kt`.
- Authorization and persistence: `SuggestionRepo.kt`, `TeamRepo.kt`, and `SuggestionTables.kt` under `backend/lib/persistence/src/main/kotlin/dk/example/feedback/persistence/`.
- API behavioral coverage: `backend/apps/api/src/test/kotlin/dk/example/feedback/tests/SuggestionTest.kt`. Covers current-member access, response-field privacy, validation, retries, concurrent duplicate support, withdrawal, and scoped moderation on H2 in PostgreSQL compatibility mode.
- iOS feature: `ios-app/Modules/Sources/TabbarFeature/TeamSuggestions.swift` and `TeamSuggestionsView.swift`; reducer coverage in `Modules/Tests/AppTests/ReducerTests/Tabbar/TeamSuggestionsTests.swift` and adapter coverage in `Modules/Tests/AppTests/APIClientLiveTests/SuggestionAdapterTests.swift`.
- Web inbox and moderation: `web/src/components/teams/TeamSuggestions.tsx` and `web/src/components/teams/TeamSuggestionReports.tsx`; mocked browser coverage in `web/tests/teams.spec.ts`.

Existing test sources describe coverage intentions. Only an actual test run establishes a result for a checkout; H2 tests do not prove native Postgres locking, and mocked web tests do not prove the complete deployed boundary.


## Evaluations and outcomes (phases 4–5)

Leaders open one evaluation for the current immutable trial revision and publish a closing instant. Opening snapshots current employee account fingerprints without retaining account foreign keys. Current membership is required to answer or edit; late joiners are ineligible. An unchanged opening retry is safe. Answers are Better, Unchanged, Worse or Cannot assess; no employee text is collected. Opening an evaluation prevents further edits to its trial plan. Submission is an idempotent desired answer, with the same account-before-suggestion lock ordering as membership-protected mutations.

After the deadline, leaders publish Continue, Adjust or Stop with an explanation. This atomically freezes and releases the summary with the outcome. Before publication, closed evaluations say they await the leader's outcome; reading a feed does not change lifecycle state. Fewer than five answers releases only Insufficient responses. Otherwise, a strict majority of all answers choosing Better releases Improved; a strict majority choosing Worse releases Not improved; all other compositions release Mixed. Cannot assess is included in the denominator but never exposed as a category. No counts, percentages, group breakdowns, individual answers, eligibility list or account fingerprints are released. Only the caller can receive their own answer and eligibility. These coarse summaries reduce disclosure, but do not promise anonymity against knowledge of colleagues' responses.

Continue and Stop finish the trial. Adjust permits a subsequent plan revision; its predecessor's evaluation and outcome remain immutable and reference the exact prior trial ID. Historical plan revisions remain in order. The web workspace offers filters for unanswered suggestions, trials/follow-ups and results. The employee iOS team home exposes suggestions, work in progress and results directly, selecting active work when an evaluation is available. Legacy feedback remains accessible; no legacy data is retired.

## Retention implementation and operational gate

`closed_at` starts at a Declined decision without promised follow-up, a final Continue/Stop outcome, withdrawal or moderation removal. Reopening an ordinary decision clears it; Adjust leaves the suggestion open. Existing withdrawn receipts conservatively start their retention clock at migration time because their original closure time was never stored. Existing final Declined decisions use their latest publication time.

The daily UTC scheduler deletes closed suggestion content and all associations after 24 calendar months. A separate permanent receipt retains **only the UUID**. Creation and purge acquire its lock before the suggestion lock, so a delayed or concurrent creation retry cannot restore deleted content. Closure is rechecked under lock before deletion. Tests cover expiry, reopening and delayed retries.

Deletion is disabled by default. `IMPROVEMENTS_RETENTION_ENABLED=false` is passed to the scheduler by Compose; enable only after backup expiry and restore safety are verified. Recommended operational policy: backups expire within 30 days, including off-site copies and snapshots; restore into an isolated database, run retention before accepting traffic, and verify expired content and associations are absent while UUID receipts still reject retries. This recommendation is not evidence that the infrastructure enforces it.

Read-only Coolify inspection on 10 November 2026 found the Lets Grow `feedback_db` healthy with **no configured Coolify database backup schedules**. External or host-level backups and their expiry were not established; no restore rehearsal was performed. Production deletion remains disabled. Setting up backups, proving expiry and rehearsing restore remain operational prerequisites, not completed work.

## Meaningful notifications

New decisions, trial starts/material plan changes, evaluation openings and outcomes enqueue generic team updates in the same transaction. Submission, support and evaluation answers do not notify. Publication retries return before enqueueing again. The scheduler resolves current membership and registered FCM tokens at dispatch. Queue records contain no employee content or participation counters; withdrawal/removal deletes pending updates. APNs copy is localized and generic, and taps refresh authenticated team context rather than restoring queued content. Existing device notification permission and token-registration behavior remains the opt-in boundary.

Delivery is at least once: a transient failure retains the queue for retry, and the stable APNs collapse identifier reduces duplicate pending alerts. Unregistered, malformed and wrong-project tokens are removed and do not block the queue. Membership is checked when dispatch selects recipients; revocation after that selection cannot retract an already-sent generic alert. Push transport and physical-device delivery are not established by unit tests.

## Pilot handoff

Before inviting a pilot, name a leader with decision authority, agree a response expectation (recommend a first explained response within seven days), and reserve time for one or two active trials and their follow-ups. These are proposed commitments for actual pilot leaders, not invented agreements. No deployment or outreach is authorized by this guide.

Human acceptance should exercise: employee submission without a solution; colleague support and reporting; leader decision and trial; evaluation opening; eligible employee answer/edit; late-joiner rejection; closure and published Continue/Adjust/Stop; linked adjustment; low-participation suppression; departed-member access denial; and notification navigation. Include a complete loop with at least five test employees and a separate small-sample loop. Inspect Danish/English copy, loading/error/empty states, and device notification preferences. Live acceptance and a real pilot loop remain unverified until performed.


### Rollout and verification limits

Publish backend migrations/API before either new client. The new iOS decoder requires the additive `trials`, `evaluations` and `outcomes` arrays; older clients can ignore new fields. New scheduler code also requires migrations 0034–0036 before processing improvements. There are no new services or ports. Compose passes only one new switch, `IMPROVEMENTS_RETENTION_ENABLED`, defaulting to false; do not turn it on as part of a routine release.

Automated verification on 10 November 2026: full API suite 68/68, including 15 suggestion tests; final focused suggestion rerun 15/15; persistence task completed with zero tests; scheduler compilation passed with no test sources. Web lint/build and 21 team browser tests passed (two workers). Native `Feedback Localhost`, `UnitTests`, `LetsGrow Manager` iOS 27.2: 277/277 test cases across both targets, plus localization/copy checks and zero changed-line SwiftLint violations. Fresh independent review found two issues (permanent token retry poisoning and out-of-range evaluation dates); both were fixed and source-rechecked. Automated tests do not establish live FCM/APNs delivery, native Postgres concurrency, backup expiry, a safe production restore or a pilot outcome.

Final review also refined notification classification: an unchanged revision of an ongoing plan is silent, while a subsequent trial after Adjust still notifies even when its plan fields repeat. Regression coverage distinguishes those cases.
