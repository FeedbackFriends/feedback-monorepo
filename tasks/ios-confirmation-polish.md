---
status: in-progress
areas: [ios]
created: 2026-11-06
updated: 2026-11-06
---

# Små forbedringer af bekræftelser

## Problem and outcome

### Toastens haptik

Oprettelsens success-toast giver vibration både ved visning og fjernelse. Den fælles modifier trigges af begge ændringer i en Bool.

### Kopiering af mailadresse

“Mailen er kopieret” kan forstås som en hel mail. Beskeden skal forklare, at aktivitetens mailadresse er kopieret, og hvad den bruges til.


## Scope

### Toastens haptik

SuccessMessageModifier og dens kaldere. Ingen ændring af timeout, navigation, øvrige feedbackvalg eller fejlbannerets adfærd.

### Kopiering af mailadresse

Alertens titel og hjælpetekst ved kopiering af aktivitetsmail. Ingen ændring af clipboard-handlingen.


## Context

### Toastens haptik

- ios-app/Modules/Sources/DesignSystem/ViewModifiers/SuccessMessageModifier.swift: sensoryFeedback(.success, trigger: isPresented) uden betingelse.
- ios-app/Modules/Sources/DesignSystem/ReusableViews/Banner.swift er et separat fejl/offline-banner med egen haptik.
- ios-app/Modules/Tests/AppTests/ReducerTests/FocusFeature/SuccessConfirmationTests.swift dækker success-forløb.

### Kopiering af mailadresse

- ios-app/Modules/Sources/ActivityFeature/Activities/ActivityDetail/Views/ActivityDetailHowItWorksView.swift: activityCopyEmailTitle og activityCopyEmailMessage.
- ios-app/Modules/Sources/Localization/Resources/AppStrings.xcstrings; ios-app/Docs/localization.md


## Decisions and open questions

### Toastens haptik

- Giv kun success-haptik på false → true. true → false, uændret værdi og initialt skjult toast er tavse.

### Kopiering af mailadresse

- Forslag til dansk titel: “Mailadressen er kopieret”. Besked: “Indsæt den som deltager i din kalenderinvitation.” Knap: “OK”.
- Engelsk: “Email address copied” / “Paste it as an attendee in your calendar invitation.” Følg eksisterende lokaliseringsnøgler.

- Bundling: Delopgaverne kan leveres i samme ændring og verificeres samlet. Hvert acceptkriterium gælder fortsat; bundlingen udvider ikke produktscope.
- Unresolved: None.
- Execution constraints: Kun refinement er bestilt. Ingen implementering, commits, deployment eller ændringer af produktdata er udført.

## Acceptance criteria

- [ ] AC-1: Hver ny visning giver én success-haptik, og automatisk eller navigationsrelateret fjernelse giver ingen.
- [ ] AC-2: Toastens visningstid, animation og efterfølgende navigation ændres ikke; en senere ny toast kan vibrere igen.

- [ ] AC-3: Kopiering viser den foreslåede danske tekst; engelsk viser tilsvarende betydning.
- [ ] AC-4: Clipboard indeholder den uændrede aktivitetsmailadresse og alerten kan lukkes.

## Implementation plan

### Toastens haptik

- [x] Beting success-modifierens haptik på overgang til synlig; gennemgå kaldere uden at ændre deres timere.
- [ ] Kontroller eksisterende success-flow-tests og visning/fjernelse på en fysisk enhed.

### Kopiering af mailadresse

- [x] Opdater eksisterende semantiske lokaliseringsnøgler og inventory; gennemgå lang tekst i alerten.


## Verification

### Toastens haptik

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1, AC-2 | Gentagne success-forløb på fysisk iPhone | Opret, afvent fjernelse, opret igen; gennemgå SuccessConfirmationTests | Kun haptik ved visning; simulator kan ikke alene bevise fysisk vibration |

