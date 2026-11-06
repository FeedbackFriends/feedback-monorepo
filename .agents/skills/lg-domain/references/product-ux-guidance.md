# Product And UX Guidance

Use this for product shape, roles, onboarding, activation, and UX decisions.

## Product Loop

Make this loop obvious:

1. The owner plans the meeting, workshop, talk, training session, or similar format as usual in their calendar.
2. The owner adds the generated LetsGrow email for that format as one extra participant.
3. LetsGrow maps the calendar invite to that format and creates a session for it.
4. Participants answer a few relevant questions directly from mobile after the session.
5. The owner sees clear insights, patterns, and development over time.
6. The owner adjusts and gets better at what actually works.

The most important product pattern is repeatability for the owner. The same participants do not need to return. An AI workshop, coding workshop, onboarding session, or talk can be a one-off event for participants but still be a repeatable format for the owner.

## Primary User

Design first for the format owner:

- short on time
- responsible for making repeatable meetings, workshops, talks, training, or similar formats useful
- wants honest feedback without a heavy process
- needs clear signals and next actions

Participants, HR admins, executives, and analysts matter later. They are not the launch wedge.

## Roles And Account Model

- Workspace owner: owns workspace, later billing, main company contact, can invite more owners, and can view overall workspace usage.
- Format owner: runs one or more meetings, workshops, talks, training sessions, or similar formats, configures feedback, views responses, and acts on insights.
- Participant: receives feedback request and answers 2-3 short questions without password creation or a real LetsGrow account.

Launch default:

- one workspace per company or team
- one workspace owner
- one first format owner, often the same person
- participants outside the account system

Avoid advanced admin hierarchy until expansion is proven.

Accounts should be linked inside the same workspace. The payer should not pay for separate disconnected individual accounts. Billing belongs to the workspace, users belong to the workspace, format owners are added inside the workspace, and participants stay outside the account system.

## Onboarding

App-first onboarding flow:

1. Danish website.
2. App download or account start, depending on the current surface.
3. User installs the app.
4. User plans a meeting, workshop, talk, training session, or similar format as usual.
5. User invites the generated LetsGrow email for that format.
6. Participants answer from mobile after the session.
7. User sees what actually worked and follows development over time.

Later self-serve flow:

1. Work email signup.
2. Email verification.
3. Confirm workspace.
4. Add first format.
5. Launch first feedback loop.
6. See first results.
7. Invite another owner if needed.

## Activation

Do not optimize for account creation.

Activation is:

`one real format has been configured and has received real participant feedback`.

Useful milestones:

- landing page visit
- app download or install
- workspace created
- first format configured
- first participant responses received
- repeated feedback or pattern identified
- paid conversion

## Prioritize

- format setup
- calendar-invite based setup with a deterministic generated email per format
- automatic post-meeting feedback
- short mobile feedback
- insights into what worked and what did not
- patterns and development over time
- simple next-action prompts
- low-friction participant flows
- workspace-level billing foundation even if billing is manual in pilot

## Defer

- enterprise permissions
- company-wide benchmarking
- broad survey customization
- complex analytics
- full self-serve checkout before onboarding is proven
- HR program workflows
- performance review or personal-development framing

## Expansion Rules

Later, workspace owners should be able to add owners, remove owners, reassign formats to another owner, and see how many active owners are in the workspace. That is enough for the next stage; do not build enterprise account structures before expansion is proven.

## UX Voice

Customer-facing UX should be plain Danish, practical, and calm.

Good directions:

- `Tilføj møde`
- `Se udvikling`
- `Første feedback modtaget`
- `Mødekvaliteten stiger`
- `Invitér LetsGrow-mailen`

## Email-Based Setup

Email-based session creation is strategically important because it keeps the owner in their existing calendar workflow.

The backend generates an email address for each format. The owner adds that generated email as a calendar participant when planning a concrete meeting, workshop, talk, training session, or similar format. Invites sent to that generated address create sessions for the specific format.

The generated address can be short and human-friendly, for example a four-digit or short-code local part at the LetsGrow domain such as `1234@letsgrow.dk`, as long as it is unique enough for deterministic routing.

The setup rule is deterministic: if the system cannot confidently map a calendar invite to one owner and one format/session, it should throw an error or require explicit setup instead of guessing.

Avoid hype, long in-app education, surveillance language, and `AI-powered` as the core value.
