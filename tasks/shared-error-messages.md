---
status: in-progress
areas: [backend, ios, web]
created: 2026-11-06
updated: 2026-11-06
---

# Shared error messages across clients

## Problem and outcome

Centralize deliberate business-error copy and Danish/English translations in the backend while preserving client-owned transport/SDK error handling and existing localization infrastructure.

## Scope

- In scope: compatible optional API error copy, language negotiation, generated clients, iOS/web adapters, tests, and ownership documentation.
- Out of scope: an Android implementation before that app exists here, a shared runtime library, or a full RFC 9457 response-format migration.

## Context

### Shared error messages across iOS, Android, and web

Status: Planned follow-up after merging iOS localization PR #101. This document proposes the implementation; it does not change the current API or app behavior.

### Goal and ownership

Maintain business-error wording and Danish/English translations once in the backend, so every client can reuse them. Preserve the localization infrastructure introduced by the iOS PR.

| Responsibility | Owner |
| --- | --- |
| Business rules and error codes, e.g. invalid PIN or duplicate feedback | Backend |
| User-facing title and message for API failures | Backend translation catalog |
| Offline, timeout, SDK authentication, permission, and local-state failures | Client localization resources |
| Presentation, buttons, retry, navigation, and field highlighting | Client |
| API response types | Generated from the backend OpenAPI contract |

The backend chooses words for failures it handles. Clients choose how to present them and handle failures where no usable API response arrives.

### Proposed contract

Clients send their selected app language using `Accept-Language`, rather than assuming it matches the device language. The backend supports Danish and English, matches regional preferences such as `en-GB`, respects preference ordering, and defaults to Danish when no supported preference is supplied.

Extend the existing error response with optional `userTitle` and `userMessage` fields. Retain `domainCode`, HTTP status, and existing fields during migration. For example, an invalid PIN response includes:

```http
Content-Language: da
```

```json
{
  "domainCode": "PINCODE_NOT_FOUND",
  "userTitle": "Ugyldig PIN-kode",
  "userMessage": "Vi kunne ikke finde en session med den PIN-kode."
}
```

This is an illustrative excerpt, not a replacement response schema. The backend returns deliberate, user-safe copy for recognized domain errors and generic copy for unexpected failures. Never construct these fields from exception messages. The current `message` field contains diagnostic exception text and must not become display text.

Behavior depends on codes/status, never translated sentences. New clients must tolerate unknown domain codes without losing otherwise usable user-facing text. Language-dependent cacheable responses must vary by `Accept-Language`.

### Runtime flow

`Failure → backend classification → backend translation → generated API client → client error adapter → screen`

When both user-facing fields are nonempty, display them as plain text. The adapter preserves the code/status for behavior. Otherwise use the existing local error mapping, then a generic localized fallback. HTML proxy responses, malformed bodies, and SDK diagnostics never become visible copy. Preserve existing cancellation behavior.

Keep iOS error normalization: unwrapping generated client errors and classifying SDK failures is still necessary. Change the presentation mapping so backend copy takes precedence for API failures.

### Why this approach

Backend ownership avoids three business-error translation catalogs and allows wording fixes without mobile releases. The cost is that backend changes affect every client immediately; copy must avoid platform-specific instructions.

A shared catalog generating native resources is an alternative: it works offline but requires a translation generation pipeline and mobile releases for copy updates. Defer that pipeline for client-only messages until the cross-platform vocabulary is clearer. A shared runtime library adds integration work and still cannot remove platform-specific error handling.

### Delivery after localization merges

1. Add backend translations, language negotiation, and optional user-facing fields. Cover domain errors and API authentication/authorization, validation, and unexpected-error paths. Audit handlers outside the main exception handler for consistent responses.
2. Regenerate the contract and clients with `./scripts/generate-api-artifacts.sh`. Generate Android types from the same contract when Android is introduced; never hand-edit generated artifacts.
3. Deploy the compatible backend first. Migrate iOS and web to send language preferences and consume the new fields. Android follows the same contract. Keep local mappings for older servers and unusable responses.
4. Document the contract and translation ownership. Retain fallback coverage; remove redundant business-specific client translations only when compatibility requirements allow it.

