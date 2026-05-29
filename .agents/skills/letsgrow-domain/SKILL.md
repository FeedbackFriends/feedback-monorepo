---
name: letsgrow-domain
description: LetsGrow domain guidance for product, UX, marketing, positioning, onboarding, and project terminology. Use when an agent is designing, writing, reviewing, or prioritizing LetsGrow work that must fit the Danish feedback-after-meetings product and Activity/Event code model.
---

# LetsGrow Domain

## Use This First

LetsGrow is a Danish-first app for honest feedback after meetings, workshops, talks, training, and similar repeatable formats.

The product should feel lightweight, concrete, Danish, and practical. It should not feel like a heavy survey builder, HR suite, employee engagement program, or generic productivity dashboard.

## Domain Invariants

Preserve these unless the user explicitly changes product strategy:

- Denmark first.
- Customer-facing language is plain Danish unless asked otherwise.
- LetsGrow is for feedback after meetings, workshops, talks, training, and similar formats, not generic surveys.
- The owner repeats a format over time, even when the participants change.
- Participants answer feedback without creating accounts.
- The owner plans in an existing calendar and invites a generated, per-format LetsGrow email address.
- Workspaces contain owners; participants stay outside the account model.
- The visible value is honest feedback, patterns, and practical improvement over time.

Challenge any plan that violates these invariants. If the task asks for participant accounts, broad survey building, HR analytics, sales-heavy procurement flows, or generic team productivity dashboards, call out the strategy change and propose the narrower LetsGrow-shaped version first.

## Product Surfaces

Inspect the surface that matches the task. Do not treat any single surface as authoritative for all product decisions.

- Web app and public site: [web/](../../../web/)
- iOS app: [ios-app/](../../../ios-app/)
- Backend and canonical API/domain model: [backend/](../../../backend/)

## Load References Only When Needed

- Audience, ICP, JTBD, and positioning: [references/audience-positioning.md](references/audience-positioning.md)
- Product UX, onboarding, roles, workspace, and activation: [references/product-ux-guidance.md](references/product-ux-guidance.md)
- Danish messaging, CTAs, pricing principles, and commercial model: [references/messaging-commercial.md](references/messaging-commercial.md)
- Code/API/domain terms such as `Activity`, `Event`, `Session`, and `ParticipantEvent`: [references/domain-language.md](references/domain-language.md)

## Strategic Filter

Before proposing a feature, flow, screen, campaign, or copy change, check whether it:

1. Helps someone learn what worked after a meeting, workshop, talk, training, or similar format.
2. Reduces friction around collecting honest feedback immediately afterwards.
3. Makes patterns over time or across sessions clearer.
4. Keeps participants account-free and low effort.
5. Fits a Danish-first, practical product that starts through familiar calendar workflows and generated per-format email addresses.
6. Avoids sounding like an HR platform, generic survey tool, or abstract self-improvement app.

If the answer is no, challenge the work and propose a tighter version anchored in post-session feedback and visible improvement.

## Durable Defaults

- Market: Denmark first.
- Customer-facing language: plain Danish unless asked otherwise.
- Setup mechanic: plan in existing calendar tools and invite the generated LetsGrow email for that format.
- Email-based session creation is core product behavior. The backend generates a deterministic email address for each format, for example a short-code address such as `1234@letsgrow.dk`, and calendar invites sent to that address create sessions for that specific format.
- Onboarding: app-first unless a future operating model reintroduces founder-assisted pilots.
- Account model: one workspace per company or team.
- First user: workspace owner, usually also the first format owner.
- Participants: answer feedback without accounts.
- Activation: one real format configured, first participant responses received, and useful feedback visible.

## Output Shape

Be concrete enough for a designer, product manager, or engineer to act on. Include:

- the target user
- the primary job the experience must solve
- the desired behavioral outcome
- what to include
- what to avoid
- suggested Danish UX or marketing copy when relevant
