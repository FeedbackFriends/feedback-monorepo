---
status: in-progress
areas: [ios]
created: 2026-11-06
updated: 2026-11-08
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

- Priority: 12 of 25. Review and close already-implemented navigation/profile work; avoid expanding soon-to-be-retired manager UI.

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

- [x] Spor alle logout-indgange og tilgængelig auth-tilstand på rodens fejlskærm.
- [x] Genbrug en konsistent adgangsregel i UI og action-håndtering; bevar ejerens fejl-recovery.
- [x] Dæk anonym/ejer samt bootstrap-fejl med målrettede reducerchecks og visuelle fixtures.

### Indstillinger

- [x] Fjern sektionen og reducer-state/actions uden andre brugere; kontroller alle referencer før oprydning.
- [x] Opdater katalogfixtures samt lokalisering/inventory, hvis nøgler bliver ubrugte.

### Profilavatar

- [x] Indfør fælles initialberegning og avatar uden at give viewet API/auth-afhængigheder.
- [x] Tilslut alle profilknapper og profilvisning til samme kilde; gennemgå bootstrap-opdatering efter navneskift.
- [x] Dæk initialregler med små enhedstests og tilføj relevante visuelle fixtures.

### Aktivitetstab

- [x] Udskift symbol på aktivitetstabet og opdater relevante katalogfixtures.


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

RootFeature gemmer den senest kendte auth-tilstand fra AuthClient/gyldigt Bootstrap. Ved startup-fejl kan ejeren dermed logge ud uden at gætte en rolle, mens ukendt/anonym identitet ikke får knappen. Root afleder canSignOut fra aktiv Bootstrap, ellers den kendte auth-tilstand, og sætter Logout-reducerens guard før dens håndtering; anonyme direkte logout-actions udfører ingen effekt. Eksplicit anonym navigation til signup viser signup uden at nulstille identiteten.

ProfileAvatarView i DesignSystem beregner grafemer fra første/sidste navneord, uden auth-/Domain-afhængigheder. Features leverer kun ejernavn fra deres fælles Bootstrap; tomme/anonyme navne bruger personikon. Profilindstillingernes eksisterende snapshot opdateres fra Bootstrap ved ModifyAccount-succes, så profilavataren ikke viser gammelt navn. Kommunikation-state/actions, controls, fixture og fem ubrugte oversættelsesnøgler er fjernet; det eksisterende link til OS-notifikationer bevares. Aktivitetstabet bruger sparkle og uændret badge.

Læsesti: `ios-app/Modules/Sources/RootFeature/RootFeature.swift` → `RootFeatureView.swift`/`Logout.swift` → `ios-app/Modules/Tests/InsightsTests/RootNavigationTests.swift` → `ios-app/Modules/Sources/DesignSystem/ReusableViews/ProfileAvatarView.swift`/`ios-app/Modules/Tests/AppTests/ProfileAvatarTests.swift` → `ios-app/Modules/Sources/MoreFeature/AccountSection/AccountSection.swift` og `ProfileSettingsView.swift`. De etablerede TCA-/Bootstrap-/DesignSystem-grænser bevares; auth-state-retention er implementeringsvalget til bootstrap-fejl.

## Handoff

- Completed: Logout UI/reducer-guard, fjernet Kommunikation og døde oversættelser/state, fælles initialavatar på alle tre profilknapper og profilindstillinger, profilnavn synkroniseret ved save, sparkle-tab. Katalogtilstande for ejerindstillinger og ejerens startup-fejl tilføjet; anonym startup-fejl skjuler logout.
- Verification results: 2026-11-06 Feedback Localhost / LetsGrow Manager iOS 27.2: buildForTesting bestået. UnitTests discovery: 215 enabled fra både AppTests og InsightsTests. RunAllTests: 235 passed, 0 failed/skipped (inkl. parameteriserede navnetests). SwiftLint --base HEAD: 0 violations i 13 filer. validate-localization.py: 308 gyldige nøgler; localized-copy guard: 216 filer. ScreenSnapshots: 1 passed; 58 billeder publiceret og alle gennemgået. `screenshots/review/profile-findings.json` har IDs/hashes; `screenshots/index.html` har galleri. Ingen baselines accepteret.
- Blockers: Live rolle-/navigation-/navneændringsrejse, mørk tilstand, Dynamic Type og VoiceOver er endnu ikke kørt pga. native Xcode DeviceInteraction-sessionfejlen, dokumenteret i `todos/13-ios-text-input-full-surface-focus.md`. Katalog og reducerchecks er ikke fuld runtime-evidens. Fysisk kontrol er føjet til `todos/17-ios-physical-device-verification.md`.
- Next action: Når native session virker, åbn profil/indstillinger som ejer og anonym, gem et navn og kontrollér begge tabs/profilavatar, kontroller logout-adgang og badge i begge temaer samt stor tekst/VoiceOver. Behold tasken indtil required verification er dækket.
