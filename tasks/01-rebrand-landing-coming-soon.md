---
status: draft
areas: [web]
created: 2026-11-06
updated: 2026-11-06
---

# Rebrand 01 — Coming-soon landing page with the new positioning

**Priority: first.** This is the first rebrand work to ship. It changes only the public web, and it is independent of the backend work.

## Problem and outcome

The public landing page at `/` still sells "feedback after meetings":

- **Hero.** "Bliv klogere på hvad der virker", with "Få ærlig feedback efter møder, workshops, oplæg og andre aktiviteter…".
- **Calendar row.** "Integreret med disse kalenderværktøjer".
- **Images.** Calendar and Teams logos, plus meeting-era imagery.
- **Metadata.** "Lets Grow helps teams improve recurring meetings with simple automated feedback."

The product is moving to employee-driven improvements (`lets-grow-strategi-teamtrivsel.md`), but none of the new features exist yet.

Outcome: `/` becomes a simple, honest **coming-soon** page that carries the new brand:

- **Promise.** "Lets Grow – Fra feedback til forbedring."
- **Headline.** "Gør medarbejdernes idéer til en bedre arbejdsdag."
- **Supporting copy.** From strategy section 16: "Lad medarbejderne foreslå forbedringer anonymt, støtte hinandens idéer og følge med i, hvad der bliver gjort. Giv lederne en enkel måde at prioritere, afprøve og følge op."
- **The loop.** The five steps "Foreslå → Stem → Beslut → Afprøv → Følg op", presented as direction, not as shipped features.
- **One CTA.** A placeholder call to action. Task 08 replaces it with the real leader and employee CTAs.

## Rebrand series

| Task | Topic | Depends on |
| --- | --- | --- |
| **01** | Coming-soon landing page (this task) | None |
| 02 | Teams, roles, platform split | None |
| 03 | Anonymous suggestions and votes | 02 |
| 04 | Leader decisions and status | 03 |
| 05 | Trials and evaluation | 04 |
| 06 | Web leader dashboard | 03–05 (incremental) |
| 07 | iOS employee app | 03–05 (incremental) |
| 08 | Finish landing page with real features, CTAs, and app screenshots; brand identity | 01, 06, 07 |
| 09 | Legacy retirement (meetings, PIN, mail listener) | 06, 07 |
| 10 | Android employee app (future, very low priority) | 02–07 |
| 11 | HR overview role (future, low priority) | 02–06 |
| 12 | Web language switch, Danish/English (low priority) | 06 |
| 13 | Optional team well-being check (future, low priority) | 02, 03, 06, 07 |

## Scope

- In scope:
  - **Landing page.** Replace the content of `/` with a coming-soon page: a hero with the promise and headline, a short "what is coming" section built on the five-step loop, and one CTA.
  - **CTA.** Reuse the existing early-access button. "Få tidlig adgang" is in `web/src/lib/letsgrow.ts` and `web/src/components/ui/EarlyAccessButton.tsx`, and its link comes from `NEXT_PUBLIC_LETSGROW_EARLY_ACCESS_URL`, a Typeform form. The CTA is a single, easily replaceable component, so task 08 can swap it.
  - **Remove meeting positioning.** Take out the calendar-integration row and logos, the meeting-feedback copy, and the "Hent appen" App Store pushes on the landing page and in `MobileStickyCta`. The app does not offer the new experience yet.
  - **Navigation and footer.** Trim the navbar links in `web/src/components/layout/Navbar.tsx` ("Problem", "Fra møde til feedback", "Hent appen") to match the coming-soon page. Keep the footer contact address and the privacy policy link.
  - **Metadata.** Change the title and description in `web/src/app/layout.tsx` and the `/` metadata to the new positioning. Set `<html lang="da">`.
  - **Images.** Remove meeting and calendar imagery from the page. Use the existing logo, typography, and color tokens, or a simple non-product illustration.
- Out of scope:
  - Real product screenshots, feature sections, and leader and employee CTAs. Task 08 covers these.
  - Visual identity refresh, iOS copy, App Store text, and the privacy policy rewrite. Task 08 covers these.
  - `/login`, `/dashboard/*`, and `/invite/[id]`. These stay working as they are.
  - Deleting unused landing components or images. Removal is fine if nothing else imports them, but it is not required.

## Context

