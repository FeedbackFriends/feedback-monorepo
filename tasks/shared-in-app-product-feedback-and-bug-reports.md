---
status: ready
areas: [ios, backend]
created: 2026-11-06
updated: 2026-11-06
---

# Send produktfeedback og fejlrapporter fra appen til databasen

## Problem and outcome

“Send feedback til os” og “Rapportér en fejl” åbner i dag mailappen direkte. Brugeren skal kunne gennemføre begge handlinger inde i appen og få en tydelig kvittering, når data er gemt.

## Scope

iOS-ejer og anonym bruger; genbrug af eksisterende feedback-UI; backendkontrakt og separat persistens for produkthenvendelser; fejlformular og eksplicit mailalternativ. Ingen adminportal, vedhæftninger eller ændring af mødefeedback/statistik.

## Context

- ios-app/Modules/Sources/MoreFeature/MoreSection/MoreSection.swift: begge actions kalder systemClient.openEmail; ios-app/Modules/Sources/MoreFeature/MoreSection/MoreSectionView.swift ejer kontaktindgangene.
- ios-app/Modules/Sources/Adapters/SystemClient/SystemClientLive.swift bygger mailto-URL. DeviceInfo.summary indsættes i mailteksten i dag.
- ios-app/Modules/Sources/FeedbackFlowFeature/FeedbackFlowCoordinator.swift er bundet til FeedbackEventDto/PIN/session; genbrug af UI kræver afkobling af transport/session-state.
- backend/apps/api/src/main/kotlin/dk/example/feedback/controller/FeedbackController.kt og service/FeedbackService.kt: eksisterende /feedback/start og /submit kræver PIN, session og account; én indsendelse pr. session og manager-notifikationer.
- backend/lib/persistence/src/main/kotlin/dk/example/feedback/persistence/table/FeedbackTable.kt; backend/lib/persistence/src/main/resources/db/changelog/; backend/docs/agents/persistence.md
- docs/agents/api-contract.md; ios-app/Docs/agents/api-contract.md; ios-app/Modules/Tests/AppTests/ReducerTests/More/MoreSectionTests.swift

## Decisions and open questions

- Bekræftet: kontaktindgange åbner in-app flows og gemmer data på serveren; appen må ikke automatisk skifte til mailappen.
- Antagelse: “brug den eksisterende” betyder genbrug af feedbackkomponenter og svaroplevelse. Produktfeedback får separat submission-model/endpoint/persistens, så den ikke tælles som mødesvar eller kræver en skjult permanent PIN-session. Forklar denne arkitekturbeslutning ved implementering.
- Forslag til produktfeedback: eksisterende emoji-kontrol med “Hvordan oplever du LetsGrow?” og en kommentar “Hvad kan vi gøre bedre?”. Kræv mindst en bedømmelse eller ikke-tom kommentar.
- Fejlformular: påkrævet “Beskriv fejlen”, valgfri “Hvad forventede du der skulle ske?” og valgfri kontaktmail med forklaringen “Skriv din mailadresse, hvis vi må kontakte dig om fejlen.” Maks. 5000 tegn pr. tekstfelt; synlig validering.
- Antagelse: “eller skrive en mail” løses med separat, eksplicit “Skriv en mail i stedet”, som åbner systemets mailkomponering i et sheet i appen. Hvis mailkomponering ikke er tilgængelig, tilbydes kopiering af kontaktadressen; ingen automatisk ekstern app. Mailalternativets data gemmes ikke som en sendt databaseformular.
- Genbrug Firebase-anonym auth for anonym bruger; intet krav om oprettelse af ejerkonto. Server udleder account fra token og ejer modtagelsen; klient vælger ikke vilkårlig manager/modtager.
- Registrer type, svar/tekst, server-tid, eventuel kontaktmail og en lille dokumenteret mængde metadata (appversion/build, OS-version). Ingen automatisk upload af logs, tokens eller mødesvar. Afklar kontoens slettepolitik og dokumentér den valgte relation i migrationen.
- Klient-genereret submission-id og serverunikhed sikrer genforsøg efter mistet svar uden dobbeltlagring. Lås send under afsendelse; behold input ved fejl; vis først kvittering efter serverbekræftelse.
- Unresolved: None
- Execution constraints: Kun refinement er bestilt. Ingen implementering, commits, deployment, produktionsdata eller nulstilling af lokale data er udført eller autoriseret af denne taskplan.

## Acceptance criteria

- [ ] AC-1: Begge indgange åbner deres respektive flow i appen for ejer og anonym uden mailapp eller PIN.
- [ ] AC-2: Produktfeedback bruger eksisterende svarkomponenter; fejlformular validerer beskrivelse, tekstgrænser og valgfri mail.
- [ ] AC-3: Gyldig indsendelse persisteres præcis én gang med korrekt type; kvittering vises efter succes, og mødestatistik, deltagelse og notifikationer påvirkes ikke.
- [ ] AC-4: Netværks-/serverfejl bevarer teksten, giver en forståelig fejl og tillader sikkert retry; dobbelttryk og mistet serversvar giver ingen dublet.
- [ ] AC-5: Mailalternativ kræver et særskilt tryk og bliver i appen; manglende mailopsætning giver mulighed for at kopiere adressen.
- [ ] AC-6: Backend validerer og kræver gyldigt token for både anonym/ejer; metadata og kontaktmail håndteres efter dokumenteret model/slettepolitik.

