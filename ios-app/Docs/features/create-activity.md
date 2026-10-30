# Opret aktivitet

## Aftalt adfærd

Oprettelse er opdelt i tre skærme i samme NavigationStack:

1. **Navn:** Påkrævet aktivitetsnavn. Videre er deaktiveret, hvis feltet er tomt eller kun indeholder mellemrum.
2. **Skabelon:** Et eksplicit valg af feedbackskabelon. Videre er deaktiveret, indtil en skabelon er valgt. De øvrige skabeloner foldes væk efter valg; Skift viser dem igen.
3. **Spørgsmål:** Skabelonens spørgsmål kan redigeres, slettes, tilføjes og omarrangeres. Egne spørgsmål starter tomt. Forhåndsvisning og Opret aktivitet er tilgængelige her. Opret aktivitet er deaktiveret, indtil der er mindst ét spørgsmål, alle spørgsmål har tekst, og navnet er udfyldt. Oprettelse kan ikke sendes fra tidligere trin.

Tilbage-navigation bevarer navn, skabelon og tilpassede spørgsmål. Skift af skabelon kræver kun bekræftelse, hvis tilpassede spørgsmål bliver erstattet. Genvalg af samme skabelon bevarer spørgsmålene.

Forhåndsvisning åbner i fuld skærm. Designsystemets lukkeknap og gennemført feedback lukker kun forhåndsvisningen og vender tilbage til spørgsmålstrinnet. Prøvesvar sendes ikke til API'et. Fejl ved oprettelse bevarer kladden på sidste trin, så brugeren kan prøve igen; knappen blokerer dobbeltindsendelse under en forespørgsel.

Redigering af eksisterende aktiviteter beholder den samlede formular og en separat spørgsmålseditor.

## Teknisk forankring

ManageActivity ejer forhåndsvisningens præsenterede FeedbackFlowCoordinator-state. TCA's presentation reducer forbinder barnets dismiss med lukning af fullScreenCover. Preview-tilstand håndteres før API-kald i feedback-reduceren.

## Verifikation

ManageActivityTests dækker starttilstand, ugyldig oprettelse, skabelonskift, beskyttelse af tilpassede spørgsmål og begge udgange fra forhåndsvisningen. Testene bruger den rigtige forælder/barn-præsentation, og preview-testen efterlader API-afhængigheden uimplementeret for at opdage utilsigtede indsendelser.
