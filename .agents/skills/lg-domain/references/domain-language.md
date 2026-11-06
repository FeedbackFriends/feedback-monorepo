# Domain Language

Use this when work touches code, API contracts, generated clients, tests, or UX copy that names LetsGrow concepts.

## Naming Rule

Keep code/API names stable. Make customer-facing copy sound like honest feedback after meetings, workshops, talks, training, and similar repeatable formats.

- In code and API contracts, use the canonical model names: `Activity`, `Event`, `Feedback`, `Question`, `ParticipantEvent`, `Workspace`, `Manager`.
- In customer-facing product copy, prefer `meeting`, `workshop`, `talk`, `training`, `format owner`, `session`, and plain Danish equivalents.
- Avoid exposing `Activity` or `Event` as visible product language unless the surrounding screen is developer/admin-facing.
- If a term conflicts with `ios-app/CONTEXT.md`, follow `CONTEXT.md` or ask before changing the domain language.

## Project Terms

### Activity

Canonical code/API term for a manager-owned feedback configuration. Public copy may describe this as a meeting, workshop, talk, training, or format depending on context.

An `Activity` groups:

- title, agenda, location, duration, and run mode
- current feedback questions
- invited participants
- one or more `Event` occurrences
- insights or trend analytics across comparable events

User-facing copy should usually say `meeting`, `workshop`, `talk`, `training`, `format`, or natural Danish equivalents. Avoid using `activity` as a broad customer-facing term.

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

Use this when the user is looking at a single scheduled occurrence of a repeatable format. Do not use `session` as the broad category term. Do not rename API contracts from `Event` to `Session` without a deliberate migration.

### Focus

User-facing name for an `Activity` in parts of the iOS app.

Use current product language for new marketing and product copy unless the existing screen already uses `Focus` consistently.

### Format Owner

Product and marketing term for the person responsible for improving one or more meetings, workshops, talks, training sessions, or similar formats.

In code this may appear as `Manager` or `Owner`. Prefer natural copy such as `den ansvarlige`, `mødeansvarlig`, `formatansvarlig`, or `owner` depending on context. Use `meeting owner` when the context is specifically a meeting.

### Workspace

Commercial/account container for one company or team.

Launch default:

- one workspace per company or team
- one workspace owner
- one first format owner
- participants outside the account system

### Participant

Person who gives feedback after a meeting, workshop, talk, training session, or similar format.

Participants should answer quickly without account creation. Do not design participant flows that require a full LetsGrow login unless the product strategy changes.

### Feedback

A participant response to questions for a specific session.

Feedback is valuable because it shows what actually worked and can reveal patterns over time, not because one response is treated as a standalone survey result.

### Question

A prompt shown to participants after a session.

Keep question sets short. The launch product should feel like micro-feedback, not a survey builder.

### Trend

Signal showing whether feedback patterns are improving, stable, declining, or have insufficient data.

Trends should be tied to comparable event/session feedback over time.

### Generated LetsGrow Email

A deterministic email address generated for a repeatable format. The owner invites this address in their calendar so LetsGrow can create sessions for that format.

Do not design a setup flow that depends on guessing which owner or format a calendar invite belongs to. If the mapping is not deterministic, the flow should require explicit setup or fail.

## Translation Pattern

When moving between code and copy:

- `Activity` -> `meeting`, `workshop`, `talk`, `training`, or `format`, Danish: `møde`, `workshop`, `oplæg`, `træning`, or natural format-specific wording
- `Event` -> `session` or occurrence, Danish: `mødegang` when specifically a meeting
- `Manager` -> `format owner`, Danish: `mødeansvarlig`, `formatansvarlig`, `ansvarlig`, or natural role-specific wording
- `Participant` -> `participant`, Danish: `deltager`
- `Feedback` -> `feedback`
- `Questions` -> `questions`, Danish: `spørgsmål`

Prefer natural Danish over literal consistency when writing customer-facing copy.
