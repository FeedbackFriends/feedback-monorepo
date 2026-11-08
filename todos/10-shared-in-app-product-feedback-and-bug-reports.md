---
status: in-progress
areas: [ios, backend]
created: 2026-11-06
updated: 2026-11-08
---

# Send produktfeedback og fejlrapporter fra appen til databasen

## Problem and outcome

“Send feedback til os” og “Rapportér en fejl” åbner i dag mailappen direkte. Brugeren skal kunne gennemføre begge handlinger inde i appen og få en tydelig kvittering, når data er gemt.

## Scope

iOS-ejer og anonym bruger; genbrug af eksisterende feedback-UI; backendkontrakt og separat persistens for produkthenvendelser; fejlformular og eksplicit mailalternativ. Ingen adminportal, vedhæftninger eller ændring af mødefeedback/statistik.

## Context

- Priority: 10 of 25. Close the existing support/reporting work so users can reliably report product problems.

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
- Implementation decisions 2026-11-06: support_submission uses account FK ON DELETE CASCADE; account deletion removes contact text/metadata too. UUID is globally unique, actor is always token subject. Identical retries return the original receipt; a reused UUID with different content returns 409, and another account cannot access that UUID.
- Client retains the exact submitted payload for unchanged retries; editing after an error creates a new submission identity. Metadata is app version/build and OS version only. No device name/identifier, logs or meeting data.
- Existing emoji controls are extracted into a shared DesignSystem value/action view, reused by meeting feedback and the new form without a fake Event/session.
- Unresolved: None
- Execution authorization: brugeren bestilte hele tasks-backloggen implementeret med separate taskcommits. Seneste instruktion: stop sessionen efter denne email/feedback-feature; det samlede mål sættes på pause efter commit. Ingen push, deployment, produktionsændring eller lokal reset/testindsendelse er autoriseret. Det tidligere spørgsmål om lokal testdata/reset er ubesvaret.

## Acceptance criteria

- [ ] AC-1: Begge indgange åbner deres respektive flow i appen for ejer og anonym uden mailapp eller PIN.
- [x] AC-2: Produktfeedback bruger eksisterende svarkomponenter; fejlformular validerer beskrivelse, tekstgrænser og valgfri mail.
- [x] AC-3: Gyldig indsendelse persisteres præcis én gang med korrekt type; kvittering vises efter succes, og mødestatistik, deltagelse og notifikationer påvirkes ikke.
- [x] AC-4: Netværks-/serverfejl bevarer teksten, giver en forståelig fejl og tillader sikkert retry; dobbelttryk og mistet serversvar giver ingen dublet.
- [ ] AC-5: Mailalternativ kræver et særskilt tryk og bliver i appen; manglende mailopsætning giver mulighed for at kopiere adressen.
- [x] AC-6: Backend validerer og kræver gyldigt token for både anonym/ejer; metadata og kontaktmail håndteres efter dokumenteret model/slettepolitik.

## Implementation plan

### Phase 1 — Backend og persistens

Outcome: Et valideret, selvstændigt produkthenvendelsesflow. Dependencies: eksisterende Firebase-auth og persistence patterns.

- [x] Tilføj tynd controller, service, input/output og separat model/table/repo med inkrementel Liquibase-migration; definer idempotent retry og kontosletningsrelation.
- [x] Dæk begge henvendelsestyper, anonym/ejer/uden token, validering, metadata og dublet/retry med API- og persistenschecks. Verificer at mødesvar og notifikationer ikke ændres.

### Phase 2 — Kontrakt og adapter

Outcome: Native domain-service med genereret transport. Depends on phase 1.

- [x] Kør `./scripts/generate-api-artifacts.sh` fra roden; gennemgå Swift/TypeScript/kontrakt-diff uden håndredigering.
- [x] Tilføj Domain-service og live adapter med submission-id samt typed result/error; ingen genererede typer i feature-state.
- [x] Verificer serialisering og retries i adaptertests.

### Phase 3 — iOS-flows

Outcome: Feedback og fejlrapport sendes fra appen. Depends on phase 2.

