---
status: ready
areas: [ios]
created: 2026-11-06
updated: 2026-11-06
---

# Profil, indstillinger og navigation

## Problem and outcome

### Log ud og adgang

Anonyme feedbackbrugere skal ikke præsenteres for Log ud. Profilstien har allerede en rollekontrol, men rodens fejlskærm viser knappen ubetinget.

### Indstillinger

Kommunikation viser indstillinger for appnotifikationer og mailopdateringer, som brugeren ønsker fjernet. De nuværende toggles ændrer kun lokal reducer-state.

### Profilavatar

Profilknappen skal identificere ejeren med initialer, fx Nicolai Dam → ND, i stedet for det generiske profilikon.

### Aktivitetstab

Aktiviteter skal have et sparkle-ikon i tabbaren.


## Scope

### Log ud og adgang

Alle iOS-indgange til Log ud, inklusive fejlskærmen. Ejerens eksisterende logout skal fortsat virke.

### Indstillinger

Fjern sektionen, tilhørende døde actions/state og forældede fixtures. Ingen ændring af faktiske push-tilladelser, mails eller backendadfærd.

### Profilavatar

Fælles avatar på profilknapper i feedback- og aktivitetstab samt profilens avatar. Ingen foto-upload eller ændring af kontomodel.

### Aktivitetstab

Kun aktivitetstabens ikon; tabtitel, badges, rækkefølge og adgangsregler bevares.


## Context

### Log ud og adgang

- ios-app/Modules/Sources/MoreFeature/AccountSection/AccountSection.swift: canSignOut = bootstrap.role != nil samt reducer-guard.
- ios-app/Modules/Sources/RootFeature/RootFeatureView.swift: errorView viser Log ud ubetinget.
- ios-app/Modules/Sources/RootFeature/RootFeature.swift og ios-app/Modules/Sources/RootFeature/Logout.swift ejer auth/fejl/logout.
- ios-app/Modules/Tests/AppTests/ReducerTests/More/AccountSectionTests.swift; ios-app/Modules/Tests/InsightsTests/RootNavigationTests.swift

### Indstillinger

- ios-app/Modules/Sources/MoreFeature/AccountSection/ProfileSettingsView.swift: Kommunikation-sektionen med to toggles.
- ios-app/Modules/Sources/MoreFeature/AccountSection/ProfileSettings.swift: isInAppNotificationsEnabled/isEmailEventsEnabled ændres lokalt.
- ios-app/Modules/Sources/MoreFeature/ScreenCatalogPreviewView.swift; ios-app/Modules/Sources/MoreFeature/MoreSection/MoreSectionView.swift har separat link til OS-notifikationer.

### Profilavatar

- ios-app/Modules/Sources/TabbarFeature/TabbarView.swift; ios-app/Modules/Sources/ActivityFeature/Activities/ActivityList/ActivityListView.swift; ios-app/Modules/Sources/SignUpFeature/SignUpView.swift har separate person.crop.circle-knapper.
- ios-app/Modules/Sources/MoreFeature/AccountSection/ProfileSettingsView.swift: ProfileSectionView viser personCircleFill.
- ios-app/Modules/Sources/Domain/Models/API/Bootstrap.swift: AccountInfo.name er kilde; ios-app/Modules/Sources/MoreFeature/AccountSection/ProfileSettings/ModifyAccount.swift ændrer profil.

### Aktivitetstab

- ios-app/Modules/Sources/TabbarFeature/TabbarView.swift: systemImage er rectangle.stack; managerUnseenResponses styrer badge.
- ios-app/Modules/Sources/TabbarFeature/ScreenCatalogPreviewView.swift


## Decisions and open questions

### Log ud og adgang

- Anonym betyder role == nil; brug eksisterende auth-/Bootstrap-tilstand, ikke navn/mail som rolleindikator.
- Afklar state-ejerskab på startup-fejl, hvor Bootstrap endnu ikke er hentet: brug pålidelig eksisterende auth-tilstand; opfind ikke en ejerrolle.

