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

Checked items record completed implementation or agreed decisions, not a claim of live end-to-end verification. Phase 2 implementation and independent review are complete; phase 2 remains open until the required native iOS build and tests pass. Xcode workspace opening currently times out, so those checks are blocked.

Next: finish native iOS verification, then phase 3 (small trials). Settle trial ownership and departure behavior before implementing trials.

## Phase 1 — Confirm the foundation and privacy rules

**Tasks:** LG-001; foundations for LG-002–005.

- [x] Review existing suggestions, support, withdrawal, reporting, membership, and authorization behavior before adding anything.
- [ ] Finish LG-001 acceptance verification. Backend suggestion tests and web checks passed; required native iOS build and tests remain blocked by Xcode workspace opening.
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
- [ ] Build iOS and run relevant native tests through Xcode. Blocked: opening the project times out waiting for its initial run destination; no workspace becomes available.

**Exit criteria:** An employee can suggest an improvement, colleagues can support it, and a leader can publish a response employees can read and understand.

## Phase 3 — Turn decisions into small trials

**Tasks:** LG-003; extend LG-004 and LG-005.

- [ ] Let leaders turn a selected suggestion into a trial.
- [ ] Record the concrete change, intended benefit, responsible person, trial period, and follow-up date.
- [ ] Show active trials and next steps in iOS.
- [ ] Give leaders an overview of active trials and overdue follow-ups.
- [ ] Preserve the connection between the original suggestion, decision, and trial.
- [ ] Encourage a manageable number of active trials without introducing an arbitrary hard limit unless agreed.

**Exit criteria:** Employees and leaders can see what is being tried, why, who owns it, and when it will be reviewed.

## Phase 4 — Evaluate and publish outcomes

**Tasks:** LG-003; extend LG-004 and LG-005.

- [ ] Offer a short evaluation tied to a specific trial.
- [ ] Prevent duplicate responses while preserving the agreed anonymity protections.
- [ ] Display aggregate results only after at least five responses, with no live participation count.
- [ ] Let leaders publish a decision to continue, adjust, or stop, with an explanation.
- [ ] Make adjustments and subsequent trials traceable.
- [ ] Publish the outcome even when participation is too low to display evaluation results.

**Exit criteria:** A team can complete the full improvement loop, and employees can see the outcome and reasoning.

## Phase 5 — Complete the employee and leader experiences

**Tasks:** LG-004, LG-005.

- [ ] Consolidate iOS around suggestions, active improvements, results, and relevant evaluations.
- [ ] Make the employee home screen show useful next actions and visible progress.
- [ ] Consolidate web around unanswered suggestions, decisions, active trials, and follow-ups.
- [ ] Provide clear empty, loading, error, and access-change states.
- [ ] Keep reporting focused on team improvements; exclude individual participation tracking and employee rankings.
- [ ] Coordinate legacy navigation with LG-018. Retiring old functionality or deleting existing data requires its separately agreed migration plan.

LG-005 evolves throughout phases 2–4; this phase consolidates the experience rather than postponing the employee redesign until the end.

**Exit criteria:** Employees and leaders can reach their core actions directly, with consistent statuses and terminology across both apps.

## Phase 6 — Verify and prepare the pilot

**Tasks:** LG-001–005 together.

- [ ] Test lifecycle behavior, permissions, cross-team isolation, duplicate submissions, concurrent updates, and anonymity protections.
- [ ] Implement and verify retention enforcement: delete suggestion content and account links 24 months after closure, account for backup expiry, and preserve safe retry behavior. Do not purge data until closure and receipt semantics are defined.
- [ ] Verify generated API contracts and affected client integrations.
- [ ] Run required backend, web, and native iOS automated checks in each implementation phase; this phase verifies the combined outcome.
- [ ] Obtain independent review of substantive changes and resolve material findings.
- [ ] Prepare human testing for submission, support, decisions, trials, evaluations, and published results. Run manual or visual checks only when explicitly requested.
- [ ] Agree on pilot leadership ownership, response expectations, and follow-up capacity.
- [ ] Validate at least one complete loop before expanding dashboards or reporting.

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
- [ ] Design and implement 24-month post-closure retention, including backup expiry and safe retry receipts.
- [ ] Settle evaluation format, eligibility, response-editing rules, and behavior when team membership changes.
- [x] Settle decision ownership: current team leaders or the organization owner; retain the public name after departure and require a current assignment on the next revision.
- [ ] Settle trial ownership and what happens when the responsible person leaves.
- [x] Settle decision revisions: append immutable history with status, explanation, responsible name, follow-up date, and publication date.
- [x] Exclude confidential contact from this iteration; current authorized leaders and owners retain moderation responsibility.
- [ ] Decide which meaningful updates warrant notifications.

## Pilot learning

Assess whether the loop identifies problems that otherwise go unheard, produces explained decisions and concrete changes, and helps employees feel their input makes a difference. Also assess whether leaders can sustain follow-up without ongoing help and whether customers want to pay to continue. Treat these as questions to validate, not established product claims.
