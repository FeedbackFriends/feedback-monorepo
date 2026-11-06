---
status: draft
areas: [web, ios, docs]
created: 2026-11-06
updated: 2026-11-06
---

# Rebrand 08 — Finish the landing page, and the brand identity

## Problem and outcome

Task 01 ships a coming-soon landing page with the new positioning and a placeholder early-access CTA. Once the real product exists (02–07), the public site must show it:

- **Features.** Real feature sections for the actual loop: suggest, vote, decide, try, follow up.
- **Screenshots.** Real screenshots from the iOS employee app and the web leader dashboard.
- **CTAs.** Separate calls to action for leaders and employees.

The brand also still promises meeting feedback outside the landing page:

- **iOS copy.** The iOS sign-up copy offers feedback on your own activities.
- **Privacy policy.** It describes the old data model.
- **App Store listing.** It describes the old product.

The new brand, from section 4 and section 16 of `lets-grow-strategi-teamtrivsel.md`:

- **Promise.** "Lets Grow – Fra feedback til forbedring."
- **Headline.** "Gør medarbejdernes idéer til en bedre arbejdsdag."
- **Recurring messages.** "Du kan påvirke din arbejdsdag", "Gode idéer kan få opbakning fra teamet", "Forslag får en synlig beslutning", "Vi afprøver få forbedringer ad gangen", and "Vi følger op på, om ændringen hjælper".

Outcome:

- **Landing page.** It goes from coming-soon to a full marketing page with accurate features and app images.
- **Leader CTA.** "Kom i gang som leder" leads to web sign-up.
- **Employee CTA.** "Hent appen" leads to the App Store.
- **Everywhere else.** The privacy policy, the iOS copy, and the App Store listing match the shipped product.

## Rebrand series

Depends on **01** (coming-soon page) and on the shipped features in **06** (web leader dashboard) and **07** (iOS employee app). Copy must describe only what has shipped, including the anonymity model decided in 03. The coming-soon landing page (01) is implemented; product direction is documented in [the rebrand strategy](../lets-grow-strategi-teamtrivsel.md).

## Scope

- In scope:
  - **Landing page.**
    - Extend the coming-soon page from 01 into the full page: hero, how it works around the five-step loop, feature sections, and outcomes, without claimed effects. The strategy lists the effects as examples, not documented results.
    - Use real screenshots of the iOS app and the web dashboard. iOS images can come from the screen snapshot catalog (`ios-app/Docs/screenshots/catalog/`) or simulator captures.
  - **CTAs.** Replace the placeholder early-access CTA from 01. Leaders get "Kom i gang som leder", which leads to `/login` and team setup. Employees get "Hent appen", which leads to the App Store. Add a sticky CTA on mobile if it still fits.
  - **Navigation and footer.** Restore section links in `Navbar.tsx` for the new sections, and update `Footer.tsx`.
  - **Privacy policy.** Update the `/privacy-policy` content for teams, suggestions, votes, anonymity, and evaluations. It is in English today. Decide its language.
  - **Visual identity.** Decide whether to keep the green palette, Montserrat, and logo, or refresh them. Apply any refresh through tokens in `web/src/app/globals.css` and the iOS `DesignSystem`. Replace hardcoded hex values in components.
  - **iOS identity.**
    - Update the onboarding and empty-state copy, the launch screen, and possibly the icon.
    - Prepare App Store listing text (subtitle, description, keywords) and screenshots.
  - **Naming consistency.** Standardize "Lets Grow" and "LetsGrow" across the product and docs, and the OpenAPI description in `backend/apps/api/.../config/OpenApiConfig.kt`.
- Out of scope:
  - Renaming internal package names such as `dk.example.feedback` or `feedback-api`, and the bundle IDs. These are high risk and low value.
  - Pricing pages. The strategy treats pricing as a hypothesis.
  - English on web. Task 12 covers this.

## Context

