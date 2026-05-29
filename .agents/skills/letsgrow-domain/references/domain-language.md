# Domain Language

Use this when work touches code, API contracts, generated clients, tests, or UX copy that names LetsGrow concepts.

## Naming Rule

Keep code/API names stable. Make customer-facing copy sound like recurring meeting improvement.

- In code and API contracts, use the canonical model names: `Activity`, `Event`, `Feedback`, `Question`, `ParticipantEvent`, `Workspace`, `Manager`.
- In manager-facing product copy, prefer `recurring meeting`, `meeting`, `meeting owner`, `session`, and plain Danish equivalents.
- Avoid exposing `Activity` or `Event` as visible product language unless the surrounding screen is developer/admin-facing.
- If a term conflicts with `ios-app/CONTEXT.md`, follow `CONTEXT.md` or ask before changing the domain language.

## Project Terms

### Activity

Canonical code/API term for a manager-owned recurring meeting configuration.

An `Activity` groups:

- title, agenda, location, duration, and run mode
- current feedback questions
- invited participants
- one or more `Event` occurrences
- trend analytics across comparable events

User-facing copy should usually say `recurring meeting` or `meeting`, not `activity`.

### Event

Canonical code/API term for one scheduled occurrence of an `Activity`.

An `Event` has:

- scheduled date and duration
- optional location
- join pin code
- question snapshot
- participant feedback and summaries

User-facing copy should usually say `session`, `meeting occurrence`, or simply `meeting`, depending on context. Avoid `event` in manager-facing visible copy for the session detail flow.

### Session

User-facing name for an `Event`, especially in the iOS app.

Use this when the user is looking at a single occurrence of a recurring meeting. Do not rename API contracts from `Event` to `Session` without a deliberate migration.

### Focus

Legacy/user-facing name for an `Activity` in parts of the iOS app.

Use `recurring meeting` for new marketing and product copy unless the existing screen already uses `Focus` consistently.

### Meeting Owner

Product and marketing term for the person responsible for improving one or more recurring meetings.

In code this may appear as `Manager` or `Owner`. Prefer `meeting owner` in strategy, UX, and marketing copy.

### Workspace

Commercial/account container for one company or team.

Launch default:

- one workspace per company or team
- one workspace owner
- one first meeting owner
- participants outside the account system

### Participant

Person who gives feedback after a meeting.

Participants should answer quickly without account creation. Do not design participant flows that require a full LetsGrow login unless the product strategy changes.

### Feedback

A participant response to questions for a specific event/session.

Feedback is valuable because it repeats over time and becomes a trend, not because one response is treated as a standalone survey result.

### Question

A prompt shown to participants after a meeting.

Keep question sets short. The launch product should feel like micro-feedback, not a survey builder.

### Trend

Signal showing whether meeting quality is improving, stable, declining, or has insufficient data.

Trends should be tied to comparable event/session feedback over time.

## Translation Pattern

When moving between code and copy:

- `Activity` -> `recurring meeting`, Danish: `fast møde` or `tilbagevendende møde`
- `Event` -> `session` or `meeting occurrence`, Danish: `mødegang`
- `Manager` -> `meeting owner`, Danish: `mødeansvarlig`
- `Participant` -> `participant`, Danish: `deltager`
- `Feedback` -> `feedback`
- `Questions` -> `questions`, Danish: `spørgsmål`

Prefer natural Danish over literal consistency when writing customer-facing copy.