### Indstillinger

- “Kommunikation” henviser til sektionen i profilindstillinger. Det separate link til systemets notifikationsindstillinger bevares.

### Profilavatar

- Antagelse: brug første og sidste navneords første grafem, trim og ignorér ekstra mellemrum, uppercase. Ét navneord giver ét initial; fx “Nicolai Christian Dam” → ND, “Åse Øster” → ÅØ.
- Manglende/tomt navn og anonyme bruger eksisterende personikon; udled ikke initialer fra mailadresse.
- Del avatarens visning i DesignSystem; features leverer navn fra Bootstrap. Bevar tilgængelighedslabel “Profil”.

### Aktivitetstab

- Brug SF Symbol “sparkle” som udgangspunkt, i systemets native Tab-udtryk.

- Bundling: Delopgaverne kan leveres i samme ændring og verificeres samlet. Hvert acceptkriterium gælder fortsat; bundlingen udvider ikke produktscope.
- Unresolved: None.
- Execution constraints: Kun refinement er bestilt. Ingen implementering, commits, deployment eller ændringer af produktdata er udført.

## Acceptance criteria

- [ ] AC-1: En anonym bruger ser ingen Log ud-knap i profil, indstillinger eller fejltilstande.
- [ ] AC-2: En ejer kan fortsat logge ud, og reduceren afviser en anonym logout-handling uden at nulstille identiteten.

- [ ] AC-3: Kommunikation, appnotifikation-toggle og mail-toggle vises ikke længere.
- [ ] AC-4: Profilredigering, ejerens Log ud, slet konto og faktisk notifikationsadfærd virker som hidtil.

- [ ] AC-5: Nicolai Dam vises som ND på alle omfattede profilindgange; profilknappen åbner samme skærm som før.
- [ ] AC-6: Ét navn, flere mellemrum, danske bogstaver og tomt navn håndteres efter reglen; ændret navn opdaterer avataren fra fælles state.
- [ ] AC-7: Avatar virker i lys/mørk og stor tekst uden forringet trykflade eller VoiceOver-label.

- [ ] AC-8: Aktiviteter viser sparkle i valgt og ikke-valgt tilstand, i både lys og mørk tilstand.
- [ ] AC-9: Titel, navigation og ulæst-badge er læsbare og fungerer for ejer og anonym.

## Implementation plan

### Log ud og adgang

- [ ] Spor alle logout-indgange og tilgængelig auth-tilstand på rodens fejlskærm.
- [ ] Genbrug en konsistent adgangsregel i UI og action-håndtering; bevar ejerens fejl-recovery.
- [ ] Dæk anonym/ejer samt bootstrap-fejl med målrettede reducerchecks og visuelle fixtures.

### Indstillinger

- [ ] Fjern sektionen og reducer-state/actions uden andre brugere; kontroller alle referencer før oprydning.
- [ ] Opdater katalogfixtures samt lokalisering/inventory, hvis nøgler bliver ubrugte.

### Profilavatar

- [ ] Indfør fælles initialberegning og avatar uden at give viewet API/auth-afhængigheder.
- [ ] Tilslut alle profilknapper og profilvisning til samme kilde; gennemgå bootstrap-opdatering efter navneskift.
- [ ] Dæk initialregler med små enhedstests og tilføj relevante visuelle fixtures.

### Aktivitetstab

- [ ] Udskift symbol på aktivitetstabet og opdater relevante katalogfixtures.


## Verification

### Log ud og adgang

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1, AC-2 | Anonym og ejer; injiceret bootstrap-fejl | Besøg profil og fejlskærm; send direkte anonym logout-action i test | Ingen anonym knap/effekt; ejer kan logge ud |

