---
status: draft
areas: [ios, tooling]
created: 2026-11-06
updated: 2026-11-06
---

# Upgrade the Xcode project to the supported JSON format

## Problem and outcome

Upgrade LetsGrow's Xcode project to the new JSON project format requested by the user, using the supported migration for the project's actual Xcode/toolchain. Preserve the app's targets, configuration, schemes, package references, tests, and developer workflows.

## Scope

- In scope: determine the exact supported format and prerequisites, migrate project metadata, and verify existing build/test/launch workflows.
- Out of scope: application feature changes, dependency upgrades unrelated to compatibility, deployment, or inventing a custom project generator as a substitute for a native project-format migration.

## Context

- Current project: [Feedback.xcodeproj/project.pbxproj](../ios-app/Feedback.xcodeproj/project.pbxproj), currently OpenStep-style project text with `objectVersion = 55`.
- Read [iOS policy](../ios-app/AGENTS.md), [simulator workflow](../ios-app/.agents/skills/lg-ios-run-simulator/SKILL.md), [harness setup](../ios-app/Docs/agent-harness.md), and [iOS CI](../.github/workflows/ios.yml).
- Inspect shared schemes, `ios-app/UnitTests.xctestplan`, `ios-app/ScreenSnapshots.xctestplan`, local package wiring, build configurations, localization/resource links, signing, capabilities, and build phases before migration.
- Coordinate with [navigator cleanup](ios-xcode-navigator-docs-and-agents.md); these tasks touch the same project metadata but have separate acceptance criteria.

## Decisions and open questions

- Confirmed: migrate project representation while preserving the existing build graph and user workflows.
- Assumptions: use a migration supported by Apple and the selected Xcode, with the smallest necessary compatibility changes.
- Unresolved: the exact JSON format, its availability in the selected Xcode, migration mechanism, and compatibility with local tooling, GitHub Actions, and Xcode Cloud have not been verified. The user's request is recorded without claiming format support has been established.
- Execution constraints: discover current native Xcode capabilities and official Apple guidance before choosing the migration. If no supported JSON project representation exists for this toolchain, record the evidence and required toolchain/decision rather than serializing the existing file arbitrarily or silently adopting a generator. Follow existing native Xcode/local automation rules. No commit, push, or deployment is authorized by this plan.

## Acceptance criteria

- [ ] AC-1: Exact destination format, supported toolchain, migration method, and CI compatibility are documented with verified primary-source guidance.
- [ ] AC-2: The migrated project opens in the selected Xcode with the intended targets, dependencies, configurations, shared schemes, test plans, signing/capabilities, resources, and build phases preserved.
- [ ] AC-3: Relevant native builds, discovered UnitTests targets, and app launch pass; screenshot-plan/resource packaging remains correctly wired.
- [ ] AC-4: Migration introduces no unrelated application changes and the task contains an architectural review guide explaining format/toolchain decisions and evidence.

## Implementation plan

### Phase 1 — Confirm format and compatibility

Outcome: a supported destination and migration method. Depends on access to the selected Xcode/current Apple guidance.

- [ ] Inspect the project's current metadata and local/CI consumers.
- [ ] Verify the requested JSON format and migration procedure using native Xcode and official documentation; record sources and minimum versions.
- [ ] Resolve compatibility implications and mark the plan ready when the migration is executable.
- [ ] Verify that the chosen approach preserves normal Xcode editing rather than introducing an unrequested generator or manual conversion.

### Phase 2 — Migrate project metadata

Outcome: the project uses the confirmed format with the same build graph. Depends on phase 1.

- [ ] Migrate using the supported mechanism and inspect changes by target/configuration responsibility.
- [ ] Preserve schemes, test plans, local packages, resource links, build phases, signing, and entitlements.
- [ ] Adjust only consumers that need the confirmed format/version change; coordinate navigator work to avoid conflicting project edits.
- [ ] Reopen and inspect the project through native Xcode.

### Phase 3 — Verify and hand off

Outcome: working developer workflows and a focused architectural review guide. Depends on phase 2.

- [ ] Verify native build, discovery/execution of relevant tests, launch, and screenshot target/plan/resource wiring under existing policy.
- [ ] Check hosted CI/release configuration compatibility without triggering an unrequested release.
- [ ] Record before/after structure, rationale, compatibility/tradeoffs, verification results, and remaining checks.

## Verification

| Acceptance | Preconditions | Action / check | Expected result |
| --- | --- | --- | --- |
| AC-1 | Selected Xcode and official format documentation | Confirm exact supported representation and migration/version requirements | Actionable format decision with evidence |
| AC-2 | Migrated project | Open through native Xcode and compare targets/configuration/scheme/resource wiring | Same intended build graph and developer entry points |
| AC-3 | Existing iOS prerequisites | Run relevant native build/test/launch checks; inspect ScreenSnapshots and resource packaging | Working app/test workflows with actual results recorded |
| AC-4 | Final metadata/config diff | Inspect scope and prepare Human review | Understandable migration, compatibility decision, and no unrelated behavior changes |

## Human review

Not implemented yet. Review will focus on the supported project representation, toolchain/CI compatibility, preservation of the build graph, and any required consumer changes.

## Handoff

- Completed: current project representation identified; migration task captured.
- Verification results: source inspection only. No format support lookup, migration, build, or launch performed.
- Blockers: exact supported JSON format and toolchain compatibility must be established.
- Next action: perform phase 1 and record the verified destination/migration path before changing project metadata.
