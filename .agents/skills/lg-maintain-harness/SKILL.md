---
name: lg-maintain-harness
description: Improve LetsGrow's agent harness, including custom lg- skills, AGENTS.md, rules, documentation, and guidance routing. Use for harness simplification, documentation audits, and guidance drift reviews grounded in session evidence and the current system.
---

# Maintain the harness

Read [harness ownership](../../../docs/agent-tooling.md), Git status, and the guidance involved in the request. Use [writing-for-agents](../writing-for-agents/SKILL.md). Follow the [task workflow](../../../docs/agents/task-workflow.md) for the simple backlog and conversation-based planning. Add todos only on explicit user request.

1. Ground the improvement in the user's request, observed session friction, or a concrete mismatch with current code, tools, or configuration. Trace the affected instruction routes and callers. Preserve unrelated work and existing authorization boundaries.
2. Verify documentation claims against their owners: code for behavior, configuration and scripts for setup/commands, and tests for intended coverage. Distinguish product direction and unfinished work from implemented behavior. Preserve product strategy, authorization boundaries, and unresolved operational requirements; documentation cleanup does not authorize changing system behavior.
3. Put the change where it belongs: `AGENTS.md` for concise policy and discovery, owning guides for durable rules and knowledge, `lg-` skills for reusable procedures, and scripts/configuration for executable behavior. Reuse or consolidate existing owners.
4. Make the smallest coherent improvement. Remove contradictions, duplicated instructions, stale references, obsolete reports, and unnecessary workflows; preserve useful invariants, recovery steps, and verification requirements. Keep descriptions precise. Keep project-specific guidance outside community skill contents.
5. Repair callers, indexes, and the [skills overview](../../../docs/skills.md) after moves or renames. Validate changed metadata, local links and anchors, and references to removed paths, check `git diff --check`, and walk affected task routes to confirm they still reach the intended rules without adding approval gates. Run relevant helper checks when executable behavior changes.

## Inline by default

Keep repository-owned harness guidance inline in its owning file by default, including long or conditional detail. Extract a shared guide only when the content is reused in multiple places; keep one authoritative home and link from its callers. A catalog or discovery link alone does not establish reuse. Merge single-use supporting documents into their owner and remove the redundant files. This repository-specific rule takes precedence over the disclosure advice in `writing-for-agents`.

Report what improved or was consolidated, actual verification, and remaining uncertainty. For documentation audits, report before/after document and word counts; claim currency only for the inspected scope. Harness improvement does not perform community package updates or advance their freshness timestamp; that separate procedure lives in [community skill updates](../../../docs/skills.md#update-community-skills). Commits, pushes, deployments, and executing installed workflows retain their existing authorization rules.
