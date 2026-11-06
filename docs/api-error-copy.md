# API error copy and language

The backend owns deliberate business-error wording in
`backend/apps/api/src/main/resources/errors_da.properties` and `errors_en.properties`.
`LocalizedApiErrors` selects copy by domain code or failure category, never by
exception text. `ControllerAdvisor` and the Spring Security 401/403 handlers use
the same envelope. Authentication and input validation have explicit 401/400
classification; existing domain statuses and other exception classification remain
unchanged, including guarded test-admin endpoints.

Clients send their selected **app language** in `Accept-Language`. The backend
matches Danish/English regional tags, orders preferences by quality, excludes
zero-quality preferences, and defaults to Danish when no supported preference is
usable. Invalid headers also default to Danish. Responses report `Content-Language`
and vary by `Accept-Language`.

`ApiError.userTitle` and `userMessage` are optional safe display strings. The
existing timestamp, diagnostic message, domain code, exception type and path remain
for compatibility. Diagnostic `message` must never be used as customer copy.
Behavior uses codes/status, never translated sentences. API errors and generated
clients remain owned by the backend OpenAPI source; regenerate with the root
`scripts/generate-api-artifacts.sh` command.

## Client responsibilities

iOS `APIErrorMiddleware` sends `L10n.locale.identifier` and reads a deliberately
small, tolerant error envelope before generated response accessors run. Its raw
domain code is a string so future codes cannot discard usable safe copy. Known
codes still map to Domain's typed enum. Generated DTO mappers retain the optional
display fields too. `Error.localized` uses both nonblank display strings together,
otherwise the existing local domain/status mapping and generic fallback. Features
continue rendering `PresentableError` through existing text/alert components.

Web `requestAPI` requires an explicit app-language argument and keeps status/raw
code in `APIHTTPError`. `apiErrorPresentation` prefers complete backend copy and
otherwise supplies local recovery text. Render its returned strings as ordinary
text; never use HTML rendering. Cancellation remains cancellation; HTML/malformed
responses, SDK diagnostics and arbitrary exception descriptions are not display
copy. Authentication headers and successful responses pass through unchanged.

The current web app uses Firebase auth and static dashboard shells; it has no
backend API screen to migrate. The request boundary is ready for those future
consumers. This change does not add a language picker or dashboard data model.

Offline, timeout, SDK authentication, permissions and local state remain client
responsibilities. Keep compatibility fallbacks for older servers and incomplete
payloads; the backend catalogs are the source for new business wording.

## Compatibility and rollout

Deploy the compatible backend before releasing clients that consume its copy.
Old clients ignore the added fields. New clients still work with old servers
through their local fallback. No deployment is implied by generating the contract
or committing this implementation.

## Verification reading path

- `backend/apps/api/src/test/kotlin/dk/example/feedback/config/LocalizedApiErrorsTest.kt`
  checks language negotiation, all domain translations, safe fields, MVC validation
  and the legacy diagnostic boundary.
- `backend/apps/api/src/test/kotlin/dk/example/feedback/tests/AdminSecurityAccessTest.kt`
  checks localized filter-level 401/403 without weakening admin authorization.
- `ios-app/Modules/Tests/AppTests/UnitTests/ErrorAdapterTests.swift` and
  `PresentableErrorTests.swift` cover known/unknown codes, selected language,
  incomplete copy, legacy payloads, malformed bodies and cancellation/SDK fallbacks.
- `web/tests/api-client.spec.ts` checks the same request/error boundary with injected
  fetch responses in both languages. These tests do not claim a live backend web
  journey; no such consumer exists yet.
