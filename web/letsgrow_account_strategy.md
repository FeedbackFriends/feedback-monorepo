# LetsGrow Account, Workspace, and Onboarding Strategy

## Purpose

This document defines how accounts, workspaces, roles, signup, and onboarding should work for LetsGrow.

It is separate from pricing because the account model should be stable even while pricing evolves.

The goal is to keep the product easy to adopt in launch phase while still creating the right foundation for paid expansion later.

It should also stay aligned with the landing page brief: low friction, recurring-meeting focused, and compatible with an early-access CTA while the go-to-market motion is still being refined.

---

## Core Recommendation

LetsGrow should use a `workspace-based` account model.

That means:

- `one company or team = one workspace`
- `one workspace has one primary owner`
- `one workspace can later contain multiple meeting owners`
- `participants do not need accounts`

This gives LetsGrow a clean path from one early pilot user to a paying workspace with multiple team leads.

---

## Why This Model Fits LetsGrow

LetsGrow is not a tool where every employee needs a login.

The value starts with the person who owns the recurring meeting.

That means the product should be built around:

- one responsible buyer
- one clear workspace
- one or more meeting owners
- many account-free participants

If every participant had to create an account, the product would become heavier than the promise on the landing page.

---

## Recommended Roles

### 1. Workspace Owner

This is the main account in the workspace.

In pilot phase, this person will usually also be the first meeting owner.

This role should be able to:

- accept the initial invite
- create or access the workspace
- become the main contact for the company
- own billing once payment starts
- invite additional meeting owners later
- view overall workspace usage

### 2. Meeting Owner

This is a user who runs one or more recurring meetings.

This role should be able to:

- connect their workflow if needed
- configure recurring meeting feedback
- view feedback and trends for their meetings

In the first version, the workspace owner and meeting owner can be the same person.

### 3. Participant

Participants should not need a real LetsGrow account.

Participants should be able to:

- receive a feedback request
- answer 2-3 short questions
- complete feedback without password creation

---

## Recommended Workspace Rules

### Launch Rule

At launch, every customer should start with:

- one workspace
- one workspace owner
- one first meeting owner

In many cases, those will be the same person.

### Expansion Rule

Later, the workspace owner should be able to:

- add another meeting owner
- remove a meeting owner
- reassign a meeting to another owner
- see how many active meeting owners are in the workspace

This is enough for the next stage. Do not build advanced admin hierarchies yet.

---

## Recommended Account Linking Strategy

Yes, accounts should be linked together inside the same workspace.

The payer should not pay for separate disconnected individual accounts.

The correct model is:

- billing belongs to the workspace
- users belong to the workspace
- meeting owners are added inside the workspace
- participants stay outside the account system

This means the payer can add meeting owners later without changing the underlying model.

---

## Pilot Phase Setup

If LetsGrow is running an early-access or design-partner phase, the account flow can be partly manual.

That should be treated as the public operating model for now, with a lightweight interest step rather than immediate self-serve account creation.

Recommended setup for early-access teams:

1. A team is identified through the landing page early-access form or founder outreach.
2. You qualify whether they match the ideal pilot profile.
3. You manually create one workspace.
4. You invite one primary contact as `workspace owner`.
5. That person becomes the first `meeting owner`.
6. If needed, you manually add one more meeting owner later.
7. Participants never create accounts.

This keeps pilot support high-touch without turning the public onboarding story into a heavy sales process.

---

## Recommended Signup Flow

### Current Launch Flow

To stay aligned with the landing page brief, the public flow should support a low-friction early-access start.

The practical launch flow should be:

1. User lands on the site.
2. User clicks the primary `Få tidlig adgang` CTA.
3. User is sent to a Typeform.
4. Typeform captures:
   - work email
   - company name
   - role
   - number of recurring meetings
   - current meeting pain
5. LetsGrow qualifies the lead.
6. LetsGrow creates the workspace manually.
7. Primary contact receives an invite.
8. Contact verifies email and enters the product.
9. First recurring meeting is configured by inviting `feedback@letsgrow.dk`.

This keeps the CTA simple while preserving control over onboarding quality.

### Later Self-Serve Expansion

Once onboarding is stable, expand to:

1. Work email signup
2. Email verification
3. Confirm or rename workspace
4. Add first recurring meeting
5. Launch first feedback loop
6. See first results after initial responses
7. Invite another meeting owner if needed

---

## Recommended Product Logic

The product should treat these as different milestones:

- `account created`
- `workspace created`
- `first recurring meeting configured`
- `first participant responses received`
- `second meeting cycle completed`

The key activation event is not account creation.

The key activation event is:

`a real recurring meeting has been set up and has received real feedback`

That is the event the onboarding should optimize for.

---

## Recommended Billing Relationship

The account model should support billing, even if billing is manual during pilot.

That means:

- one workspace owner becomes billing owner later
- one workspace subscription covers the workspace
- one workspace can include one or more paid meeting owners

So yes: the payer should be able to add meeting owners.

That should be part of the strategy from the start, even if the first implementation is manual.

---

## What To Avoid

Avoid these account decisions early:

- requiring every participant to create a login
- building complex admin permissions too early
- treating each meeting owner as a separate isolated customer
- letting billing live outside the workspace model
- optimizing for enterprise account structures before expansion is proven

---

## Recommended Default Strategy Right Now

If a decision had to be made today, the recommended account strategy would be:

- use one workspace per company or team
- create one workspace owner as the main account
- let that person also be the first meeting owner
- keep participants account-free
- use a `Få tidlig adgang` Typeform and manual workspace setup as the current public flow
- move to self-serve workspace creation only when onboarding is stable
- later let the workspace owner add more meeting owners

This is the simplest model that matches LetsGrow's low-friction promise and still supports commercial expansion.
