---
status: ready
areas: [ios]
created: 2026-11-06
updated: 2026-11-06
---

# Fysisk afprøvning af implementerede ændringer

## Problem and outcome

Samlet tjekliste til Nicolai over adfærd, der kræver en fysisk iPhone. Simulator-, build- og testresultater holdes adskilt fra faktisk fysisk afprøvning.

## Scope

Fysiske kontroller fra implementeringsopgaverne. Listen udvides løbende før relevante commits/pushes. Ingen produktionstest, deploy eller automatisk godkendelse af screenshots.

## Context

- Oprettet efter brugerens ønske 2026-11-06 under gennemførsel af backloggen.
- `ios-app/Modules/Sources/DesignSystem/ViewModifiers/SuccessMessageModifier.swift` ejer success-haptik; features ejer toastens timing.
- `docs/agents/human-review.md` og `ios-app/Docs/agents/simulator.md` beskriver evidens og begrænsninger.

## Decisions and open questions

- Confirmed: Nicolai udfører fysisk afprøvning; agenten vedligeholder listen.
- Assumptions: Kontroller køres på en build med de relevante commits; registrer build/commit og iOS-version ved testen.
- Unresolved: None.
- Execution constraints: Ingen test må hævdes gennemført uden faktisk resultat. Denne opgave forbliver åben efter implementeringsbackloggen, indtil Nicolai har afprøvet punkterne.

## Acceptance criteria

- [ ] AC-1: Success-toast giver kun én success-haptik ved visning; automatisk fjernelse og navigation giver ingen; en senere ny toast giver haptik igen.
- [ ] AC-2: Alle efterfølgende tilføjede fysiske kontroller er udført og deres build/enhed/resultat registreret.

## Implementation plan

- [ ] Implementér haptikrettelsen i `ios-confirmation-polish.md`, og tilføj commitreference her før levering.
- [ ] Tilføj relevante fysiske kontroller løbende med reproduktionstrin og forventning.
- [ ] Nicolai gennemfører og registrerer resultater; fejl følges op i særskilt task ved behov.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1 | Fysisk iPhone med haptik aktiveret og rettelsen installeret | Opret aktivitet, mærk toasten, afvent fjernelse, navigér, og gentag oprettelse | Én vibration pr. ny toast; ingen ved fjernelse/navigation |
| AC-2 | Relevant build installeret | Gennemfør alle tilføjede punkter og noter commit/build, enhed, iOS og resultat | Ingen uafprøvede punkter |

## Human review

Eksisterende ansvarsdeling bevares: DesignSystem ejer haptik, features ejer timing og navigation. Fysisk vibration kan ikke bevises i simulatoren. Implementering og automatiserede resultater registreres i de respektive opgaver/commits.

## Handoff

- Completed: Samlet fysisk tjekliste oprettet efter brugerens ønske.
- Verification results: Not run. Haptikrettelsen er endnu ikke implementeret.
- Blockers: Kræver Nicolais fysiske iPhone og testresultater.
- Next action: Ved implementering af confirmation-polish tilføjes commitreference og faktisk automatisk evidens; Nicolai tester derefter AC-1.
