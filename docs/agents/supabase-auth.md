# Supabase Auth setup and cutover

LetsGrow uses managed Supabase Auth for email codes, Google, Apple and anonymous iOS identities. Product data remains in the existing Postgres database; Kotlin checks current ownership and memberships on every team request. No Supabase Data API or RLS migration is involved.

## Project setup

Use a dedicated nonproduction Supabase project for local fixture tools and a separate production project. In each project:

- Enable email signup and confirmation, anonymous sign-ins, Google and Apple. Keep automatic same-verified-email linking enabled. Do not enable domain-based access, passwords in the product UI, or custom role claims.
- Use an asymmetric ES256 or RS256 JWT signing key. Kotlin validates its project issuer, signature, expiry, `authenticated` audience and UUID subject. Legacy Firebase tokens and Supabase service-role tokens are not user sessions.
- Configure custom SMTP with an authenticated sender domain (SPF/DKIM/DMARC). Set the **Magic Link** and signup-confirmation email templates to display `{{ .Token }}` in Danish; the app accepts an email code rather than asking people to open a magic link. Set OTP expiry to 600 seconds, resend interval to 60 seconds, and keep provider rate limits enabled. Do not disable email confirmation.
- Set Site URL to `https://app.letsgrow.dk` and allow redirects to `https://app.letsgrow.dk/login` and `https://app.letsgrow.dk/leader-invite/*`. Add the equivalent localhost routes for the separate development project. The web SDK uses PKCE and restores the same route after Google login.
- Configure Google's web callback as `https://PROJECT.supabase.co/auth/v1/callback`. Add the native iOS OAuth client ID to Supabase's permitted Google client IDs and configure its reversed-client-ID URL scheme in the iOS project. Set `GOOGLE_CLIENT_ID` to that native client ID. Configure Apple with the existing app bundle identifier, native entitlement, and provider credentials. Rotate the Apple OAuth secret according to its provider expiry.

Environment values are described in [`.env.example`](../../.env.example). For web outside Compose, set both `NEXT_PUBLIC_SUPABASE_*` values. Compose maps the backend public project values into the web service at runtime. Publishable keys are intentionally public; Supabase secret keys and SMTP credentials are server-only.

For iOS, set `SUPABASE_URL = https:/$()/PROJECT.supabase.co`, `SUPABASE_PUBLISHABLE_KEY`, and `GOOGLE_CLIENT_ID` in ignored `App/Config/secrets.xcconfig`. The URL syntax avoids xcconfig's `//` comment parsing. Native Auth uses the SDK's Keychain storage under a project-specific key, separate from Firebase sessions. Firebase configuration remains necessary for Messaging/Crashlytics.

## Fresh start and release sequence

The user explicitly chose **no migration**. Supabase identities use internal IDs `supabase:<subject>`. Existing Firebase accounts and content stay in place; ownership, team assignments, employee memberships and prior feedback identities are not recovered or merged by email. Still-valid personal leader and legacy event invitations remain independent grants checked through their existing flows. The provider-scoped email constraint permits the same email to create a new account without deleting old rows. Only the Supabase generation receives incoming calendar-email lookups after cutover.

1. Configure the managed project, mail delivery, signing keys, provider callbacks and environment before release. Do not reset product or provider databases.
2. Build and verify the API, scheduler, web and iOS release from the same contract. Apply the additive `0029` Liquibase change through the normal backend startup path.
3. Cut over API, scheduler and web together. Existing installed Firebase-auth clients cannot use the new API and must update; no mixed-provider compatibility window is offered. All users sign in again. Owners create new organizations; employees rejoin and need approval. Distribute the updated iOS client at cutover.
4. Human acceptance: actual code delivery/expiry/resend; Google and Apple callbacks; same-email Google/code convergence; owner name/organization/team; email invitation and wrong-email rejection; pending invitation after direct login; anonymous employee join/approve/reject/remove/relaunch; legacy event-code entry.

Rollback restores the previous coordinated API/scheduler/web/native release and Firebase environment. Leave Supabase accounts and the expanded database schema intact. Do not drop `auth_provider` or restore global email uniqueness while duplicate emails exist across generations; that requires a separate data decision. Fresh Supabase content remains isolated until the Supabase release resumes. No deployment, provider purchase, remote configuration mutation or database cleanup is performed by implementing this task.

## Delivery and local fixtures

The API sends a plain-text transactional leader invitation over SMTP after the invitation transaction commits. A 200 response means the SMTP transport accepted the message, not confirmed inbox delivery. A transport failure returns 503; the UI retains the same submission ID so retry sends the same still-valid invitation. SMTP may accept a message before a connection fails, so a retry can produce a duplicate email; it cannot create duplicate authority. Revoked, expired and accepted invitations are not resent. Existing copy-link controls remain a recovery option.

Test admin endpoints remain disabled in production. When explicitly enabled against the nonproduction project, manager fixture login uses Supabase's admin-generated magic-link hash exchanged directly for a session, without sending email. Anonymous fixture seeds create a new anonymous identity. `scripts/e2e-admin` emits a JSON access/refresh pair consumed by the native debug-only session restore; it no longer emits a Firebase custom token. Do not put pairs into tracked files or shared schemes. Resetting the local product database does not delete Supabase identities.

References: [email OTP](https://supabase.com/docs/guides/auth/auth-email-passwordless), [identity linking](https://supabase.com/docs/guides/auth/auth-identity-linking), [anonymous users](https://supabase.com/docs/guides/auth/auth-anonymous), [admin link generation](https://supabase.com/docs/reference/javascript/auth-admin-generatelink).
