# Plan: Employee-driven improvements

## Direction and scope

Follow the [LetsGrow product strategy](docs/shared/product/lets-grow-strategi-teamtrivsel.md): **Fra feedback til forbedring.**

Build the smallest complete improvement loop:

**Suggest → Support → Decide → Try → Evaluate → Share results.**

Employees participate in the existing iOS app. Leaders manage improvements on web. The backend owns permissions, lifecycle rules, and shared data. Success means visible decisions, meaningful follow-up, and improvements employees find useful—not participation counts alone.

This plan covers:

- **LG-001:** Let employees suggest improvements and support ideas anonymously in iOS.
- **LG-002:** Let leaders respond with a clear decision, explanation, responsible person, and follow-up date.
- **LG-003:** Let teams try small improvements, evaluate them, and decide whether to continue, adjust, or stop.
- **LG-004:** Give leaders a web workspace for suggestions, decisions, trials, and follow-ups without monitoring individual employees.
- **LG-005:** Rework iOS around employees: suggestions, active improvements, results, and evaluations.

These are delivery phases. The [foundation reference](docs/shared/product/improvement-loop.md#agreed-policies) records agreed privacy and lifecycle policies separately from current implementation. Remaining design choices must be settled before dependent work.

## Strategy constraints

- Allow employees to describe a problem without proposing a solution.
- Treat support as input to prioritization, never an automatic decision or a ranking of people.
- Give proposals a visible response, including when the answer is no or not now.
- Keep active trials few and concrete, with an owner and a follow-up date.
- Evaluate actual changes and publish the outcome, including trials that did not help.
- Protect anonymity beyond hiding names: consider metadata, small teams, access, and identifiable content.
- Include moderation. Confidential contact is explicitly excluded from this iteration; retain the warning against sensitive personal submissions. This is an agreed scope exception to the strategy’s first-release confidential-route requirement.
- Preserve distinct owner, invited-leader, and employee journeys.
- Send notifications only for meaningful updates, never solely to make employees reopen the app.
- Defer broad surveys, advanced HR reporting, employee web participation, Android, and heavy integrations.

## Progress

Checked items record completed implementation or agreed decisions, not a claim of live end-to-end verification. Phase 2 implementation, independent review, and required automated verification are complete. Native Xcode verification passed on 10 November 2026 using `Feedback Localhost`, the `UnitTests` plan, and the `LetsGrow Manager` iOS 27.2 simulator: build-for-testing succeeded and all eight suggestion adapter/reducer tests passed. Discovery included both `AppTests` and `InsightsTests` (249 enabled tests); only the eight relevant tests were run.

Phase 3 implementation, required automated verification, and independent review are complete. Trials extend Planned decisions with immutable plan revisions, responsible-person departure flags, web publication/overdue follow-ups, and iOS plan history. Remaining policy recommendations were authorized by the user on 10 November 2026 and are recorded in the foundation reference.

Phases 4–5 implementation, automated verification, and independent review are complete. Employees can evaluate concrete trials, leaders publish immutable outcomes, and both apps expose the full loop. Phase 6 automated checks and human-test preparation are complete; operational backup/restore verification and actual pilot commitments remain open below. No deployment, participant outreach, live push delivery, or live pilot loop was performed.

Verification on 10 November 2026: all 68 API tests passed, including 15 focused suggestion tests; the 15 suggestion tests passed again after final regression assertions. Persistence checks passed (zero tests); scheduler compiled (no tests). Web lint/build and all 21 team browser tests passed with two workers. Native `Feedback Localhost` / `UnitTests` on `LetsGrow Manager` iOS 27.2 passed all 277 test cases across `AppTests` and `InsightsTests`; localization, copy guard, and changed-line Swift lint passed with zero violations. Independent review identified and rechecked fixes for permanent push-token failures blocking delivery and unsupported evaluation timestamps crashing web rendering. Native Postgres concurrency was not exercised.

Retention deletion remains disabled: read-only Coolify inspection found no backup schedules for the healthy `feedback_db`. A maximum backup lifetime, coverage of external copies, and restore-before-serving purge must be verified before enabling deletion. Pilot ownership/capacity and a live full loop require actual participants; recommendations and human journeys are in the foundation reference.

## Phase 1 — Confirm the foundation and privacy rules

**Tasks:** LG-001; foundations for LG-002–005.

- [x] Review existing suggestions, support, withdrawal, reporting, membership, and authorization behavior before adding anything.
- [x] Finish LG-001 automated acceptance verification. Backend suggestion tests and web checks passed; native iOS build and all eight relevant tests passed on 10 November 2026. Live end-to-end acceptance remains human testing.
- [x] Confirm team boundaries and leader permissions for every operation.
- [x] Agree on stored identities, visible metadata, administrator access, retention, and small-team result protection.
- [x] Define moderation responsibilities and handling of sensitive or identifying content.
- [x] Record the agreed lifecycle and identify remaining transition details for suggestions, decisions, trials, evaluations, and results.

**Exit criteria:** Existing behavior and actual gaps are understood; privacy and lifecycle decisions are settled before dependent work.

## Phase 2 — Complete suggestions and leader decisions

**Tasks:** LG-001, LG-002; first increment of LG-004 and LG-005.

- [x] Complete verified gaps in anonymous suggestion submission and support, including hiding support counts below five and displaying only “5+ supporters” at or above five. Enforce this in API responses, not only the UI.
- [x] Give leaders a web inbox for suggestions from teams they manage.
- [x] Let leaders publish a decision, explanation, responsible person, and next follow-up date.
- [x] Show decisions and next steps alongside suggestions in iOS.
- [x] Explain declined or deferred ideas clearly; support counts must not determine the decision automatically.
- [x] Preserve understandable decision history when decisions change.

Verification:

- [x] Generate the OpenAPI contract and TypeScript/Swift clients.
- [x] Pass backend API checks, including seven focused suggestion tests covering privacy, authority, retries, revisions, and concurrent publication.
- [x] Pass web lint, production build, and all 19 team browser tests.
- [x] Pass iOS localization validation, localized-copy guard, and changed-line Swift lint (zero violations).
- [x] Complete independent review and resolve all three findings; corrections rechecked with no new findings.
- [x] Build iOS and run relevant native tests through Xcode. `Feedback Localhost` build-for-testing passed on the `LetsGrow Manager` iOS 27.2 simulator; `SuggestionAdapterTests` and `TeamSuggestionsTests` passed (8/8).

**Exit criteria:** An employee can suggest an improvement, colleagues can support it, and a leader can publish a response employees can read and understand.

## Phase 3 — Turn decisions into small trials

**Tasks:** LG-003; extend LG-004 and LG-005.

- [x] Let leaders turn a selected suggestion into a trial.
- [x] Record the concrete change, intended benefit, responsible person, trial period, and follow-up date.
- [x] Show active trials and next steps in iOS.
- [x] Give leaders an overview of active trials and overdue follow-ups.
- [x] Preserve the connection between the original suggestion, decision, and trial.
- [x] Encourage a manageable number of active trials without introducing an arbitrary hard limit unless agreed.

Verification on 10 November 2026:

- [x] Regenerate OpenAPI and TypeScript/Swift clients through the root script.
- [x] Pass all ten focused suggestion API tests, including current authority, private assignment metadata, date validation, retry behavior, owner departure, and distinct-actor concurrent trial publication. These exercise the migration and repository on H2. `:persistence:test` also completed successfully but contains zero tests.
- [x] Pass web lint and production build, all 20 team browser tests, and the focused trial test again after adding duplicate-name assignment coverage.
- [x] Pass native `Feedback Localhost` build on `LetsGrow Manager` iOS 27.2 and all ten suggestion adapter/reducer tests. `UnitTests` discovery includes both targets (251 enabled tests); only the ten relevant tests were run.
- [x] Pass localization validation, localized-copy guard, and changed-line Swift lint (zero violations).
- [x] Complete independent review; fix and recheck both findings (Postgres foreign-key lock inversion and indistinguishable same-name assignment choices).

Native Postgres concurrency and live end-to-end/manual journeys were not run. Publish the backend migration/API before clients requiring the additive `trials` response field. No new environment variables or services are required.

**Exit criteria:** Employees and leaders can see what is being tried, why, who owns it, and when it will be reviewed.

## Phase 4 — Evaluate and publish outcomes

**Tasks:** LG-003; extend LG-004 and LG-005.

- [x] Offer a short evaluation tied to a specific trial.
- [x] Prevent duplicate responses while preserving the agreed anonymity protections.
- [x] Display aggregate results only after at least five responses, with no live participation count.
- [x] Let leaders publish a decision to continue, adjust, or stop, with an explanation.
- [x] Make adjustments and subsequent trials traceable.
- [x] Publish the outcome even when participation is too low to display evaluation results.

**Exit criteria:** A team can complete the full improvement loop, and employees can see the outcome and reasoning.

## Phase 5 — Complete the employee and leader experiences

**Tasks:** LG-004, LG-005.

- [x] Consolidate iOS around suggestions, active improvements, results, and relevant evaluations.
- [x] Make the employee home screen show useful next actions and visible progress.
- [x] Consolidate web around unanswered suggestions, decisions, active trials, and follow-ups.
- [x] Provide clear empty, loading, error, and access-change states.
- [x] Keep reporting focused on team improvements; exclude individual participation tracking and employee rankings.
- [x] Coordinate legacy navigation with LG-018. Retiring old functionality or deleting existing data requires its separately agreed migration plan.

LG-005 evolves throughout phases 2–4; this phase consolidates the experience rather than postponing the employee redesign until the end.

**Exit criteria:** Employees and leaders can reach their core actions directly, with consistent statuses and terminology across both apps.

## Phase 6 — Verify and prepare the pilot

**Tasks:** LG-001–005 together.

- [x] Test lifecycle behavior, permissions, cross-team isolation, duplicate submissions, concurrent decision/trial publication, and anonymity protections. Evaluation/outcome tests cover editable answers, opening snapshots, deadline closure, private summaries, suppression, and linked adjustments. These use H2; native Postgres concurrency remains unverified.
- [x] Implement and test closure tracking, 24-month content/account-link purge, reopening protection, and permanent UUID-only retry receipts. Provide a daily scheduler disabled by default through `IMPROVEMENTS_RETENTION_ENABLED=false`.
- [ ] Verify maximum backup lifetime and restore-before-serving purge before enabling retention. Coolify currently has no database backup schedules; external/host copies and restore safety are not established. No production purge is enabled.
- [x] Verify generated API contracts and affected client integrations.
- [x] Run required backend, web, and native iOS automated checks in each implementation phase; this phase verifies the combined outcome.
- [x] Obtain independent review of substantive changes and resolve material findings.
- [x] Prepare human testing for submission, support, decisions, trials, evaluations, and published results. Run manual or visual checks only when explicitly requested.
- [ ] Agree on pilot leadership ownership, response expectations, and follow-up capacity.
- [x] Validate the complete loop with automated backend lifecycle tests and affected client tests before expanding reporting. A deployed or pilot loop remains human acceptance, not an automated-test claim.

**Exit criteria:** Required automated checks and independent review are complete; remaining limitations and human testing steps are explicit. Pilot readiness does not itself authorize deployment or participant outreach.

## Architecture and delivery

- Extend existing suggestion, membership, and authorization patterns where they fit.
- Keep lifecycle validation, authorization, and privacy enforcement in the backend.
- Generate API artifacts from backend definitions using `./scripts/shared/generate-api-artifacts.sh`; never edit generated artifacts manually.
- Deliver each phase across the backend and affected clients so it produces usable behavior.
- Follow each owning app's guidance and required verification.
- Reuse existing patterns rather than introduce speculative services or extension points.

## Decisions required before dependent implementation

- [x] Implement the agreed suggestion anonymity boundary and support-count threshold for phase 2.
- [ ] Complete operational backup expiry and restore verification for 24-month retention. Closure/purge/retry implementation and tests are complete; deletion stays disabled until this prerequisite is met.
- [x] Settle evaluation format, eligibility, response-editing rules, and membership changes: fixed short question, eligibility snapshot at opening, continued membership required, one editable response until closure; see the foundation reference.
- [x] Settle decision ownership: current team leaders or the organization owner; retain the public name after departure and require a current assignment on the next revision.
- [x] Settle trial ownership and what happens when the responsible person leaves: current leaders/owner; preserve public name, flag reassignment, and require a current owner on the next update.
- [x] Settle decision revisions: append immutable history with status, explanation, responsible name, follow-up date, and publication date.
- [x] Exclude confidential contact from this iteration; current authorized leaders and owners retain moderation responsibility.
- [x] Decide which meaningful updates warrant notifications: decisions, trial starts/material changes, evaluation openings and published outcomes; no engagement-only reminders. Implemented with generic localized push copy, current-member/token resolution, retry receipts, permanent-token cleanup, and no participation counters. Live delivery remains unverified.

## Pilot learning

Assess whether the loop identifies problems that otherwise go unheard, produces explained decisions and concrete changes, and helps employees feel their input makes a difference. Also assess whether leaders can sustain follow-up without ongoing help and whether customers want to pay to continue. Treat these as questions to validate, not established product claims.

Final review also refined notification classification: an unchanged revision of an ongoing plan is silent, while a subsequent trial after Adjust still notifies even when its plan fields repeat. Regression coverage distinguishes those cases.
