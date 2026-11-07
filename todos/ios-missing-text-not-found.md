---
status: draft
areas: [ios]
created: 2026-11-06
updated: 2026-11-06
---

# Afklar og ret tom tekst / “Not Found”

## Problem and outcome

Under manuel test er der noteret “Fix tom tekst i stedet for Not Found”. Den konkrete skærm og betydningen af tom tekst er endnu ikke kendt. Målet er korrekt præsentation af manglende indhold uden en teknisk eller misvisende tekst.

## Scope

Afgrænset reproduktion og rettelse af det rapporterede sted. Ingen global undertrykkelse af 404-fejl eller blind ændring af alle tomme felter.

## Context

- ios-app/Modules/Sources/MoreFeature/AccountSection/ProfileSettingsView.swift bruger profileMissingValue til manglende navn, mail og telefon.
- ios-app/Modules/Sources/Localization/Resources/AppStrings.xcstrings: profile.missingValue er allerede “Ikke angivet” / “Not provided”, ikke “Not Found”.
- todos/shared-error-messages.md beskriver en separat, større ændring af API-fejltekster; denne opgave må ikke duplikere den.

## Decisions and open questions

- Rapporten er ikke en dokumenteret rodårsag. Bevar fejl med en reel brugerhandling; manglende profilindhold må ikke forveksles med en API-fejl.
- Unresolved: Hvor vises teksten, hvad udløser den, og ønskes tom tekst eller en anden placeholder? Spørgsmål sendt til brugeren.
- Execution constraints: Kun refinement er bestilt. Ingen implementering, commits, deployment, produktionsdata eller nulstilling af lokale data er udført eller autoriseret af denne taskplan.

## Acceptance criteria

- [ ] AC-1: Den præcise skærm, handling, kontotype, sprog samt forventet tom visning er dokumenteret før rettelsen.
- [ ] AC-2: Det reproducerede sted viser den aftalte tomme tilstand uden “Not Found”; relevante reelle fejl er fortsat forståelige.

## Implementation plan

- [ ] Indhent skærm og handling, reproducer med samme rolle og sprog, og spor den konkrete tekstkilde.
- [ ] Fastlæg om løsningen er tomt felt, placeholder eller fejltekst; opdater taskens scope og ejerskab.
- [ ] Ret den fundne kilde, og tilføj kun regressionstest hvor adfærden kræver det.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1 | Samme rolle/sprog som rapporten | Gentag den oplyste handling | Reproduktion og kilde dokumenteret |
| AC-2 | Reproducerbar fixture | Gentag før/efter; kontroller reel 404 separat | Aftalt tom visning uden at skjule fejl |

Ved implementering: følg ios-app/AGENTS.md og Docs/agents/simulator.md; brug native Xcode MCP til relevante build/test-kørsler. Swiftændringer kræver `python3 ios-app/scripts/lint-swift-changes.py --base HEAD` for rent uncommitted scope (ellers korrekt merge-base). UI-ændringer kræver fuldt katalogreview efter ios-app/Docs/agents/visual-review.md plus interaktion med de ændrede kontroller; dokumentér faktiske resultater separat. Brug eksisterende lokale fixtures; planen giver ikke tilladelse til reset eller produktionsændringer.

## Human review

Not implemented yet. Implementeringen skal forklare flow, arkitekturbeslutninger, tradeoffs, læsesti og verifikationsgrænser efter docs/agents/human-review.md.

## Handoff

- Completed: Kodenære kilder undersøgt; scope, antagelser og plan gemt. Ingen produktændringer.
- Verification results: Not run. Kun refinement.
- Blockers: Hvor vises teksten, hvad udløser den, og ønskes tom tekst eller en anden placeholder? Spørgsmål sendt til brugeren.
- Next action: Indhent skærm og handling, reproducer med samme rolle og sprog, og spor den konkrete tekstkilde.
