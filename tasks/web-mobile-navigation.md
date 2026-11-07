---
status: draft
areas: [web]
created: 2026-11-06
updated: 2026-11-06
---

# Ret webnavigation på mobil

## Problem and outcome

Mobilnavigationen er rapporteret som defekt, men den konkrete overflade og fejl er ikke oplyst. Målet er adgang til navigation og handlinger på små skærme.

## Scope

Reproducer og ret den rapporterede navigation med eksisterende Sheet/Sidebar. Ingen generel redesign af websitet.

## Context

- web/src/components/layout/Navbar.tsx: offentlig topmenu bruger et højresheet på mobil.
- web/src/components/dashboard/DashboardShell.tsx: dashboard bruger Sidebar og har nu en SidebarTrigger i headeren samt mobil-lukning ved navigation. Den oprindelige trigger-observation er forældet; den rapporterede fejl skal reproduceres på ny.
- web/src/components/ui/sidebar.tsx; web/src/components/ui/sheet.tsx; web/tests/routes.spec.ts; web/tests/auth.spec.ts
- web/AGENTS.md; web/docs/agents/ui.md; web/docs/agents/validation.md

## Decisions and open questions

- En manglende dashboard-trigger er en kodeobservation, ikke en bekræftet årsag til brugerens rapport.
- Undersøg begge overflader, men vælg endelig rettelse efter reproduktion.
- Unresolved: Forsidens topmenu, menuen efter login eller begge — og hvad går galt? Spørgsmål sendt til brugeren.
- Execution constraints: Kun refinement er bestilt. Ingen implementering, commits, deployment, produktionsdata eller nulstilling af lokale data er udført eller autoriseret af denne taskplan.

## Acceptance criteria

- [ ] AC-1: Rapporteret URL, viewport, handling og defekt er dokumenteret.
- [ ] AC-2: Den berørte menu kan åbnes, navigeres og lukkes med touch og tastatur; fokus gendannes og aktiv side fremgår.
- [ ] AC-3: Ingen horisontal overflow, skjulte links/CTA eller regression ved desktop-breakpoint.

## Implementation plan

- [ ] Afklar overflade/fejl og reproducer i mobilviewport; inspicer Navbar og DashboardShell/Sidebar.
- [ ] Ret fundet layout- eller triggerproblem med eksisterende primitives og korrekt lukning ved navigation.
- [ ] Tilføj en relevant Playwright-regression og inspicer mobil/desktop visuelt.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1 | Oplyst URL og mobilbredde | Reproducer fejlen | Dokumenteret før-tilstand |
| AC-2, AC-3 | 320, 390, 768 og 1280 px; evt. lokal testlogin | Åbn/luk, følg link, Escape/fokus; npm run lint og relevante Playwright-tests fra web/ | Alle handlinger tilgængelige; ingen overflow; desktop virker |

## Human review

Not implemented yet. Implementeringen skal forklare flow, arkitekturbeslutninger, tradeoffs, læsesti og verifikationsgrænser efter docs/agents/human-review.md.

## Handoff

- Completed: Kodenære kilder undersøgt; scope, antagelser og plan gemt. Ingen produktændringer.
- Verification results: Not run. Kun refinement.
- Blockers: Forsidens topmenu, menuen efter login eller begge — og hvad går galt? Spørgsmål sendt til brugeren.
- Next action: Afklar overflade/fejl og reproducer i mobilviewport; inspicer Navbar og DashboardShell/Sidebar.