- [x] Tilføj destinations/reducere under passende featureejerskab; genbrug svarkontroller gennem en afkoblet UI-/stategrænse, ikke en opdigtet mødesession.
- [x] Implementer formularer, validering, loading, fejl med bevaret input, sikker retry og serverbekræftet kvittering; luk/annuller uden utilsigtet indsendelse.
- [x] Tilføj eksplicit in-app mailcomposer via systemadapter og kopi-fallback; opdater dansk/engelsk lokalisering og inventory.
- [x] Dæk indsendelse/succes/fejl/dobbelttryk/annullering med reducerchecks og katalogfixtures.

### Phase 4 — Samlet verifikation

Outcome: Dokumenteret klient/server-rejse uden mødedata-sideeffekter. Depends on phase 3.

- [x] Kør relevante API-/persistens-/adapter-/reducertests og kontraktchecks.
- [ ] Verificer begge indgange på localhost som ejer og anonym samt mailalternativet; kun efter særskilt autorisation til nødvendige lokale testindsendelser.
- [x] Gennemfør iOS build/lint og fuldt katalogreview; dokumentér dataejerskab, slettepolitik og eventuelle begrænsninger i human-review-handoff.

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

MoreSection præsenterer ProductContact, som ejer lokal input-/request-/receipt-state. EmojiRatingView er trukket ud som en ren DesignSystem-værdi/action-komponent og genbruges i mødefeedback og produktfeedback; ingen opdigtet Event/PIN eller ny feedbackkoordinator bruges. Domain ProductContactInput/Receipt passerer APIClient; Adapters mapper til genereret transport uden at opdatere Bootstrap/cache. Uændrede retries beholder payload og UUID; redigering efter fejl tildeler nyt UUID til nyt indhold. Reducerens guards afviser invalid/dobbelt send og in-flight inputændringer. Kvittering kræver serverens matchende receipt.

Backendcontroller validerer og udleder account fra JWT; service ejer betinget validering og idempotens-/ejerkontrol, repository ejer atomisk insert-or-get. Ny separat tabel med account-CASCADE følger kontodataejerskab og holder kontaktdata ude af mødesvar/statistik/notifikationer. Unikt globalt UUID giver samme receipt ved samtidige retries; andet indhold giver 409 og anden konto 403. Metadataadapteren leverer kun appversion/build og OS-version.

Mail er en eksplicit sidevej: SystemClient afklarer capability/adresse/clipboard, DesignSystem wrapper MFMailComposeViewController, og reduceren præsenterer composer eller copy-alert. Den vej kalder aldrig databasen og viser ingen databasekvittering. Ingen nye SDK/runtime-dependencies eller genererede typer i feature-state. Beslutninger om særskilt lagring/genbrug var planlagte; CASCADE, præcis retry-model og fælles UI-udtræk er implementeringsvalgene.

Læsesti: `ios-app/Modules/Sources/MoreFeature/MoreSection/MoreSection.swift` → `ios-app/Modules/Sources/MoreFeature/ProductContact/ProductContact.swift`/`ProductContactView.swift` → `ios-app/Modules/Sources/Adapters/APIClient/Live/APIClient+LiveProductContact.swift` → `backend/apps/api/src/main/kotlin/dk/example/feedback/service/SupportSubmissionService.kt` → `backend/lib/persistence/src/main/kotlin/dk/example/feedback/persistence/repo/SupportSubmissionRepo.kt` og migration 0026. Varig kontrakt/retention/mail-dokumentation: `docs/product-contact.md`. Testene ProductContactTests, ProductContactAdapterTests og SupportSubmissionTest viser de vigtige grænser.

## Handoff

### Contact presentation follow-up (2026-11-06)