### Acceptance criteria

- Danish, English, regional, missing, and unsupported language preferences resolve predictably; `Content-Language` reports the selected language.
- All existing domain errors have both translations. Unexpected failures return safe generic copy.
- iOS and web display the same backend copy for the same failure and language; codes still drive special behavior.
- Old clients work with the new backend. New clients handle absent fields and unknown codes safely.
- Offline, timeout, malformed-response, SDK, and cancellation cases retain appropriate client behavior.
- Backend tests, generated-contract checks, and focused client integration tests pass. No exception details appear in visible messages.

API shape ownership: [API contract guidance](../docs/agents/api-contract.md). Language negotiation for human-readable API errors is supported by [RFC 9457](https://www.rfc-editor.org/rfc/rfc9457.html); adopting its full response format is outside this follow-up.

## Decisions and open questions

- Confirmed: the preserved proposal is a planned follow-up after the iOS localization work; it has not changed the current API.
- Assumptions: backend-first compatible rollout; clients retain fallbacks for unusable/missing fields.
- Current-code audit 2026-11-06: iOS Localization is present and shipping; ControllerAdvisor handles MVC errors, while Spring Security filter errors currently bypass it. Both paths will share safe copy and language headers. iOS APIErrorMiddleware currently loses unknown domain codes during generated enum decoding, so its error envelope must tolerate unknown strings.
- Web currently has Firebase auth and static dashboard shells but no backend API transport/callers. Implement a small typed API request/error boundary with required explicit app-language input, verify it against mocked responses, and document that there is no existing backend-consuming screen to migrate. Do not invent a dashboard data flow.
- Language resolution honors preference order/quality, supports regional da/en tags, excludes q=0, and defaults to Danish for missing/unsupported/malformed preferences.
- Unresolved: None.
- Execution constraints: no deployment or production mutations authorized by this plan; follow owning app/API guidance.

## Acceptance criteria

- [x] AC-1: Danish/English/regional/missing/unsupported preferences select safe copy with correct Content-Language.
- [x] AC-2: Optional userTitle/userMessage preserve existing clients and keep exception details out of customer-visible copy.
- [ ] AC-3: iOS/web display backend copy while retaining code-driven behavior and safe local fallback/cancellation handling.
- [x] AC-4: Relevant backend, generation, and client integration checks pass.

## Implementation plan

### Phase 1 — Backend error classification and translations

Outcome: safe optional copy and predictable language negotiation. Dependencies: audit existing handlers and localization readiness.

- [x] Implement translations/negotiation and optional response fields across domain/auth/validation/unexpected-error paths.
- [x] Verify safe text, language cases, and backward compatibility with backend tests.

### Phase 2 — Contract and generated clients

Outcome: producer/consumer contract is synchronized. Depends on phase 1.

- [x] Run `./scripts/generate-api-artifacts.sh` and inspect generated differences.
- [x] Verify generated fields and existing-client compatibility.

### Phase 3 — Client integration

Outcome: iOS/web send language preferences and consume safe copy. Depends on phase 2 and compatible backend availability.

- [x] Update handwritten adapters and request language configuration; preserve transport/SDK/local fallbacks and cancellation.
- [x] Verify recognized/unknown codes, missing fields, malformed responses, and localized display.

### Phase 4 — Ownership documentation and regression verification

Outcome: one documented ownership/compatibility model. Depends on phase 3.

- [x] Document contract/translation responsibilities and retain fallback coverage.
- [ ] Verify cross-platform copy and regressions; remove redundant mappings only when compatibility permits.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1, AC-2 | Backend handler/language fixtures | Relevant API tests and old-client payload checks | Safe localized optional fields with stable codes/status |
| AC-3 | Injected client failure fixtures and compatible local API | Adapter tests and relevant iOS/web journeys | Backend copy wins only when usable; local failures/cancellation remain correct |
| AC-4 | All affected sources | Root generation, relevant Gradle/client checks | Generated artifacts and consumers agree |

## Human review

Business copy now lives in two backend ResourceBundle catalogs. LocalizedApiErrors chooses safe copy independently of exception diagnostics; ControllerAdvisor and Spring Security share the envelope and language/Vary headers. Existing domain codes/statuses and legacy diagnostic fields remain compatible; validation/auth paths now explicitly classify 400/401. Existing guarded admin-reset exception classification remains unchanged, verified by the full API suite.

iOS sends L10n’s selected locale through APIErrorMiddleware and decodes only a tolerant handwritten error envelope before generated closed enums could reject future codes. Raw code/status remain available; known codes keep typed Domain mapping. Error.localized uses only complete nonblank safe pairs, otherwise existing local mappings. This small envelope is an implementation tradeoff for forward compatibility, not a replacement for generated success transport. Both generated DTO mappers preserve optional fields too.

Web had no backend callers; the new typed request/error boundary requires explicit app language and is verified with injected fetch, without inventing dashboard behavior. Plain-text rendering and local/cancellation ownership are documented in `docs/api-error-copy.md`. No runtime localization library, app language picker or backend deploy added.

Reading path: `backend/apps/api/src/main/kotlin/dk/example/feedback/config/LocalizedApiErrors.kt` → `controller/ControllerAdvisor.kt` and `config/SecurityConfig.kt` → `ios-app/Modules/Sources/Adapters/APIClient/APIErrorMiddleware.swift` → `ios-app/Modules/Sources/Domain/Error+Extension.swift` → `web/src/lib/api/client.ts` → `docs/api-error-copy.md` and tests linked there. Existing layer boundaries retained; no persistence changes.

## Handoff

- Completed: Backend safe optional copy, Danish/English negotiation across domain/MVC/auth/security, regenerated contract/Swift/TypeScript, iOS language+safe-copy integration with unknown-code retention, web request/error boundary, compatibility and rollout documentation. Local fallbacks retained for older servers. No deployment, reset or product-data mutations.
- Verification results: 2026-11-06: `./gradlew :api:test` from backend/: 33 passed, 0 failed/skipped. Initial narrow suite: 7 passed. Full suite initially exposed an unintended change to guarded reset HTTP classification; narrowed framework mapping and reran all 33 successfully. Existing Gradle 8.5 deprecation/JVM/MockBean/runtime bean warnings remain; no new main-source compiler warnings. Root artifact generator passed, with existing unhandled OpenAPI resource warnings; generated optional fields/400/401 responses inspected. Native iOS Feedback Localhost / LetsGrow Manager iOS 27.2 buildForTesting passed; UnitTests discovery 222 enabled from both targets, RunAllTests 245 passed (parameterized expansion), 0 failed/skipped. SwiftLint --base HEAD: 0 violations across 12 files. Web on Node 20.19.0: npm lint passed; seven injected-fetch Playwright checks passed; npm build passed (installed Next 16.1.6). No new UI source changed or new screenshot capture claimed for this task; prior 66-state catalog is unrelated visual evidence. Incidental generator Package.resolved and build next-env.d.ts changes restored, not included.
- Blockers: Live iOS error presentation on a compatible localhost backend remains blocked by native Xcode DeviceInteraction-session state (see `tasks/ios-text-input-full-surface-focus.md`). Web has no backend-consuming screen; only its transport boundary can be exercised. No production rollout is authorized or performed.
- Next action: Restore native session, run current client against compatible localhost backend and inspect invalid-PIN/local fallback in Danish/English. Complete AC-3/live verification, then remove this task. Read `docs/api-error-copy.md` before any separately authorized backend-first rollout.
