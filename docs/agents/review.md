# Shared review lens

The human's review focuses on architectural judgement: ownership, boundaries, dependencies, state/data flow, contract changes, and tradeoffs. Use the implementation conversation's handoff, using the [human review guidance](../../.agents/skills/lg-implement/SKILL.md#prepare-the-human-review) as a reading guide and verify its claims against source. Existing coding standards are the default, and the implementing/reviewing agent remains responsible for convention and correctness checks.

Review the actual task's intended behavior against complete changed functions, callers, tests, and both sides of contracts. A useful finding states a trigger, failure path, and observable consequence, and distinguishes an introduced issue from a pre-existing one.

| Lens | What to trace |
| --- | --- |
| Ownership and source of truth | Duplicate writable state, service/adapter boundaries, persistence consistency, and callers that still observe old data |
| Access and identity | Owner/anonymous authorization, account changes during requests, scoped activity/session access, and private feedback exposure |
| API compatibility | Backend DTOs → generated contract/clients → mappers → consumers; optional/unknown/error cases and deployment order |
| Concurrency and failure | Cancellation, stale results, duplicate requests/jobs, retries/timeouts, transaction boundaries, idempotency, and terminal recovery |
| Persistence | Incremental migrations, old/new data compatibility, DAO predicates, transaction semantics, and deletion side effects |
| Client behavior | Navigation/presentation, auth, loading/empty/error state, localization, user-content preservation, and accessibility affected by control changes |
| Verification and wiring | Code is in a compiled target/module; tests are discovered and would fail for the regression; generated artifacts come from source |

For timing/retry fixes, write the event timeline with real constants and stop conditions. For broad renames or component migrations, inspect the semantic changes remaining after the mechanical transformation and enumerate affected callers. Use [the iOS lens](../../ios-app/Docs/agents/review.md) for TCA, Bootstrap, native UI, and screenshot-specific concerns.

Rank concrete defects by impact. Keep uncertainty separate and avoid stylistic padding. Report which checks were actually run; no findings does not imply runtime verification. A review is read-only unless fixes or local task capture are requested.