- User requests fixing both forms dismissing immediately on LetsGrow Manager. No reset or submission needed.
- Diagnosis: sheet on MoreSectionView's structural Group creates multiple presenters; supplied logs show competing presentations and dismissal.
- Plan: one stable profile presenter, retaining MoreSection state and existing form behavior.
- Acceptance: both forms remain open, close back to profile, and reopen without unintended dismissal during typing/sync.
- Verification planned: native build, existing contact reducer tests, changed-line lint, full catalog and live open/close without submission.
- Implemented: MoreFeature-owned moreSectionDestinations modifier moves contact presentation from structural Group sections to the single profile List container in TabbarView. State, reducer, form content and transport remain unchanged; follows existing accountSectionDestinations pattern. Preview shares one store.
- Verification 2026-11-06: Feedback Localhost / LetsGrow Manager iOS 27.2 buildForTesting passed; nine discovered contact tests passed (0 failed/skipped). Initial suite-name selection returned no results; rerun with exact discovered identifiers passed. SwiftLint --base HEAD: 0 changed-line violations in two files. ScreenSnapshots capture test passed; published/reviewed 69 PNGs, 0 pending, approved baselines preserved. Comparison reports 15 added / 91 removed against historical baselines; no inventory changed by this fix. Findings and hashes: screenshots/review/contact-fix-findings.json; gallery screenshots/index.html.
- Launch: RunProject succeeded, launch reference 7cd8c8ba80; updated app left running. Native interaction Start returns simulator=true and a key, but immediate Synthesize says Session not found; EndSession also says session does not exist. Cleanup attempted. No live open/close, typing or sync acceptance claimed; retain task.
- Next action for this fix: once native device interaction works, open profile → each contact entry, type without submitting, wait through sync, close back to profile and reopen. Verify anonymous entry too. No database reset needed.


- Completed: Implementeret end-to-end kode for in-app produktfeedback og fejlrapporter, separat persistens/migration, idempotent retry/ejerskab, genereret kontrakt/klienter, native Domain/adapter, formularer/validering og eksplicit in-app Mail/copy-fallback. Metadata og kontosletning dokumenteret i `docs/product-contact.md`. Ingen push/deploy/reset eller produktions-/lokale liveindsendelser udført.
- Verification results: 2026-11-06: `./gradlew :api:test :persistence:test` bestået. API: 38 tests, 0 failures/errors/skipped; heraf 5 nye SupportSubmissionTest-integrationstests med virkelig repository, anvendt Liquibase-migration og isoleret H2, inklusive samtidighed/cascade/uforandrede mødedata. Persistence-tasken har 0 selvstændige tests; persistensadfærden er dækket i API-integrationerne, ikke påstået som separate persistens-unit-tests. Eksisterende Gradle/JVM/deprecation-warnings består. Root API-generator kørt igen efter DTO-/enum-placering; kontrakt og Swift/TypeScript inspiceret; eksisterende generator-resourcewarnings, ingen håndredigering. iOS Feedback Localhost / LetsGrow Manager iOS 27.2: buildForTesting bestået, UnitTests discovery 231 enabled fra AppTests/InsightsTests, RunAllTests 254 passed, 0 failed/skipped. SwiftLint --base HEAD: 0 violations i 26 filer. Lokaliseringscheck: 335 gyldige nøgler; direct-copy guard: 224 filer. ScreenSnapshots: 1 passed, 69 PNGer publiceret; alle gennemgået via 58 uændrede hashes og 11 friske ændrede/nye billeder. `screenshots/review/product-contact-findings.json` har IDs/hashes; `screenshots/index.html` galleri; baselines bevaret. RunProject byggede og lancerede appen succesfuldt (launch reference 7cdf46e700). Webs genererede klient: Node 20.19.0 npm lint og tsc --noEmit bestået. Incidental Package.resolved ændring fra generatoren er gendannet.
- Blockers: AC-1/AC-5 og den krævede localhost-rejse som ejer/anonym med faktisk composer/copy/keyboard er endnu ikke live-afprøvet. Native DeviceInteractionStartWorkspaceSession returnerer nøgle, men Synthesize/EndSession kan ikke finde den, mens nyt Start siger simulatoren er optaget af samme nøgle; se `todos/13-ios-text-input-full-surface-focus.md` for nøjagtig oprindelig fejl. Ingen fallbackværktøjer anvendt. Fysisk Mail/VoiceOver/tema/stor tekst og localhost-testdataautorisation afventer; opdateret i `todos/17-ios-physical-device-verification.md`. Derfor beholdes taskfilen; alle required checks hævdes ikke afsluttet.
- Next action: Efter brugerens genoptagelse: gendan native Xcode-interaktionssessionen, få konkret lokal testindsendelsesautorisation (reset er ikke nødvendigt for denne feature), og gennemfør begge indgange som ejer/anonym samt Mail configured/unconfigured, offline/retry og fysisk/tastatur/tilgængelighed. Luk først tasken efter den resterende verifikation. Backend + migration skal deployes før iOS-udgivelse, kun ved særskilt autorisation. Sessionen stopper efter denne features commit efter brugerens seneste instruktion; fortsæt ikke til Maestro/web/Not Found af dig selv.
