# iOS review lens

Read beyond the changed lines: complete functions, callers, sibling implementations, fixtures, and the relevant backend/API boundary. Use the actual task brief to distinguish intentional behavior changes from regressions. A finding needs a trigger and a consequence; identify whether the change introduced it or merely exposed an existing problem.

| Lens | What to trace |
| --- | --- |
| Shared state | Does the change preserve the shared Bootstrap instance? Does an API mutation update the data seen by other screens? Can a stale effect update the wrong account/session after auth or navigation changes? |
| Access and identity | Owner versus anonymous access, not a new participant role. PIN feedback stays account-free. Verify manager-only state requirements and notification/deep-link entry paths. |
| Effects and presentation | Cancellation, overlapping requests, stale response order, in-flight recovery, destination dismissal, and navigation completion. For a timing fix, write the timeline with actual constants and the event that terminates the mechanism. |
| Contracts | Generated → mapper → Domain → cache → feature. Check enum/optional/error cases, request IDs, server semantics, and every caller of renamed public APIs. Generated output must come from canonical generation. |
| UI replacement | Controls can lose focus, keyboard/content type, disabled/loading guards, accessibility, or sheet behavior during cosmetic changes. Inspect DesignSystem callers when a shared token/component changes. |
| Localization and meaning | Typed resources, whole-sentence parameters/plurals, Danish/English layout, decimal/date formatting, and stable IDs instead of translated-string comparisons. Preserve user content and PIN leading zeros. |
| Tests and wiring | Newly added code belongs to a compiled target; tests are in a selected plan and discovered. Check that tests would fail for the concrete regression, rather than only checking a happy path. |
| Resilience | A retry/poll/debounce budget must survive the scenario it is intended to repair. Check cancellation, stop conditions, stale shared data, and terminal failures before accepting a claim that a spinner/lost update is fixed. |

For a broad rename or component migration, enumerate callers and inspect the semantic changes left after removing the mechanical transformation. For a shared DesignSystem change, include relevant consuming screens and visual evidence.

Report the most consequential findings first. Each should state severity, file/line, triggering scenario, defect, and user-visible consequence. Keep uncertainties separate. A clean review can say no findings while still recording which runtime checks were not performed. The review skill is read-only unless the user asks for fixes or external posting.