- Current behavior:
  - Task 01 leaves a coming-soon page at `/` with one replaceable early-access CTA (`web/src/components/ui/EarlyAccessButton.tsx`).
  - Brand assets: `web/public/branding/*` and `web/src/components/layout/BrandLogo.tsx`.
  - Tokens: `web/src/app/globals.css` (`--primary` is a green, plus the `marketing-bg-*` tokens) and `web/src/lib/letsgrow.ts`.
  - iOS assets:
    - `ios-app/Resources/AppIcon.icon`
    - `ios-app/Resources/Launch Screen.storyboard`
    - `ios-app/Modules/Sources/DesignSystem/Resources/Colors/`
    - Montserrat fonts in DesignSystem
  - The iOS display name is "Lets Grow". Version 1.1.2 is live in the App Store (id6742420307).
- Reading path:
  - Strategy sections 4, 5, and 16.
  - `web/docs/agents/ui.md`.
  - The iOS DesignSystem module.

## Decisions and open questions

- Confirmed:
  - The name "Lets Grow", the brand promise, and the headline come from the strategy.
  - The landing page is finished here, after the coming-soon page from 01, with correct features, real app images, and changed CTAs (user, 2026-11-06).
- Assumptions:
  - Copy is Danish-first on web, and Danish and English on iOS.
  - The domain `letsgrow.dk` and the contact address stay unchanged.
- Unresolved:
  - Decide whether to refresh the visual identity (palette, logo, icon) or keep it and change only messaging. A refresh likely needs a designer or a Figma file.
  - Decide the privacy policy language and who reviews it legally.
  - Decide whether leader sign-up is open, or still gated as a pilot or early access when this task runs.

## Acceptance criteria

- [ ] AC-1: The full landing page describes only shipped features and uses real, current screenshots of the iOS app and the web dashboard.
- [ ] AC-2: The early-access placeholder from 01 is replaced by distinct leader and employee CTAs that route correctly.
- [ ] AC-3: The privacy policy describes the teams, suggestions, votes, and anonymity model that 02–05 actually implement.
- [ ] AC-4: Brand colors come from tokens, with no stray hardcoded brand hex values in web components.
- [ ] AC-5: iOS user-facing copy matches the new messaging in Danish and English, and App Store listing text is prepared for the user to submit.
- [ ] AC-6: The naming is consistent across web, iOS, and docs.

## Implementation plan

### Phase 1 — Full landing page

- [ ] Build the feature sections on top of the 01 page, capture and add app screenshots, replace the CTA, and update the navigation, footer, and metadata.
- [ ] Update the iOS copy keys.

### Phase 2 — Visual identity (if a refresh is decided)

- [ ] Change tokens and assets on web and iOS, and run a catalog review.

### Phase 3 — Legal and store

- [ ] Update the privacy policy and write an App Store listing draft.

Verification: web lint, build, route smoke tests (`web/tests/routes.spec.ts`), and a responsive visual check. Run the iOS localization validators and a snapshot catalog review.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1 | Tasks 06 and 07 shipped, web dev server | Open `/` and compare each feature claim and screenshot with the product | Every claim is accurate, and the screenshots are current |
| AC-2 | Web dev server | Click both CTAs | They go to login or sign-up and to the App Store, with no early-access CTA left |
| AC-3 | Tasks 02–05 done | Review the privacy policy against the implemented data | Accurate |
| AC-4 | Repository | Search web components for brand hex values | Only tokens remain |
| AC-5 | iOS scripts | Run the localization validators | Pass |
| AC-6 | Repository | Search for "LetsGrow" and "Lets Grow" in user-facing copy | Consistent |

## Human review

Not implemented yet.

## Handoff

- Completed: None.
- Verification results: Not run.
- Blockers: Tasks 01, 06, and 07, the visual identity decision, and the anonymity decision from 03.
- Next action: After 06 and 07 ship, decide on keeping or refreshing the visual identity, then start phase 1.
