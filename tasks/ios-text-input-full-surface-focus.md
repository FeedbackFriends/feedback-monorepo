---
status: ready
areas: [ios]
created: 2026-11-06
updated: 2026-11-06
---

# Gør hele tekstfeltets flade trykbar centralt

## Problem and outcome

Aktivitetsnavnets tekstfelt får kun fokus på den egentlige tekstlinje. Hele den synlige inputflade skal kunne aktivere feltet, også titel og indvendig luft.

## Scope

Fælles TextInputView og alle dens kaldere; gennemgå tilsvarende indrammede enkeltfelter og migrér kun kompatible tilfælde. Ingen global tap-handler eller formularomlægning.

## Context

- ios-app/Modules/Sources/DesignSystem/ReusableViews/TextInputView.swift: VStack med titel og TextField, surfaceCard(padding: 15), men ingen fokus ved tap på kortfladen.
- ios-app/Modules/Sources/ActivityFeature/Activities/ManageActivity/ManageActivityView.swift og ios-app/Modules/Sources/ActivityFeature/Activities/ManageEvent/QuestionPickerView.swift er nuværende kaldere.

## Decisions and open questions

- Implementer fokus i DesignSystem-komponenten gennem dens eksisterende FocusState.Binding. Bevar native markørplacering, markering og redigeringsmenu på selve teksten.
- Trykfladen er inputkortet inklusive intern padding, ikke hele sektionen eller nabokontroller. Bevar horisontal/multiline-støtte og eksisterende accessibility-identifiers.
- Unresolved: None
- Execution constraints: Kun refinement er bestilt. Ingen implementering, commits, deployment, produktionsdata eller nulstilling af lokale data er udført eller autoriseret af denne taskplan.

## Acceptance criteria

- [ ] AC-1: Tryk på titel, indvendig luft, tomt område og tekst i aktivitetsnavnet fokuserer feltet og åbner tastaturet.
- [ ] AC-2: Spørgsmålseditorens felt får samme adfærd gennem fælles komponent uden per-skærm-gestures.
- [ ] AC-3: Tekstmarkering, cursor, multiline-scroll, VoiceOver og tryk uden for feltet fungerer fortsat.

## Implementation plan

- [ ] Udvid contentShape/hit-testing og fokusadfærd i TextInputView uden at overtage TextFields egne gestures.
- [ ] Kontroller alle kaldere og afprøv tom/udfyldt samt en- og flerlinjet tilstand; dokumenter eventuelle kompatible migrationer.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1, AC-2 | Opret/rediger aktivitet og spørgsmål; tastatur lukket | Tryk separat på label, padding, højre tomme side og tekst | Samme felt får fokus fra hele kortfladen |
| AC-3 | Lang tekst, multiline og VoiceOver | Flyt cursor, marker tekst, rul og tryk på naboknap | Native redigering og nabohandlinger virker |

Ved implementering: følg ios-app/AGENTS.md og Docs/agents/simulator.md; brug native Xcode MCP til relevante build/test-kørsler. Swiftændringer kræver `python3 ios-app/scripts/lint-swift-changes.py --base HEAD` for rent uncommitted scope (ellers korrekt merge-base). UI-ændringer kræver fuldt katalogreview efter ios-app/Docs/agents/visual-review.md plus interaktion med de ændrede kontroller; dokumentér faktiske resultater separat. Brug eksisterende lokale fixtures; planen giver ikke tilladelse til reset eller produktionsændringer.

## Human review

Not implemented yet. Implementeringen skal forklare flow, arkitekturbeslutninger, tradeoffs, læsesti og verifikationsgrænser efter docs/agents/human-review.md.

## Handoff

- Completed: Kodenære kilder undersøgt; scope, antagelser og plan gemt. Ingen produktændringer.
- Verification results: Not run. Kun refinement.
- Blockers: None
- Next action: Udvid contentShape/hit-testing og fokusadfærd i TextInputView uden at overtage TextFields egne gestures.