Ved implementering: følg ios-app/AGENTS.md og Docs/agents/simulator.md; brug native Xcode MCP til relevante build/test-kørsler. Swiftændringer kræver `python3 ios-app/scripts/lint-swift-changes.py --base HEAD` for rent uncommitted scope (ellers korrekt merge-base). UI-ændringer kræver fuldt katalogreview efter ios-app/Docs/agents/visual-review.md plus interaktion med de ændrede kontroller; dokumentér faktiske resultater separat. Brug eksisterende lokale fixtures; planen giver ikke tilladelse til reset eller produktionsændringer.

### Indstillinger

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-3, AC-4 | Ejer med profil | Åbn indstillinger; gennemgå øvrige handlinger og katalog | Sektionen er væk; øvrige indstillinger virker |

Ved implementering: følg ios-app/AGENTS.md og Docs/agents/simulator.md; brug native Xcode MCP til relevante build/test-kørsler. Swiftændringer kræver `python3 ios-app/scripts/lint-swift-changes.py --base HEAD` for rent uncommitted scope (ellers korrekt merge-base). UI-ændringer kræver fuldt katalogreview efter ios-app/Docs/agents/visual-review.md plus interaktion med de ændrede kontroller; dokumentér faktiske resultater separat. Brug eksisterende lokale fixtures; planen giver ikke tilladelse til reset eller produktionsændringer.

### Profilavatar

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-5, AC-6 | Navnefixtures og ejerprofil | Beregn eksempler; rediger navn og skift tab | Korrekte og opdaterede initialer; fallback ved intet navn |
| AC-7 | Lys/mørk, Dynamic Type og VoiceOver | Inspicer og aktiver alle profilknapper | Læsbar avatar og uændret navigation |

Ved implementering: følg ios-app/AGENTS.md og Docs/agents/simulator.md; brug native Xcode MCP til relevante build/test-kørsler. Swiftændringer kræver `python3 ios-app/scripts/lint-swift-changes.py --base HEAD` for rent uncommitted scope (ellers korrekt merge-base). UI-ændringer kræver fuldt katalogreview efter ios-app/Docs/agents/visual-review.md plus interaktion med de ændrede kontroller; dokumentér faktiske resultater separat. Brug eksisterende lokale fixtures; planen giver ikke tilladelse til reset eller produktionsændringer.

### Aktivitetstab

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-8, AC-9 | Ejer med ulæst badge og anonym | Skift tab i lys/mørk og inspicer katalog | Sparkle er synligt; titel/badge/adgang fungerer |

Ved implementering: følg ios-app/AGENTS.md og Docs/agents/simulator.md; brug native Xcode MCP til relevante build/test-kørsler. Swiftændringer kræver `python3 ios-app/scripts/lint-swift-changes.py --base HEAD` for rent uncommitted scope (ellers korrekt merge-base). UI-ændringer kræver fuldt katalogreview efter ios-app/Docs/agents/visual-review.md plus interaktion med de ændrede kontroller; dokumentér faktiske resultater separat. Brug eksisterende lokale fixtures; planen giver ikke tilladelse til reset eller produktionsændringer.

Gennemfør fælles build/lint og fuldt katalogreview én gang efter alle delændringer; de konkrete rolle-, interaktions- og datachecks ovenfor skal stadig udføres. Haptik kræver fortsat fysisk enhed, hvis det indgår.

## Human review

Not implemented yet. Forklar flow, arkitekturbeslutninger, tradeoffs, læsesti og verifikationsgrænser efter docs/agents/human-review.md.

## Handoff

- Completed: Relaterede taskplaner samlet med alle acceptkriterier, beslutninger og verifikationsscenarier bevaret. Ingen produktændringer.
- Verification results: Not run. Kun refinement og kontrol af taskstruktur/referencer.
- Blockers: None.
- Next action: Læs konteksten for delopgaverne, gennemfør implementeringsplanen og afslut med én samlet iOS-verifikation.