Ved implementering: følg ios-app/AGENTS.md og Docs/agents/simulator.md; brug native Xcode MCP til relevante build/test-kørsler. Swiftændringer kræver `python3 ios-app/scripts/lint-swift-changes.py --base HEAD` for rent uncommitted scope (ellers korrekt merge-base). UI-ændringer kræver fuldt katalogreview efter ios-app/Docs/agents/visual-review.md plus interaktion med de ændrede kontroller; dokumentér faktiske resultater separat. Brug eksisterende lokale fixtures; planen giver ikke tilladelse til reset eller produktionsændringer.

### Kopiering af mailadresse

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-3, AC-4 | Aktivitet med mailadresse; dansk/engelsk | Kopiér, læs alert, luk og indsæt clipboard | Præcis tekst og korrekt mailadresse |

Ved implementering: følg ios-app/AGENTS.md og Docs/agents/simulator.md; brug native Xcode MCP til relevante build/test-kørsler. Swiftændringer kræver `python3 ios-app/scripts/lint-swift-changes.py --base HEAD` for rent uncommitted scope (ellers korrekt merge-base). UI-ændringer kræver fuldt katalogreview efter ios-app/Docs/agents/visual-review.md plus interaktion med de ændrede kontroller; dokumentér faktiske resultater separat. Brug eksisterende lokale fixtures; planen giver ikke tilladelse til reset eller produktionsændringer.

Gennemfør fælles build/lint og fuldt katalogreview én gang efter alle delændringer; de konkrete rolle-, interaktions- og datachecks ovenfor skal stadig udføres. Haptik kræver fortsat fysisk enhed, hvis det indgår.

## Human review

Eksisterende ansvar bevares: DesignSystem successMessage reagerer nu kun på false → true med Apples sensoryFeedback-condition; features ejer stadig timers, animation og navigation. Fejlbanneret er uændret. De eksisterende activity.copyEmailTitle/Message-nøgler er rettet på dansk/engelsk; onCopyEmail og clipboard-transport er uændret.

Læsesti: `ios-app/Modules/Sources/DesignSystem/ViewModifiers/SuccessMessageModifier.swift` → `ios-app/Modules/Tests/AppTests/ReducerTests/FocusFeature/SuccessConfirmationTests.swift` → `ios-app/Modules/Sources/ActivityFeature/Activities/ActivityDetail/Views/ActivityDetailHowItWorksView.swift` → `ios-app/Modules/Sources/Localization/Resources/AppStrings.xcstrings`.

## Handoff

- Completed: Haptik begrænset til visning, kaldere gennemgået uden timerændringer; aktivitetsmail-alert præciseret i begge sprog og inventory opdateret.
- Verification results: 2026-11-06 Feedback Localhost / LetsGrow Manager iOS 27.2: native BuildProject og buildForTesting bestået; SuccessConfirmationTests/waitsForCompletedTransitionAndIgnoresDuplicateCallbacks(): 1 passed. SwiftLint --base HEAD: 0 violations i 1 fil. validate-localization.py: 313 nøgler gyldige; check-localized-copy.py: 215 filer bestået. Frisk ScreenSnapshots: 1 passed, 56 billeder publiceret; 52 hashes uændrede fra gennemgået fokus-capture og 4 ændrede billeder geninspiceret. Findings/hashes: `screenshots/review/confirmation-findings.json`; galleri `screenshots/index.html`. Ingen baselines accepteret.
- Blockers: Fysisk haptik kræver Nicolais test, samlet i `tasks/ios-physical-device-verification.md`. Live alert/clipboard-kontrol er blokeret af native Xcode-interaktionssession-fejlen dokumenteret i `tasks/ios-text-input-full-surface-focus.md`; screenshotkataloget viser ikke copy-alerten. Ingen fuld runtime-verifikation hævdes.
- Next action: Få native interaktionssession tilbage, kontrollér copy-alert/clipboard i begge sprog og genstart appen med rettelsen. Nicolai udfører fysisk haptiktest; tasken beholdes indtil required checks er dækket.
