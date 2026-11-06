---
status: done
areas: [ios]
created: 2026-10-27
updated: 2026-11-06
---

# Native Xcode screen catalog — historical delivery

## Problem and outcome

Preserve the delivered October screen-catalog work and its recorded capture observations. Current screenshot implementation and policy are owned by the current screenshot documentation.

## Scope

- In scope: historical capture/catalog delivery record.
- Out of scope: claiming a new capture or retaining the old RenderPreview method as current execution policy.

## Context

### Native Xcode screen catalog

Date: 27 October 2026
Status: 145 named screen and state previews captured.

The earlier five-preview proof of concept established Xcode 27's native `RenderPreview` as a reliable source of real SwiftUI snapshots. An unchanged warm five-image batch took 1.80 seconds; a same-environment concurrency check measured 1.69 seconds sequentially and 1.66 seconds concurrently. The difference was too small to justify concurrent capture. These are cached observations, not clean-build timings.

The catalog now covers app startup and sign-in; manager, participant, and anonymous tabs; profile and settings; activity lists, overviews, creation and editing; session creation, details and invitation; participant sessions; notifications; the question editor; and every feedback answer type and result. It includes representative empty, populated, saving, offline, error, and success states, with longer content snapshots where the initial phone viewport would omit important content.

Every preview uses fixed fixtures and an inert reducer, so capture does not require login or call the backend. Xcode MCP renders previews; the Python publisher validates the full batch and copies the original PNG bytes to `Docs/screenshots/catalog/`. The output folder contains the image files only. The current workflow and its coverage limits are in [the screenshot instructions](../ios-app/Docs/screenshots/README.md).

Native modal framing and system-owned alerts are not captured. Foundation date strings follow the preview host locale, even though SwiftUI's locale and time zone are fixed. The tall full-content images use a different layout from phone captures.

## Decisions and open questions

- Confirmed: original record reports 145 named screen/state previews captured.
- Assumptions: done reflects that historical delivery, not the current catalog size or a new acceptance run.
- Unresolved: None for this completed record.
- Execution constraints: new screenshot work uses the current [screenshot instructions](../ios-app/Docs/screenshots/README.md) and native harness.

## Acceptance criteria

- [x] AC-1: Original delivery record documents capture coverage and limitations.

## Implementation plan

- [x] Preserve the historical delivered catalog record and observations.
- [x] Point future work at maintained screenshot guidance.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1 | Original delivery document | Preserve its coverage/limitations | Historical evidence remains available without implying a fresh run |

## Human review

Historical delivery record; no new implementation or architectural decision is claimed by migration. Current screenshot architecture is documented in the [screenshot guide](../ios-app/Docs/screenshots/README.md). No fresh capture was performed.

## Handoff

- Completed: original catalog delivery recorded; migrated to the common task format.
- Verification results: original 145-preview observations retained; no new screenshot capture performed.
- Blockers: None for the historical record.
- Next action: none; create a new prefixed task for future screenshot changes.
