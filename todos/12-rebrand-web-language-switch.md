---
status: draft
areas: [web]
created: 2026-11-06
updated: 2026-11-06
---

# Rebrand 12 — Danish and English language switch on web (low priority)

**Priority: low.** The web leader UI stays Danish-only for now (user, 2026-11-06).

## Problem and outcome

The iOS app supports Danish and English. The web app has hardcoded Danish strings and no i18n setup. The only exception is the error copy in `web/src/lib/api/client.ts`, which already has Danish and English versions.

Outcome: a leader can switch the web app between Danish and English. Danish stays the default, and the choice is remembered.

## Rebrand series

Best done after **06** (leader dashboard) and **08** (marketing copy), so the strings are stable. The coming-soon landing page (01) is implemented; product direction is documented in [the rebrand strategy](../docs/product/lets-grow-strategi-teamtrivsel.md).

## Scope

- In scope:
  - **i18n setup.** Add an i18n setup to the Next.js app, and move hardcoded strings into Danish and English catalogs.
  - **Language switch.** A switch in the dashboard and the marketing site. Remember the choice, and set `<html lang>` to match.
  - **API language.** Send the chosen language as `Accept-Language`, which `requestAPI` already does, so backend error copy matches.
- Out of scope:
  - Languages other than Danish and English.
  - Translating the privacy policy. Legal text has its own review.

## Context

- Current behavior: Danish strings are hardcoded in `web/src/components/**` and `web/src/app/**`. The root `<html lang="en">` is wrong, and task 01 fixes it to `da`.
- Reading path:
  - `web/AGENTS.md`
  - `web/docs/agents/architecture.md`
  - `ios-app/Docs/localization.md` for the iOS conventions to align terminology

## Decisions and open questions

- Confirmed: low priority, and Danish remains the default.
- Assumptions: None.
- Unresolved:
  - Choose the i18n library, for example next-intl, or a minimal in-house dictionary.
  - Decide whether the language lives in the URL (`/en/...`) or in a cookie or preference.
- Execution constraints: none until the task is prioritized.

## Acceptance criteria

- [ ] AC-1: All web UI strings are available in Danish and English, with no hardcoded user-facing strings left.
- [ ] AC-2: A leader switches language, the whole UI updates, and the choice survives a reload.
- [ ] AC-3: `<html lang>` and `Accept-Language` match the chosen language.

## Implementation plan

- [ ] Refine when prioritized.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1 | Repository | Lint or search for hardcoded strings | None found |
| AC-2 | Playwright | Switch to English and reload | The UI is in English |
| AC-3 | Playwright | Inspect the rendered HTML and the API request headers | `en` in both |

## Human review

Not implemented yet.

## Handoff

- Completed: None.
- Verification results: Not run.
- Blockers: None. Low priority.
- Next action: None until prioritized. Then run `$lg-refine todos/12-rebrand-web-language-switch.md`.
