---
status: ready
areas: [ios]
created: 2026-11-06
updated: 2026-11-06
---

# Svartypevælger med preview og tydelige ikoner

## Problem and outcome

### Sheet og valg

Valg af svartype ved nyt og redigeret spørgsmål skal være en tydelig, separat handling med deltagerens visning under valgmulighederne.

### SVG-ikoner

De nuværende SF Symbols viser ikke tilstrækkeligt tydeligt, hvilken svaroplevelse hver type giver. Lever fem konsistente vektorikoner og integrer dem i appen.


## Scope

### Sheet og valg

Fælles QuestionPickerView for opret/rediger spørgsmål og alle fem svartyper. Ingen ændring af API eller svarenes domænetyper.

### SVG-ikoner

Fem redigerbare SVG-kilder, native iOS-assetintegration og alle eksisterende svartypeikon-kaldere. Ingen ændring af svarmulighedernes betydning.


## Context

### Sheet og valg

- ios-app/Modules/Sources/ActivityFeature/Activities/ManageEvent/QuestionPickerView.swift: lokal optional feedbackTypeSelected, inline-valg og separat FeedbackQuestionIllustrationView.
- ios-app/Modules/Sources/ActivityFeature/Activities/ManageEvent/QuestionsListView.swift og ios-app/Modules/Sources/ActivityFeature/Activities/ManageEvent/FeedbackType+Extensions.swift.
- ios-app/Modules/Sources/FeedbackFlowFeature/FeedbackQuestionIllustrationView.swift giver eksisterende forhåndsvisning.

### SVG-ikoner

- ios-app/Modules/Sources/DesignSystem/Resources/Images/Images.swift: face.smiling, text.bubble, hand.thumbsup, slider.horizontal.3 og number.square.
- ios-app/Modules/Sources/ActivityFeature/Activities/ManageEvent/FeedbackType+Extensions.swift mapper de fem FeedbackType-cases til ikoner.
- ios-app/Modules/Sources/FeedbackFlowFeature/FeedbackQuestionIllustrationView.swift og de fem feedbackfeatures viser svarenes faktiske betydning.


## Decisions and open questions

### Sheet og valg

- Nyt spørgsmål starter med knappen “Vælg” og ingen implicit valgt type; gem spørgsmål er deaktiveret indtil tekst og type er gyldige.
- Redigering bevarer eksisterende svartype. “Starter som Vælg” fortolkes som den uvalgte oprettelsestilstand, ikke nulstilling af gemt data.
- Sheet har midlertidigt valg. Tryk på en type opdaterer preview og lukker ikke sheetet. “Vælg” øverst til højre bekræfter og lukker; knappen er deaktiveret uden valg.
- Swipe/luk/annuller forkaster ændringer til svartypen; bekræftelse gemmer kun typen i spørgsmålseditoren, ikke spørgsmålet eller aktiviteten.

### SVG-ikoner

- Motivforslag: emoji = tre ansigter med tydeligt forskelligt udtryk; kommentar = taleboble med tekstlinjer; thumpsUpThumpsDown = både tommel op og ned; opinion = diskrete valg fra uenig til enig; zeroToTen = en skala med synlige 0 og 10. Kontroller opinionens faktiske labels inden tegning.
- Fælles viewBox, ens stregtykkelse og optisk størrelse; afprøv ved 24 og 32 pt. Brug monokrom template-farve via appens semantiske farver; SVG-kilder kan bruge currentColor.
- Bevar SVG som redigerbar kilde og brug assetformat/konvertering understøttet af projektets Xcode-pipeline. Ingen runtime-SVG-renderer som ny dependency.
- Tegn kodebaserede vektorer; rasterbilleder er ikke det ønskede output. Ikon ledsages fortsat af typens tekst.

- Bundling: Delopgaverne kan leveres i samme ændring og verificeres samlet. Hvert acceptkriterium gælder fortsat; bundlingen udvider ikke produktscope.
- Unresolved: None.
- Execution constraints: Kun refinement er bestilt. Ingen implementering, commits, deployment eller ændringer af produktdata er udført.

## Acceptance criteria

