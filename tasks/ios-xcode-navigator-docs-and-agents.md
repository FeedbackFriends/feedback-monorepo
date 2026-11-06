---
status: ready
areas: [ios, tooling, docs]
created: 2026-11-06
updated: 2026-11-06
---

# Expose docs and agent files in Xcode and clean stale references

## Problem and outcome

Make repository documentation, task plans, and agent instructions/configuration easy to browse and edit from Xcode's project navigator. Remove stale navigator entries, including `allow_xcode_mcp.js`, which is still referenced by the project but no longer exists in the repository.

## Scope

- In scope: repository docs and agent/task files, logical navigator organization, renamed skill paths/aliases, and cleanup of missing/duplicate project references.
- Out of scope: changing app behavior, restoring obsolete permission automation, deleting active tools because they look old, or adding documentation/agent files to app/test resources or compilation.

## Context

- [Project metadata](../ios-app/Feedback.xcodeproj/project.xcproj) currently contains explicit `.agents` groups and an `allow_xcode_mcp.js` file reference under a scripts group. Repository file discovery finds no corresponding script.
- Current project groups expose only a selection of skills and agent metadata; root lifecycle skills and task/doc additions need to be included.
- Inspect root `AGENTS.md`, `docs/`, `tasks/`, `.agents/`, and checked-in `.codex/` guidance/configuration, plus `ios-app/AGENTS.md`, `ios-app/Docs/`, `ios-app/.agents/`, and the repository-owned docs/agent files under backend/web. Include supporting skill references, templates, metadata, and helper scripts where applicable.
- Read [iOS policy](../ios-app/AGENTS.md), [harness ownership](../ios-app/Docs/agent-harness.md), [agent-tooling overview](../docs/agent-tooling.md), and [native simulator workflow](../ios-app/.agents/skills/lg-ios-run-simulator/SKILL.md).
- The project now uses Xcode’s native JSON `project.xcproj` format (Xcode 27+). Choose navigator mechanisms supported by that format; see [project configuration guidance](../ios-app/Docs/agent-harness.md#project-configuration-format).

## Decisions and open questions

- Confirmed: all repository-owned docs and agent/task files should be accessible from the navigator with a clear relationship to their real filesystem paths.
- Confirmed: remove the stale `allow_xcode_mcp.js` reference; do not recreate a removed automation script to satisfy a dangling navigator item.
- Assumptions: prefer supported folder-based organization when it keeps additions/removals current without altering target membership. Use explicit groups/references where needed by the actual format. Avoid duplicate trees for skill aliases pointing to the same canonical content.
- Unresolved: None at the product level; the implementation should audit actual files/references and choose the supported navigator representation.
- Execution constraints: expose checked-in guidance/configuration only; keep secrets, `.env`, user-specific files, dependency/build output, and generated captures out of navigator scope. Verify every deletion against the filesystem and existing callers. No application behavior, deployment, commits, or pushes are requested.

## Acceptance criteria

- [ ] AC-1: Repository-owned docs, tasks, and agent files can be found and opened from clearly organized navigator groups, including root and relevant app-local files.
- [ ] AC-2: Missing/stale references such as `allow_xcode_mcp.js` are removed and renamed skill/alias paths resolve; unrelated active helpers remain intact.
- [ ] AC-3: Documentation/agent additions do not enter Sources, Resources, or unintended target membership; build/test/scheme/package behavior is preserved.
- [ ] AC-4: The chosen grouping approach and its maintenance behavior are documented, with a human reading path and verification evidence.

## Implementation plan

### Phase 1 — Inventory files and stale references

Outcome: an actual filesystem-to-navigator comparison. No dependency on project-format migration completion.

- [ ] Inventory repository-owned documentation, tasks, agent metadata/templates/references/helpers, and existing project groups.
- [ ] Resolve project file references against their group/source-root locations; identify missing paths, broken aliases, and duplicate entries.
- [ ] Confirm `allow_xcode_mcp.js` is absent and locate all references before removing its navigator entry.
- [ ] Record the grouping plan and check compatibility with the current project format.

### Phase 2 — Organize navigator and remove obsolete entries

Outcome: useful coverage with stable source paths. Depends on phase 1.

- [ ] Add logical root/app documentation and agent/task groups using supported folder or file references.
- [ ] Include canonical `lg-*` skills, supporting resources, and tasks without duplicating alias content unnecessarily.
- [ ] Remove stale navigator references/groups and correct paths; delete actual obsolete files only when their lack of callers is established within scope.
- [ ] Ensure docs/configuration/helpers have no app/test compilation or bundle-resource membership.

### Phase 3 — Verify visibility and build isolation

Outcome: navigable files and preserved app wiring. Depends on phase 2.

- [ ] Open the project through native Xcode and verify representative root/iOS/backend/web docs, tasks, and agent files open at their real paths.
- [ ] Check coverage against the inventory and verify no dangling or duplicate navigator entries remain within the touched groups.
- [ ] Inspect target/resource/build-phase differences and run relevant native project/build/test-discovery checks.
- [ ] Document how new files become visible and prepare the Human review reading path.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1 | Inventory and updated project | Open representative files through Xcode and compare coverage with filesystem inventory | All scoped files reachable in clear groups |
| AC-2 | Resolved navigator reference audit | Check stale/missing/renamed paths and skill aliases | No dangling `allow_xcode_mcp.js` or stale skill references; active helpers retained |
| AC-3 | Project diff and native Xcode | Inspect target/resource membership and run relevant build/test discovery | Documentation stays outside app/test build content; existing workflows preserved |
| AC-4 | Final grouping approach | Read maintenance notes and Human review | Clear rationale, source reading path, and observed evidence |

## Human review

Not implemented yet. Review will focus on folder/group ownership, canonical files versus aliases, future maintenance, and keeping navigator visibility separate from target/resource membership.

## Handoff

- Completed: confirmed a stale `allow_xcode_mcp.js` project reference and identified existing partial agent groups; task captured.
- Verification results: source/filesystem inspection only. No project cleanup or native Xcode verification performed.
- Blockers: None for starting the inventory; coordinate project-format edits if both tasks are active.
- Next action: inventory scoped files and resolve existing project-group paths before selecting the navigator layout.
