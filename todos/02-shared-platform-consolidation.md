---
status: draft
areas: [backend, web, ios, tooling, docs]
created: 2026-11-08
updated: 2026-11-08
---

# Consolidate database, messaging, analytics and monitoring

## Problem and outcome

LetsGrow should use as few operational tools as practical. The user wants managed Supabase Postgres and prefers a small shared toolset for web and mobile analytics, errors, email and push. Sentry is currently installed but is not a platform the user likes or regularly checks. Consolidate responsibilities into tools the user will actually use while retaining useful diagnostics and reliable delivery.

## Scope

- In scope: Move product database hosting to managed Supabase; establish shared web/mobile analytics and error visibility through PostHog; evaluate OneSignal as the shared outbound email/push platform, including login-code delivery; retire superseded Sentry and Firebase reporting/messaging once replacement coverage is verified; retain useful built-in Xcode crash investigation.
- Out of scope: Replacing the product backend, unrelated product features, employee re-engagement campaigns, collecting anonymous feedback content for analytics, deleting existing product data, or purchasing/deploying/cancelling external services without explicit authorization.
- Related removal: Zoho calendar-email retirement belongs to [its separate task](19-shared-remove-zoho-calendar-email.md).

## Context

- Priority: 02 of 25. Settle database, delivery and monitoring foundations before adding more product integrations; this does not authorize a production cutover.

- Current behavior: Product data is hosted separately from managed authentication; iOS initializes both Sentry and Crashlytics and uses Firebase push delivery. Outgoing login and product emails need a delivery provider.
- Background: Discussion on 2026-11-08 established a preference for Supabase + PostHog + OneSignal as the target small toolset, with Xcode supplying additional native crash reports. The user explicitly agreed with moving Postgres to Supabase and emphasized minimizing tools.
- Related work: shared authentication and owner onboarding is implemented and completed. Native build-for-testing and all 264 unit tests passed on 2026-11-08; backend/web evidence was already passing. Use [Supabase setup and cutover](../docs/agents/supabase-auth.md) for the remaining provider configuration and manual release checks. Do not duplicate the completed auth implementation.
- Prerequisites: Validate provider suitability and settle the existing-data transition and release timing before changing live services.

## Decisions and open questions

- Confirmed: Use as few tools as practical; move Postgres hosting to managed Supabase. Evaluate monitoring against the user's actual workflow rather than retaining Sentry by default.
- Proposed direction: Supabase for authentication and product data; PostHog for web/mobile analytics and application errors; OneSignal for outbound email and push; Xcode for deeper native crash investigation. OneSignal and replacement monitoring remain subject to refinement and coverage validation, not final provider approval.
- Assumptions: Existing product content should be preserved during a hosting move. The earlier decision to start fresh for login identities is not permission to delete the product database.
- Unresolved: Whether OneSignal can suitably deliver Supabase login codes as well as invitations and push; final messaging provider choice and operating costs; acceptable native diagnostic coverage when replacing Sentry/Crashlytics; which analytics questions/events are needed; privacy boundaries for anonymous employees; alert destination/frequency; hosting region, backups, release timing and recovery expectations.
- Constraints: Preserve employee anonymity. Do not send feedback text, invitation tokens or employee-to-anonymous-contribution links to analytics or monitoring.
- Refinement: Pending; clarify detailed feature requirements and overall architecture with the user.

## Acceptance criteria

- [ ] AC-1: Product data runs on managed Supabase with existing content preserved and an agreed recovery path.
- [ ] AC-2: A shared web/mobile analytics view answers the agreed onboarding and usage questions without exposing anonymous employee contributions.
- [ ] AC-3: Relevant application errors reach the chosen monitoring tool and actionable alerts reach a destination the user uses; native diagnostic limits are understood and accepted.
- [ ] AC-4: The chosen shared messaging approach delivers login codes, personal invitations and supported push notifications, with usable delivery visibility and failure recovery.
- [ ] AC-5: Sentry, Crashlytics and Firebase messaging are retired only where their replacement coverage is verified; any retained tool has an explicit reason.
- [ ] AC-6: Supported flows work through the agreed transition, and setup/operating guidance describes the final small toolset.
- [ ] AC-7: Costs, provider dependencies and residual external-account cleanup are explicit; production changes and account cancellations receive separate authorization.

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
- Next action: Refine OneSignal login-email suitability, monitoring coverage and analytics/privacy requirements; confirm the target toolset and database transition before implementation.
