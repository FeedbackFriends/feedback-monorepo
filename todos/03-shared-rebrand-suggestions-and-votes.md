---
status: draft
areas: [backend, ios, web]
created: 2026-11-06
updated: 2026-11-08
---

# Anonymous suggestions and votes

## Problem and outcome

The strategy's first two loop steps are "Foreslå anonymt" (suggest anonymously) and "Støt hinandens idéer" (support each other's ideas), in sections 6.1 and 6.2 of `lets-grow-strategi-teamtrivsel.md`.

Outcome:

- An employee submits an improvement suggestion to their team from iOS. The suggestion has a title or problem, an impact, and an optional solution. The employee can add a topic.
- Teammates support a suggestion anonymously.
- Leaders see the suggestions and support counts on web. They never see who submitted or supported.
- Inappropriate or identifying content can be flagged. Sensitive matters have a confidential path that does not publish to the team.

## Rebrand series (historical IDs)

The numeric references in this section and older planning notes are original rebrand IDs, not current backlog priorities. Current priority is the filename prefix. Rebrand 01 (coming-soon landing page) and 02 (teams/memberships) are already completed.

Scheduling: work-email login, owner onboarding and Firebase-auth replacement were completed on 2026-11-08, including native build and automated tests. Provider setup and live release checks remain described in [Supabase setup](../docs/agents/supabase-auth.md); platform consolidation is now the next numbered task.

Depends on **02** (teams and memberships). Feeds 04 (decisions), 06 (web dashboard), and 07 (iOS employee app). The coming-soon landing page (01) is implemented; product direction is documented in [the rebrand strategy](../docs/product/lets-grow-strategi-teamtrivsel.md).

## Scope

- In scope:
  - A backend suggestion model with three fields:
    - "Hvad vil du gerne forbedre?" (required)
    - "Hvad betyder det for arbejdsdagen?"
    - "Har du en idé til en løsning?" (optional)
  - A topic from a fixed list: fokus og arbejdsro, samarbejde, arbejdspres, kommunikation, møder, onboarding, and andet.
  - One anonymous support per member per suggestion. Members can withdraw their support.
  - An anonymity model:
    - Identity is never exposed in any API response to leaders or peers.
    - Counts are minimum-threshold aware for small teams.
    - The UI explains what is stored and who sees what.
  - Flagging a suggestion as inappropriate or identifying. The leader can hide it, and the hidden state is visible to the team.
  - A confidential path. A sensitive message goes privately to the team leader, or another designated recipient, and is never shown in the team feed or opened for voting.
  - iOS screens to write, browse, and support suggestions. A basic web leader list of suggestions with counts.
- Out of scope:
  - Decision and status workflow (04).
  - Merging duplicate suggestions into themes. This can come after the MVP, but leave room in the model.
  - Leader notifications for new suggestions. That decision belongs in 06.
  - Comments threads.

## Context

- Priority: 03 of 25. Deliver the core employee value and settle anonymity before building dependent workflows.

- Current behavior:
  - No suggestion concept exists.
  - `feedback.participant_id` stores the submitter's account ID next to each answer.
  - The manager-facing `QuestionResponseDto` omits it.
  - `EventDetailDto`/`ParticipantSummaryDto` in `backend/apps/api/src/main/kotlin/dk/example/feedback/service/ActivityMappings.kt` (around line 177) carry participant identity. They are unused and not in the contract.
- Reading path:
  - Strategy sections 6, 7, and 8.
  - Existing feedback persistence: `backend/lib/persistence/.../table/FeedbackTable.kt`.
  - The previous client-generated-ID idempotency pattern: `support_submission` (changeset 0026) and `todos/10-shared-in-app-product-feedback-and-bug-reports.md`.
- State/API flow and prerequisites:
  - Team membership from 02 authorizes every call.
  - The contract is regenerated through `./scripts/generate-api-artifacts.sh`.

## Decisions and open questions

- Confirmed:
  - Suggestions and votes are anonymous toward colleagues and leaders (strategy, section 7).
  - Votes are input to a decision, not an automatic ranking (strategy, section 6.2).
  - No person rankings, and no votes about specific colleagues.
