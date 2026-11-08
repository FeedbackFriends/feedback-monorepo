---
status: draft
areas: [backend, web, ios, tooling, docs]
created: 2026-11-08
updated: 2026-11-08
---

# Remove Zoho calendar-email processing

## Problem and outcome

Zoho receives calendar invitations for the old meeting-feedback experience. The new employee-improvement product does not need an incoming calendar mailbox. Remove that dependency and its user-facing calendar-email instructions without replacing it with another inbound-email service.

## Scope

- In scope: Stop receiving and processing calendar invitations through Zoho; remove the requirement to configure or operate Zoho; remove obsolete instructions and controls that ask users to email calendar invitations.
- Out of scope: Outbound login codes, leader invitation emails, product notifications, unrelated meeting-feature retirement, deletion of historical content, and closing external accounts or cancelling subscriptions without explicit authorization.

## Context

- Priority: 19 of 25. Remove the obsolete incoming-calendar dependency once replacement journeys and existing-user cutover are settled.

- Current behavior: Calendar invitations sent to LetsGrow create or update meetings in the old product experience.
- Background: The user confirmed that email polling is unnecessary for the new direction and requested a removal task on 2026-11-08.
- Related work: [Legacy retirement](20-shared-rebrand-legacy-retirement.md) owns the broader meeting-model retirement. This task owns Zoho removal and its calendar-email entry points; legacy retirement must not duplicate that work. [Platform consolidation](02-shared-platform-consolidation.md) covers outgoing email and push.
- Prerequisites: Settle when existing users stop relying on calendar-email integration; the current retirement plan waits for replacement web and employee journeys.

## Decisions and open questions

- Confirmed: Remove Zoho calendar-email processing; no replacement inbound mailbox is required for the new product.
- Assumptions: Outgoing email and push continue independently of Zoho.
- Unresolved: Removal timing, the message shown to existing calendar-integration users, whether any existing non-calendar use of the Zoho account must remain, and whether/when the external mailbox or subscription should be closed. Existing content is preserved unless a separate data decision authorizes otherwise.
- Refinement: Pending; clarify detailed feature requirements and overall architecture with the user.

## Acceptance criteria

- [ ] AC-1: LetsGrow operates without Zoho credentials or an active Zoho calendar mailbox.
- [ ] AC-2: Incoming calendar emails no longer create or change meetings after the agreed cutover.
- [ ] AC-3: Supported web and iOS journeys no longer direct users to add a LetsGrow address to calendar invitations.
- [ ] AC-4: Login-code emails, personal leader invitations and supported notifications continue to work.
- [ ] AC-5: Historical content remains intact, and affected users receive the agreed transition experience.
- [ ] AC-6: Operational instructions no longer require Zoho, and any external account closure remains separately authorized.

## Implementation plan

Pending refinement.

## Verification

Pending refinement.

## Human review

Not implemented yet. Implementation will record the change/flow, architectural decisions and tradeoffs, linked reading path, and verification limits here.

## Handoff

- Completed: Captured the user's request as a nontechnical draft.
- Verification results: Not run; task creation only.
- Blockers: None for refinement; implementation depends on settling the open questions.
- Next action: Refine removal timing and existing-user communication alongside legacy retirement; keep the removal scope separate from outbound messaging consolidation.
