---
name: lg-improve-harness
description: Improve LetsGrow's agent harness, including custom lg- skills, AGENTS.md, rules, documentation, and guidance routing. Use for harness cleanup or improvements grounded in session evidence and the current system.
---

# Improve the harness

Read [harness ownership](../../../docs/agent-tooling.md), Git status, and the guidance involved in the request. Use [writing-for-agents](../writing-for-agents/SKILL.md). Track unfinished work through the [task workflow](../../../docs/agents/task-workflow.md).

1. Ground the improvement in the user's request, observed session friction, or a concrete mismatch with current code, tools, or configuration. Trace the affected instruction routes and callers. Preserve unrelated work and existing authorization boundaries.
2. Put the change where it belongs: `AGENTS.md` for concise policy and discovery, owning guides for durable rules and knowledge, `lg-` skills for reusable procedures, and scripts/configuration for executable behavior. Reuse or consolidate existing owners. Use [lg-maintain-docs](../lg-maintain-docs/SKILL.md) for substantial documentation audits.
3. Make the smallest coherent improvement. Remove contradictions, duplicated instructions, stale references, and unnecessary workflows; preserve useful invariants, recovery steps, and verification requirements. Keep descriptions precise and disclose conditional detail through links. Keep project-specific guidance outside community skill contents.
4. Repair callers, indexes, and the [skills overview](../../../docs/skills.md) after moves or renames. Validate changed metadata and local links, check `git diff --check`, and walk affected task routes to confirm they still reach the intended rules without adding approval gates. Run relevant helper checks when executable behavior changes.

Report what improved, the evidence, verification, and remaining uncertainty. Harness improvement does not perform community package updates or advance their freshness timestamp; that separate procedure lives in [community skill updates](../../../docs/skills.md#update-community-skills). Commits, pushes, deployments, and executing installed workflows retain their existing authorization rules.