- [ ] AC-1: Nyt spørgsmål viser Vælg uden automatisk åbning; rediger viser eksisterende type og åbner sheet med den markeret.
- [ ] AC-2: Sheet viser alle fem typer og en preview nedenunder, som følger det midlertidige valg og den aktuelle spørgsmålstekst.
- [ ] AC-3: Valg af række holder sheet åbent; Vælg bekræfter og lukker; annullering bevarer tidligere værdi.
- [ ] AC-4: Spørgsmålets ID/tekst bevares ved redigering; gem validerer tekst/type; preview sender aldrig data.

- [ ] AC-5: Alle fem typer har et selvstændigt SVG-ikon med de aftalte motiver og konsistent stil.
- [ ] AC-6: Appen bruger de nye ikoner på alle eksisterende svartypeikon-flader, inklusive sheet hvis det er implementeret.
- [ ] AC-7: Ikoner er genkendelige ved lille størrelse i lys/mørk, følger semantic tint og er ikke afhængige af farve alene.

## Implementation plan

### Sheet og valg

- [ ] Udskil sheet med midlertidig valgt type og genbrug FeedbackQuestionIllustrationView.
- [ ] Flyt inline-valg til sheet, skjul tastaturet ved åbning og implementer bekræft/annuller-semantik.
- [ ] Opdater katalog for uvalgt, redigering, sheet og fem previews; verificer QuestionPicker-kaldere.

### SVG-ikoner

- [ ] Gennemgå de reelle svarkontroller; tegn fem SVG-kilder og en samlet preview med labels ved 24/32 pt i lys/mørk.
- [ ] Integrer som native template-assets i DesignSystem og udskift den eksisterende mapping.
- [ ] Kontroller alle kaldere, tilgængelighedslabels og katalog; dokumenter placering og evt. konverteringskommando.


## Verification

### Sheet og valg

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1, AC-3 | Nyt og eksisterende spørgsmål | Åbn, vælg type, annuller, genåbn, bekræft | Ingen implicit type eller tidlig commit |
| AC-2, AC-4 | Alle fem typer, lang tekst og Dynamic Type | Skift type, rul sheet, gem/rediger og åbn igen | Korrekt preview og bevaret ID/tekst/type; ingen API-kald fra preview |

Ved implementering: følg ios-app/AGENTS.md og Docs/agents/simulator.md; brug native Xcode MCP til relevante build/test-kørsler. Swiftændringer kræver `python3 ios-app/scripts/lint-swift-changes.py --base HEAD` for rent uncommitted scope (ellers korrekt merge-base). UI-ændringer kræver fuldt katalogreview efter ios-app/Docs/agents/visual-review.md plus interaktion med de ændrede kontroller; dokumentér faktiske resultater separat. Brug eksisterende lokale fixtures; planen giver ikke tilladelse til reset eller produktionsændringer.

### SVG-ikoner

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-5, AC-7 | SVG-kilder og samlet preview | Vis alle fem side om side ved målestørrelser i begge temaer | Motiver/stregstil er tydelige; ingen clipping |
| AC-6 | App med spørgsmål af alle fem typer | Åbn typeliste/sheet og øvrige kaldere | Samme nye ikonmapping overalt |

Ved implementering: følg ios-app/AGENTS.md og Docs/agents/simulator.md; brug native Xcode MCP til relevante build/test-kørsler. Swiftændringer kræver `python3 ios-app/scripts/lint-swift-changes.py --base HEAD` for rent uncommitted scope (ellers korrekt merge-base). UI-ændringer kræver fuldt katalogreview efter ios-app/Docs/agents/visual-review.md plus interaktion med de ændrede kontroller; dokumentér faktiske resultater separat. Brug eksisterende lokale fixtures; planen giver ikke tilladelse til reset eller produktionsændringer.

Gennemfør fælles build/lint og fuldt katalogreview én gang efter alle delændringer; de konkrete rolle-, interaktions- og datachecks ovenfor skal stadig udføres. Haptik kræver fortsat fysisk enhed, hvis det indgår.

## Human review

Not implemented yet. Forklar flow, arkitekturbeslutninger, tradeoffs, læsesti og verifikationsgrænser efter docs/agents/human-review.md.

## Handoff

- Completed: Relaterede taskplaner samlet med alle acceptkriterier, beslutninger og verifikationsscenarier bevaret. Ingen produktændringer.
- Verification results: Not run. Kun refinement og kontrol af taskstruktur/referencer.
- Blockers: None.
- Next action: Læs konteksten for delopgaverne, gennemfør implementeringsplanen og afslut med én samlet iOS-verifikation.
