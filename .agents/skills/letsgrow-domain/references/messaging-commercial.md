# Messaging And Commercial Guidance

Use this for website copy, CTAs, Danish messaging, pricing, and commercial model decisions.

## Language And Tone

Customer-facing launch website, marketing copy, and most UX copy should be Danish unless the user asks otherwise.

Use the implemented landing page in `web/src/components/landing` as the source of truth for current public wording. The live page intentionally uses broader copy around meetings, workshops, talks, activities, and App Store download CTAs.

Latest landing-page language audit: 2026-05-29.

Tone:

- simple
- concrete
- calm
- useful
- confident without hype

Avoid American SaaS cliches, broad culture claims, generic "unlock growth" language, HR-platform language, and `AI-powered` as the launch message.

## Landing-Page Language Pattern

The current page is meeting-led, not meeting-only:

- Hero broadens the promise: `møder, workshops, oplæg og andre aktiviteter`.
- Problem section sharpens the recognizable moment: `Alle nikker. Ingen siger noget.`
- Workflow copy uses `mødet` because the calendar behavior is easiest to understand through one concrete meeting.
- Outcome copy stays practical: what worked, honest feedback, development over time, better meetings.
- CTA copy is app-first: `Hent på App Store`, `Hent appen`, and `Prøv det helt gratis`.

Use this pattern when writing new public copy:

- lead with `møde` when the user needs a concrete mental model
- broaden to `workshop`, `oplæg`, or `aktivitet` when describing product scope
- keep `feedback` tied to a just-finished activity, not an abstract survey program
- prefer `hvad der faktisk virker` over broad improvement or growth language
- keep setup anchored in familiar calendar tools and the generated LetsGrow email for the activity
- make repeatability about the owner and the format, not necessarily the same participants

Avoid forcing every sentence to mention every use case. The page works because it starts concrete and expands only where needed.

## Approved Copy Directions

Use or adapt:

- `Bliv klogere på hvad der virker`
- `Få ærlig feedback efter møder, workshops, oplæg og andre aktiviteter`
- `Se mønstre, juster undervejs og bliv bedre til det, der gør en forskel`
- `Alle nikker. Ingen siger noget.`
- `Men hvad tænkte de egentlig?`
- `De fleste møder føles som succes i øjeblikket`
- `Uden ærlig feedback ved du ikke, hvad der faktisk virkede`
- `Fra møde til indsigt - i 4 enkle trin`
- `Planlæg mødet som du plejer`
- `Tilføj én deltager`
- `Invitér aktivitetens LetsGrow-mail, så ved systemet, at mødet skal have feedback bagefter`
- `LetsGrow opretter en mail til aktiviteten, som du kan invitere fra din kalender`
- `Deltagerne giver feedback`
- `Efter mødet svarer deltagerne på få, relevante spørgsmål direkte fra mobilen`
- `Se hvad der faktisk virker`
- `Få klare indsigter og følg din udvikling over tid`
- `Opdag hvad der virker (og hvad der ikke gør)`
- `Få ærlig feedback - ikke bare "det var godt"`
- `Følg din udvikling over tid`
- `Skab bedre møder, hver gang`
- `Prøv det helt gratis`
- `Giv dit næste møde feedback - uden ekstra arbejde`
- `Feedbacken er anonym, så deltagerne kan svare ærligt`
- `Se hvordan dit format udvikler sig fra gang til gang`

Avoid or rewrite:

- generic personal-growth copy disconnected from a specific meeting/activity
- generic "team app for the office" copy without a concrete repeatable format
- HR engagement or performance-review framing
- long survey language
- enterprise procurement or sales-heavy CTAs on the public landing page

## Homepage Narrative

Recommended structure:

1. Hero: make "what works" the emotional hook and explain honest feedback after meetings, workshops, talks, and activities.
2. Calendar trust: show familiar tools such as Teams, Outlook, Google Calendar, Apple Calendar, Zoho Calendar, and Proton Calendar.
3. Problem: people nod, but the owner does not know what they actually thought.
4. How it works: plan as usual, invite the generated LetsGrow email for the activity, participants answer from mobile, owner sees what works.
5. Outcomes: what worked, honest feedback, development over time, better meetings each time.
6. CTA: free App Store trial/download.

Hero must preserve the broad landing-page promise. Do not force it back to recurring meetings unless the user explicitly asks for a repositioning.

The homepage succeeds when:

- a reader understands that LetsGrow gets honest feedback after meetings and activities
- a reader understands that the value compounds when the owner repeats a format over time
- participants understand whether their feedback is anonymous
- the page feels concrete, Danish, and practical
- the workflow sounds effortless because it starts in the calendar
- the app CTA is clear and immediate
- a founder would not mistake LetsGrow for a broad HR or survey product

Each section has a job:

- Hero: state the "what works" promise and the feedback-after-activity scope.
- Problem: make the gap between polite nods and honest feedback recognizable.
- How it works: show the calendar-based feedback workflow.
- Outcomes: translate the product into practical insight and improvement over time.
- CTA: turn interest into App Store download.

## CTA

Default primary CTA:

- `Hent på App Store`
- `Hent appen`

Default destination:

- Apple App Store URL from `web/src/components/landing/content.ts`

Secondary CTA:

- `Se hvordan det virker`

Avoid `Book demo`, `Talk to sales`, early-access Typeform, or public checkout as the primary landing-page action unless the operating model changes.

## Commercial Model

Current landing page sells:

- honest feedback after meetings and activities
- clarity about what actually worked
- visible patterns and development over time
- a lightweight calendar-based flow
- free app download

Do not sell "more survey responses."

Do not sell a broad office team app unless the strategy is intentionally changed. The sharper wedge is for owners of repeatable formats who need feedback across sessions.

Commercial direction should not override the current landing page. If pricing or paid pilots are discussed, keep them behind the scenes until the app-first public CTA changes.

Expansion path:

1. Land with one meeting/activity owner.
2. Prove value on a small number of meetings or activities.
3. Add more owners inside the workspace.
4. Later expand to departments or larger company usage.

## Pricing

Launch with owner-based pricing inside one workspace subscription.

Avoid participant-based pricing because it makes cost unpredictable and discourages inviting the right people.

Suggested validation phases:

- Design partner: free for 6-8 weeks with active feedback calls.
- Early access paid, if the app-first motion changes: 499 DKK/month per workspace, includes 1 owner, up to 3 active meetings/activities, and up to 25 participants total.
- Extra owner: 299 DKK/month.
- Annual early-access option: 4,990 DKK/year.
- Later self-serve: Starter 499 DKK/month, Team 1,499 DKK/month, Business custom.

Keep pricing semi-private until the offer is validated. Do not add a full public pricing table too early.

Pricing principles:

- keep the first purchase small
- charge for owner value, not employee reach
- avoid participant-based pricing because it discourages inviting the right people
- avoid per-meeting pricing unless a future packaging test proves it clearer than owner-based pricing
- do not create too many plans at launch
- do not require annual contracts early
- make expansion obvious through more owners, more teams, and better reporting

## Payment Timing

Do not ask for card details before the team sees first real value.

Early default:

- free pilot or founder-led setup
- no credit card upfront
- no self-serve checkout
- manual invoicing only if a paid pilot is needed

Later:

- 14-day free trial
- no credit card upfront
- workspace owner starts subscription
- extra owners adjust the workspace subscription

Manual paid pilots, if needed, should use one fixed invoice or monthly fee. Do not build a full billing flow just to support early paid pilots.