- Assumptions:
  - **Storage.** The server stores the author's and voter's account IDs only to enforce one vote per member, to allow withdrawal and editing, and for moderation. They are never returned in any DTO. Document this in the API and persistence docs.
  - **Small teams.** For teams below a minimum size, for example 5 members, support counts are shown as a band or hidden until a threshold is met.
  - **Clear copy.** The UI states plainly that the content of a text can reveal the author (strategy, section 7).
- Unresolved:
  - **Anonymity guarantee.** Decide whether author and voter IDs are stored or only a salted hash per team. Decide how much an admin or database operator can see. This must be settled before the product promises anonymity in marketing (08).
  - **Minimum team size.** Decide the minimum team size and the count display rule.
  - **Confidential messages.** Decide who receives them: the team leader, a designated HR person, or a choice made by the employee.
  - **Moderation.** Decide who moderates flagged content (the team leader or LetsGrow), and whether hiding is reversible.
  - **Editing.** Decide whether an author can edit or delete their suggestion after others have supported it.
- Execution constraints:
  - Same as task 02.

## Acceptance criteria

- [ ] AC-1: A team member submits a suggestion from iOS with the required field, and it appears in the team feed. A client retry with the same submission ID does not duplicate it.
- [ ] AC-2: A member supports and unsupports a suggestion. Repeated supports count once.
- [ ] AC-3: No API response available to leaders or peers contains author or voter identity, and tests cover each DTO.
- [ ] AC-4: In a team below the threshold, counts are displayed according to the agreed rule.
- [ ] AC-5: A member flags a suggestion, and the leader can hide it. Hidden suggestions are not shown to members.
- [ ] AC-6: A confidential message reaches only its designated recipient and never appears in the team feed.
- [ ] AC-7: The leader sees all team suggestions with topic, support, and age on web.
- [ ] AC-8: Non-members cannot read or write a team's suggestions.

## Implementation plan

### Phase 1 — Backend model and anonymity boundary

- [ ] Add a Liquibase changeset with `suggestion`, `suggestion_support`, `suggestion_flag`, and `confidential_message`.
- [ ] Add services with team authorization, and DTOs without identity. Add idempotent create keyed by a client UUID.
- [ ] Remove or document the unused identity-bearing `EventDetailDto`/`ParticipantSummaryDto`, so no one reuses them by accident.
- [ ] Verification: API tests for AC-1 to AC-6 and AC-8, plus a DTO identity-leak test.

### Phase 2 — Contract and iOS employee flows

- [ ] Regenerate the artifacts, and add Domain models and a live adapter.
- [ ] Add a new feature module, for example `SuggestionsFeature`. It holds the write form with validation and an anonymity explainer, the feed with support toggle, a flag action, and the confidential message entry.
- [ ] Add localization in Danish and English, reducer tests, and catalog fixtures.

### Phase 3 — Web leader suggestion list

- [ ] Add a team suggestion list with filters by topic and newest or most supported, and a hide or restore action for flagged items.
- [ ] Verification: lint, build, and a Playwright journey.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1 | Team with a member (02) | Submit twice with the same ID | One suggestion exists |
| AC-2 | Existing suggestion | Support ×2, then unsupport | The count goes 1, then 1, then 0 |
| AC-3 | API tests | Serialize every leader and peer response | No account IDs appear |
| AC-4 | Team below the threshold | Load the feed | The display rule applies |
| AC-5 | Flagged suggestion | The leader hides it, then a member loads the feed | The suggestion is not shown |
| AC-6 | Confidential message | Load the feed and the recipient view | It is visible only to the recipient |
| AC-7 | Web E2E | Open the suggestions page | The list shows counts and topics |
| AC-8 | API tests | Call as a non-member | 403 |

## Human review

Not implemented yet.

## Handoff

- Completed: None.
- Verification results: Not run.
- Blockers: Task 02, and the anonymity decisions above.
- Next action: After 02, refine the anonymity storage model with the user, then start phase 1.
