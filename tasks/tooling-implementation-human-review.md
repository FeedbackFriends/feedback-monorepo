---
status: done
areas: [tooling, docs]
created: 2026-11-06
updated: 2026-11-06
---

# Human review handoff from implementation

## Problem and outcome

Implementation should give a human a short reading guide focused on architectural decisions. Routine coding follows existing project standards and remains the implementing agent's responsibility.

## Scope

- In scope: implementation output, persistent task review section, shared reviewer guidance, and existing task structure migration.
- Out of scope: changing application architecture, adding a human approval gate, or external posting.

## Context

- Read `.agents/skills/lg-implement/SKILL.md`, `.agents/skills/lg-create-task/SKILL.md`, and the canonical task template.
- Shared workflow and review guidance live in `docs/agents/task-workflow.md` and `docs/agents/review.md`.
- Existing tasks must distinguish historical evidence from a new implementation review guide.

## Decisions and open questions

- Confirmed: human review focuses on ownership, boundaries, state/data flow, contracts, alternatives, and tradeoffs.
- Assumptions: conventional implementation details need no separate human decision; material departures from standards must be called out.
- Unresolved: None.
- Execution constraints: documentation/skill validation only; no app launch or external mutation required.

## Acceptance criteria

- [x] AC-1: Implementation ends with a concise architectural review guide and saves it in the task file.
- [x] AC-2: Review guidance separates human architectural judgement from agent responsibility for correctness and coding standards.
- [x] AC-3: Existing tasks remain structurally valid without invented review or verification claims.

## Implementation plan

- [x] Define the human-review output and wire it into implementation, task creation, and shared review guidance.
- [x] Add the review section to existing task files with accurate initial/historical status.
- [x] Validate skills, metadata, task structure, and local links; record results and a concrete review guide for this change.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1, AC-2 | Updated skills and shared documentation | Inspect output contract and walk simple-change and architectural-change handoffs | Decisions and source reading path are clear; ordinary standards are followed without ceremony |
| AC-3 | Canonical template and existing tasks | Validate task headings, skill metadata, links, and diff formatting | Consistent structure; no new runtime verification claimed |

## Human review

**Change and flow:** Implementation now writes an architectural reading guide into the task's Human review section and summarizes it in the final handoff. Agents continue to apply existing coding standards and check correctness.

**Architectural decisions:** One [shared guide](../docs/agents/human-review.md) owns the output contract across iOS, backend, web, and tooling. The implementation skill and task template link to it rather than maintaining separate formats. This adds a persistent section to each task; existing plans receive explicit historical/pending notes rather than invented review evidence. The guide is explanatory and does not add an approval gate.

**Reading path:**

1. [Human review guide](../docs/agents/human-review.md): the intended division of responsibility and content of the output.
2. [Implementation skill](../.agents/skills/lg-implement/SKILL.md#prepare-the-human-review): where the persistent and final handoffs become required.
3. [Task template](../.agents/skills/lg-create-task/assets/task.md#human-review): the portable section another session or reviewer reads.

**Verification and limits:** Three affected skills/metadata passed validation; six task files and the template passed schema checks; 263 local links/headings and diff formatting passed. Walked through routine and architectural-change output requirements. Documentation/instructions only; no app build or runtime behavior is claimed.

## Handoff

- Completed: shared guide, implementation/review guidance, template, and existing task sections updated.
- Verification results: three skills/metadata, six task schemas/template, 263 local links/headings, and diff formatting passed.
- Blockers: None.
- Next action: use the new Human review output on the next implementation.
