# Opret aktivitet

## Aftalt adfærd

Oprettelse er opdelt i to trin i samme NavigationStack:

1. **Navn:** Påkrævet aktivitetsnavn. Feltet får automatisk fokus, når navnesiden åbnes. Videre er deaktiveret, hvis feltet er tomt eller kun indeholder mellemrum.
2. **Skabelon og spørgsmål:** Et eksplicit valg af feedbackskabelon. De øvrige skabeloner foldes væk efter valg; Skift viser dem igen. Spørgsmålsoversigten vises på samme side som skabelonen, ligesom ved redigering. Tryk på oversigten for at åbne den fælles editor, hvor spørgsmål kan redigeres, slettes, tilføjes, omarrangeres og forhåndsvises. Egne spørgsmål starter tomt. Opret aktivitet er tilgængelig på den samlede side og deaktiveret, indtil der er mindst ét spørgsmål, alle spørgsmål har tekst, og navnet er udfyldt. Oprettelse kan ikke sendes fra navnesiden eller spørgsmålseditoren.

Tilbage-navigation bevarer navn, skabelon og tilpassede spørgsmål. Skift af skabelon kræver kun bekræftelse, hvis tilpassede spørgsmål bliver erstattet. Genvalg af samme skabelon bevarer spørgsmålene.

Forhåndsvisning åbner i fuld skærm. Designsystemets lukkeknap og gennemført feedback lukker kun forhåndsvisningen og vender tilbage til spørgsmålseditoren. Prøvesvar sendes ikke til API'et. Fejl ved oprettelse bevarer kladden på det samlede trin, så brugeren kan prøve igen; knappen blokerer dobbeltindsendelse under en forespørgsel.

Redigering af eksisterende aktiviteter beholder den samlede formular og en separat spørgsmålseditor.

## Teknisk forankring

ManageActivity ejer forhåndsvisningens præsenterede FeedbackFlowCoordinator-state. TCA's presentation reducer forbinder barnets dismiss med lukning af fullScreenCover. Preview-tilstand håndteres før API-kald i feedback-reduceren.

## Verifikation

ManageActivityTests dækker starttilstand, ugyldig oprettelse, skabelonskift, beskyttelse af tilpassede spørgsmål og begge udgange fra forhåndsvisningen. Testene bruger den rigtige forælder/barn-præsentation, og preview-testen efterlader API-afhængigheden uimplementeret for at opdage utilsigtede indsendelser.
