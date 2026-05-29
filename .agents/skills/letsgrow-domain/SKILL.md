---
name: letsgrow-domain
description: LetsGrow domain guidance for product, UX, marketing, positioning, onboarding, and project terminology. Use when an agent is designing, writing, reviewing, or prioritizing LetsGrow work that must fit the Danish feedback-after-meetings product, landing-page language, and Activity/Event domain model.
---

# LetsGrow Domain

## Use This First

LetsGrow is a Danish-first app for honest feedback after meetings, workshops, talks, and similar activities.

The current landing page in `web/src/components/landing` is the source of truth for public positioning and tone. Its core message is:

- `Bliv klogere på hvad der virker`
- get honest feedback after `møder, workshops, oplæg og andre aktiviteter`
- see patterns, adjust along the way, and get better at what actually makes a difference
- plan in the calendar as usual, invite a generated LetsGrow email for the activity, let participants answer from mobile, and see what actually worked

Latest landing-page language audit: 2026-05-29.

The public copy is meeting-led but activity-capable. It uses `møder` as the most concrete everyday wedge, then broadens to `workshops`, `oplæg`, and `andre aktiviteter` where scope matters. Do not flatten this into generic feedback, and do not narrow it back to only recurring meetings unless the user explicitly asks for a repositioning.

Strategic niche: repeatable formats run by the same owner. A workshop, talk, training session, team meeting, or coding session may be one-off for the participants, but it should be recurring or repeatable for the owner so LetsGrow can show patterns and improvement over time.

The product should feel lightweight, concrete, Danish, and practical. It should not feel like a heavy survey builder, HR suite, employee engagement program, or generic productivity dashboard.

This skill is the markdown source of truth for LetsGrow domain, launch messaging, account strategy, onboarding, and commercial direction. The implemented landing page is the source of truth for current public wording and should be analyzed before changing this skill again.

## Load References Only When Needed

- Audience, ICP, JTBD, and positioning: [references/audience-positioning.md](references/audience-positioning.md)
- Product UX, onboarding, roles, workspace, and activation: [references/product-ux-guidance.md](references/product-ux-guidance.md)
- Website copy, Danish messaging, CTAs, pricing, and commercial model: [references/messaging-commercial.md](references/messaging-commercial.md)
- Code/API/domain terms such as `Activity`, `Event`, `Session`, and `ParticipantEvent`: [references/domain-language.md](references/domain-language.md)

## Strategic Filter

Before proposing a feature, flow, screen, campaign, or copy change, check whether it:

1. Helps someone learn what worked after a meeting, workshop, talk, or activity.
2. Reduces friction around collecting honest feedback immediately afterwards.
3. Makes patterns over time or across activities clearer.
4. Keeps participants account-free and low effort.
5. Fits a Danish-first, practical product that starts through familiar calendar workflows.
6. Avoids sounding like an HR platform, generic survey tool, or abstract self-improvement app.

If the answer is no, challenge the work and propose a tighter version anchored in post-activity feedback and visible improvement.

## Defaults

- Market: Denmark first.
- Customer-facing language: plain Danish unless asked otherwise.
- Primary landing-page CTA: `Hent på App Store` / `Hent appen`.
- Secondary CTA: `Se hvordan det virker`.
- Offer framing: `Prøv det helt gratis`.
- Setup mechanic: plan in existing calendar tools and invite the generated LetsGrow email for the activity.
- Email-based event/session creation is part of the MVP direction. The backend generates a deterministic email address for each activity, for example a short-code address such as `1234@letsgrow.dk`, and calendar invites sent to that address create sessions/events for that specific activity.
- Supported calendar signals shown publicly: Microsoft Teams, Outlook, Google Calendar, Apple Calendar, Zoho Calendar, Proton Calendar.
- Onboarding: app-first unless a future operating model reintroduces founder-assisted pilots.
- Account model: one workspace per company or team.
- First user: workspace owner, usually also the first meeting/activity owner.
- Participants: answer feedback without accounts.
- Activation: one real meeting/activity configured, first participant responses received, and useful feedback visible.

## Output Shape

Be concrete enough for a designer, product manager, or engineer to act on. Include:

- the target user
- the primary job the experience must solve
- the desired behavioral outcome
- what to include
- what to avoid
- suggested Danish UX or marketing copy when relevant
