# Product feedback and bug reports

The profile's two contact actions open independent in-app forms for owners and
anonymous feedback users. `MoreSection` presents `ProductContact`, which owns
temporary input, validation, submission and receipt state. No meeting, PIN,
participant event or manager statistics are created for product contact.

Product feedback reuses `EmojiRatingView`, the same value/action component used by
meeting feedback. At least a rating or a nonblank comment is required. Bug reports
require a description and allow optional expected behavior and a contact address.
Text fields are limited to 5000 UTF-16 code units, matching backend validation;
contact email is limited to 254. The UI keeps those implementation units out of the
flow and displays the character limit in ordinary language.

## Request and persistence ownership

`ProductContactInput` is a handwritten Domain model. The live API adapter maps it
to the generated `POST /support/submissions` request and validates the returned ID
before confirming success. The separate endpoint uses the Firebase token subject
as the account; the client cannot select a recipient or another account. Existing
anonymous authentication is sufficient, with no owner-account signup requirement.

`SupportSubmissionController` validates the DTO and delegates to the service.
`SupportSubmissionRepo` atomically inserts or reads the UUID through a unique
primary key. Repeating an identical request returns the original receipt/time.
A different account receives a forbidden response; changed content with the same
ID receives a conflict. Input remains visible after a failure. Unchanged retries
reuse the exact request and metadata; editing after a failed attempt creates a
new identity for the changed content. Send and field changes are guarded during a
request, and receipt UI appears only after server confirmation.

Migration `0026-add-support-submissions.yaml` adds a separate `support_submission`
table. It has no relationship to meeting feedback or notification tables and does
not update account bootstrap versions. Its account foreign key uses `ON DELETE
CASCADE`, following existing account-owned data: deleting the account also deletes
the contact text, optional reply address and metadata. No additional automatic
retention period or support-admin portal is introduced here.

Only submission type, rating/text, optional expected behavior/contact email,
server receipt time and **app version, build and OS version** are stored. The
metadata boundary does not include device name/identifier, tokens, logs or meeting
answers. The app version metadata comes from the system adapter, not feature SDK
access.

## Explicit email alternative

“Skriv en mail i stedet” checks mail availability through `SystemClient`.
`MailComposerView` wraps the native composer in an app sheet with plain text and
the configured support address. It never opens an external mail app automatically.
Without configured Mail, an alert offers an explicit copy action for that address.
Closing, sending or cancelling the email composer never creates a database receipt
or calls the product-contact API. Composer completion is not a claim of email
delivery.

## Verification and rollout

`SupportSubmissionTest` uses the applied Liquibase migration and the real repository
on an isolated H2 database. It covers owner/anonymous access, no-token rejection,
validation boundaries, concurrent/identical retries, changed-content conflicts,
cross-account isolation, account cascade and unchanged meeting/notification counts.
These are integration tests of persistence; they do not claim a live PostgreSQL
journey.

`ProductContactTests` covers validation, double taps, in-flight edits, lost-response
retry, cancellation, receipts and both email paths. `ProductContactAdapterTests`
covers generated request fields, allowed metadata, receipt IDs and unchanged cache.
The `product-contact.*` catalog fixtures cover feedback, bug reports and retained
input on error; the receipt remains an interactive preview under the catalog's
success-state policy. Native Mail presentation and physical interaction remain
separate checks recorded in the physical-device verification task while pending.

Regenerate API artifacts with the root script. Deploy the backend and incremental
migration before releasing the iOS form; older servers cannot accept this new
endpoint. Deployment is a separate operation from implementation and commits.