## Implementation plan

### Phase 1 — Backend og persistens

Outcome: Et valideret, selvstændigt produkthenvendelsesflow. Dependencies: eksisterende Firebase-auth og persistence patterns.

- [ ] Tilføj tynd controller, service, input/output og separat model/table/repo med inkrementel Liquibase-migration; definer idempotent retry og kontosletningsrelation.
- [ ] Dæk begge henvendelsestyper, anonym/ejer/uden token, validering, metadata og dublet/retry med API- og persistenschecks. Verificer at mødesvar og notifikationer ikke ændres.

### Phase 2 — Kontrakt og adapter

Outcome: Native domain-service med genereret transport. Depends on phase 1.

- [ ] Kør `./scripts/generate-api-artifacts.sh` fra roden; gennemgå Swift/TypeScript/kontrakt-diff uden håndredigering.
- [ ] Tilføj Domain-service og live adapter med submission-id samt typed result/error; ingen genererede typer i feature-state.
- [ ] Verificer serialisering og retries i adaptertests.

### Phase 3 — iOS-flows

Outcome: Feedback og fejlrapport sendes fra appen. Depends on phase 2.

- [ ] Tilføj destinations/reducere under passende featureejerskab; genbrug svarkontroller gennem en afkoblet UI-/stategrænse, ikke en opdigtet mødesession.
- [ ] Implementer formularer, validering, loading, fejl med bevaret input, sikker retry og serverbekræftet kvittering; luk/annuller uden utilsigtet indsendelse.
- [ ] Tilføj eksplicit in-app mailcomposer via systemadapter og kopi-fallback; opdater dansk/engelsk lokalisering og inventory.
- [ ] Dæk indsendelse/succes/fejl/dobbelttryk/annullering med reducerchecks og katalogfixtures.

### Phase 4 — Samlet verifikation

Outcome: Dokumenteret klient/server-rejse uden mødedata-sideeffekter. Depends on phase 3.

- [ ] Kør relevante API-/persistens-/adapter-/reducertests og kontraktchecks.
- [ ] Verificer begge indgange på localhost som ejer og anonym samt mailalternativet; kun efter særskilt autorisation til nødvendige lokale testindsendelser.
- [ ] Gennemfør iOS build/lint og fuldt katalogreview; dokumentér dataejerskab, slettepolitik og eventuelle begrænsninger i human-review-handoff.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1, AC-2 | Ejer og anonym; lokalt API | Åbn begge indgange; prøv tom/whitespace, ugyldig mail og længdegrænser | Ingen ekstern navigation; tydelig validering |
| AC-3, AC-4, AC-6 | Injicerede fejl og API/persistence-fixtures | Indsend, dobbelttryk, mist svar og retry samme submission-id; tjek database/statistik og autorisation | Én record, korrekt type og ingen mødefeedback-sideeffekter |
| AC-4 | Offline/500-fixture | Send, fejl, gendan netværk og retry | Input bevaret og kvittering først efter serverbekræftelse |
| AC-5 | Mail configured og ikke configured | Åbn eksplicit mailalternativ; annuller eller kopiér adresse | In-app composer eller kopiering; ingen automatisk appskift |

Ved implementering: følg ios-app/AGENTS.md og Docs/agents/simulator.md; brug native Xcode MCP til relevante build/test-kørsler. Swiftændringer kræver `python3 ios-app/scripts/lint-swift-changes.py --base HEAD` for rent uncommitted scope (ellers korrekt merge-base). UI-ændringer kræver fuldt katalogreview efter ios-app/Docs/agents/visual-review.md plus interaktion med de ændrede kontroller; dokumentér faktiske resultater separat. Brug eksisterende lokale fixtures; planen giver ikke tilladelse til reset eller produktionsændringer.

Backend: kør `./gradlew :api:test :persistence:test` fra backend/ for de berørte flows; warnings fejler buildet. Efter API-ændringer køres rodens artifact-generator. Indsendelsesjourney kræver dokumenteret lokal fixture og konkret testdataautorisation.

## Human review

Not implemented yet. Implementeringen skal forklare flow, arkitekturbeslutninger, tradeoffs, læsesti og verifikationsgrænser efter docs/agents/human-review.md.

## Handoff

- Completed: Kodenære kilder undersøgt; scope, antagelser og plan gemt. Ingen produktændringer.
- Verification results: Not run. Kun refinement.
- Blockers: None
- Next action: Fastlæg request/response og support submission-model med de dokumenterede antagelser; læs eksisterende auth/persistensmønstre før fase 1.