- Current behavior:
  - `web/src/app/page.tsx` renders `MarketingShell` and `web/src/components/landing/LandingPage.tsx`.
  - `LandingPage.tsx` composes `web/src/components/landing/sections/` (`HeroSection`, `ProblemSection`, `HowItWorksSection`, `OutcomesSection`, `AppStoreCtaSection`, `MobileStickyCta`).
  - The copy, the App Store URL, and the calendar platform list live in `web/src/components/landing/content.ts`.
  - Images are in `web/public/`: `hero_image.png`, `problem*.png`, and the calendar and Teams logos. Brand assets are in `web/public/branding/` and `web/src/components/layout/BrandLogo.tsx`.
  - Styling uses Tailwind 4 tokens in `web/src/app/globals.css`. Some hardcoded hex values remain in `web/src/lib/letsgrow.ts`.
  - The route smoke test is `web/tests/routes.spec.ts`.
- Reading path:
  - `web/AGENTS.md`
  - `web/docs/agents/ui.md`
  - `web/docs/agents/validation.md`
  - Strategy sections 4 and 16
- State/API flow and prerequisites: None. This is a static marketing page.

## Decisions and open questions

- Confirmed (user, 2026-11-06):
  - The first rebrand task is the landing page, as a coming-soon page.
  - The CTAs change later, in task 08.
- Assumptions:
  - The copy is Danish only.
  - The page promises direction ("Snart", meaning soon), not shipped features. It does not claim guaranteed anonymity, because task 03 still decides the anonymity model. Wording like "foreslå forbedringer anonymt" describes the intent. Phrase it as what is coming.
  - The current palette, Montserrat, and logo stay until task 08 decides on a visual refresh.
- Unresolved:
  - **CTA target.** Decide whether the CTA keeps the existing early-access Typeform ("Få tidlig adgang"), or becomes a "Skriv dig op" email signup or a mailto to `kontakt@letsgrow.dk`. The default is to keep the existing Typeform, which needs no new code.
  - **Existing iOS users.** Decide whether the page mentions anything to current users of the meeting-feedback app. The default is no.
- Execution constraints:
  - No deployment is authorized by this plan.
  - Do not commit or push unless asked.

## Acceptance criteria

- [ ] AC-1: `/` shows the new promise and headline and a short coming-soon section about the improvement loop.
- [ ] AC-2: No meeting, calendar-integration, or meeting-feedback copy or imagery remains on `/`, the navbar, or the page metadata.
- [ ] AC-3: Exactly one primary CTA is shown, and it works. It is implemented as one component that task 08 can replace.
- [ ] AC-4: The page is responsive at phone width (390 px) and desktop width, with no horizontal scroll.
- [ ] AC-5: `<html lang="da">`, and the title and description use the new positioning.
- [ ] AC-6: `/login`, `/dashboard`, `/invite/[id]`, and `/privacy-policy` still work.

## Implementation plan

- [ ] Rewrite `content.ts` and replace the composition in `LandingPage.tsx` with a coming-soon hero, a loop section, and the CTA. Drop `ProblemSection`, `OutcomesSection`, `AppStoreCtaSection`, and the App Store sticky CTA from the page.
- [ ] Update `Navbar.tsx` and `Footer.tsx` for the coming-soon page.
- [ ] Update the metadata and `lang` in `web/src/app/layout.tsx` and `web/src/app/page.tsx`.
- [ ] Update `web/tests/routes.spec.ts` for the new `/` content, with an assertion on the headline and an absence check for the calendar copy.
- [ ] Verification: `npm run lint`, `npm run build`, `npm run test:e2e`, and a visual check at 390 px and desktop width.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1 | Web dev server | Open `/` | The promise, headline, and loop section are visible |
| AC-2 | Rendered page | Search the page and metadata for "møde", "kalender", and "Teams" | No matches |
| AC-3 | Early-access URL env set | Click the CTA | Opens the agreed target |
| AC-4 | Playwright or a browser | Check at 390 px and 1280 px | No horizontal scroll, and the layout is intact |
| AC-5 | Rendered HTML | Inspect `lang`, `<title>`, and the meta description | `da`, with the new copy |
| AC-6 | `npm run test:e2e` | Run the route and auth specs | Pass |

## Human review

Not implemented yet.

## Handoff

- Completed: None.
- Verification results: Not run.
- Blockers: None. The CTA target defaults to the existing Typeform if not decided.
- Next action: Confirm the CTA target, then run `$lg-implement tasks/01-rebrand-landing-coming-soon.md`.
