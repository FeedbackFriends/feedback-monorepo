---
status: draft
areas: [web, ios, backend, tooling]
created: 2026-11-07
updated: 2026-11-07
---

# Simple work-email login, owner onboarding, and replacement of Firebase

## Problem and outcome

Owners and team leaders currently need Google to start using LetsGrow on web. This creates friction for people whose work email is not connected to Google. Owners also need a clear self-service path from the website to their first team.

Provide one simple login entry using work email and a one-time code, with Google as an alternative. New owners can create their organization and first team; invited leaders arrive directly in their assigned team. Replace Firebase as the login provider in the same task, while preserving existing users' access and the simple employee experience.

## Scope

- In scope:
  - One shared login entry for owners and leaders, without asking users to choose their role.
  - Work-email verification with a one-time code and Google as an alternative.
  - Website “Kom i gang” leading to the application at `app.letsgrow.dk`.
  - New-owner onboarding collecting name, organization name, and first team name; the creator becomes owner automatically.
  - Existing users returning to their organization after login.
  - Invited leaders confirming the invited email and entering their assigned team, without creating an organization.
  - Sending personal leader invitations by email rather than requiring the owner to share each link manually.
  - Replacing Firebase login across the affected web, iOS, and backend experience.
  - Preserving existing accounts, organization ownership, team memberships, leader access, and associated content during the transition.
  - Preserving employees' ability to join and use the iOS app without being forced through owner signup.
- Out of scope:
  - Additional administration roles, billing, or enterprise account-management features.
  - Automatically granting organization access based on a shared email domain.
  - Unrelated changes to product functionality or storage.

## Context

- Current behavior: Owner signup and leader-invitation acceptance require Google. Owners manually share personal leader invitation links. Employees use the iOS app and have a separate team-joining experience.
- Background: The user approved the shared login and owner-onboarding flow in the conversation on 2026-11-07, then requested a new task and replacement of Firebase in the same scope. They proposed an alternative provider for consideration during refinement; no replacement is selected yet.
- Prerequisites: Preserve the implemented organization ownership, team-scoped leadership, and employee membership behavior from task 02, closed at the user's request on 2026-11-07. Team authority remains determined by current stored ownership and membership, independently of the login provider. Existing architectural guidance: [backend](../backend/docs/agents/architecture.md), [web authentication](../web/docs/agents/api-and-auth.md), and [iOS](../ios-app/Docs/agents/architecture.md).
- Priority: This is now the next task, ahead of [03](03-rebrand-suggestions-and-votes.md) and the remaining rebrand feature tasks. Its next step is refinement, not implementation.
- Verification carried forward from 02: Implementation passed 48 backend API tests, 27 mocked browser tests, and 261 native tests, plus web lint/build and Swift lint. All 71 captured iOS catalog images were reviewed. These results do not establish real identity-provider integration or the complete live web-to-iOS membership journey. Native interactive verification was blocked by Xcode's device interaction session reporting “Session not found” after successful setup/launch. Resolve that tooling limitation before relying on live acceptance evidence. Existing Google-specific live acceptance was not verified; verify the supported identity flows selected in this task instead.

## Decisions and open questions

- Confirmed:
  - Replace Firebase login in the same scope as the improved login and owner onboarding.
  - Work email plus a one-time code is the common entry; Google remains an alternative.
  - Users do not choose an owner or leader role at login. Their existing access or invitation determines the destination.
  - A new organization creator becomes its owner and creates the first team during onboarding.
  - A leader invitation leads to the assigned team rather than organization creation.
  - Organization access is not granted automatically from email domain.
  - Keep the experience simple and avoid optional features.
- Assumptions: Existing users should retain access and content without creating replacement accounts manually.
- Unresolved:
  - Which replacement provider best meets the agreed needs, and its operating cost and maintenance requirements.
  - How existing users and anonymous employees experience the transition, including sessions on already-installed apps.
  - How to handle a work email previously used through Google so the person keeps one account.
  - Email delivery, code expiry, resend, and recovery behavior.
  - The simplest path for a person who signs in before opening their invitation, or already belongs to another team.
- Refinement: Pending; clarify detailed feature requirements and overall architecture with the user. Evaluate the user's proposed provider alongside credible alternatives before selecting one.

## Acceptance criteria

- [ ] AC-1: A new owner can start from the website and use their work email and a one-time code without requiring a Google account or choosing a role.
- [ ] AC-2: After entering their name, organization, and first team, the new owner lands in that team with owner access.
- [ ] AC-3: An existing owner or leader returns to their authorized organization and teams after login without repeating onboarding.
- [ ] AC-4: An owner can send a personal leader invitation by email; the recipient confirms the invited address and lands in the assigned team with only the intended access.
- [ ] AC-5: Google remains an alternative login path, and using the same verified work email does not produce separate, disconnected accounts.
- [ ] AC-6: An unrelated person sharing an email domain cannot gain access without an invitation.
- [ ] AC-7: Expired or invalid codes, wrong-account invitations, resend, and interrupted signup have clear Danish recovery paths without granting unintended access.
- [ ] AC-8: Following the agreed transition, supported web and iOS journeys work without Firebase login, and existing users retain their content, ownership, and team access.
- [ ] AC-9: Employees can still join and use their team in the iOS app without owner onboarding or a mandatory Google account.
- [ ] AC-10: Removing a leader or revoking an invitation continues to prevent access through either supported login path.
- [ ] AC-11: A live employee journey works across web and iOS: team link and manual code entry, name submission, waiting state, owner approval/rejection, refresh/resume/relaunch, cancellation/leaving, and removal. Invalid or rotated codes and temporary fetch errors show recovery without silently granting or switching access. Legacy event links still open their separate flow while supported.

## Implementation plan

Pending refinement.

## Verification

Pending refinement.

## Human review

Not implemented yet. Implementation will record the change/flow, architectural decisions and tradeoffs, linked reading path, and verification limits here.

## Handoff

- Completed: Captured the approved product flow, Firebase replacement requirement, and next-task priority. Task 02 was closed at the user's request; its outstanding live acceptance checks are explicitly carried forward here rather than reported as passed.
- Verification results: Not run; task creation only.
- Blockers: No provider or transition approach selected; these must be resolved during refinement.
- Next action: Refine this task with the user before 03, evaluate Supabase (the user's proposed candidate) and alternatives, and settle the account transition and overall architecture. Include the carried-forward live membership and identity checks in the verification plan.
