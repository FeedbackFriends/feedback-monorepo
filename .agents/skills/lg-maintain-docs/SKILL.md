---
name: lg-maintain-docs
description: Audit, trim, consolidate, and update LetsGrow documentation against the current system. Use for documentation cleanup or drift reviews.
---

# Maintain documentation

Follow [root policy](../../../AGENTS.md) and the owning app's instructions. Use [writing-for-agents](../writing-for-agents/SKILL.md) when editing agent guidance. Follow the [task workflow](../../../docs/agents/task-workflow.md) for the simple backlog and conversation-based planning. Add todos only on explicit user request.

1. Establish the requested scope. Inspect Git status, docs and their callers; record document/word counts. Preserve unrelated work and the product strategy.
2. Verify claims against their owners: code for implemented behavior, config/manifests for setup, scripts/CI for commands and checks, tests for intended coverage. Read callers and surrounding control flow, not just matching names. Use authorized read-only runtime inspection when a claim depends on deployed state. A test's existence is not a passing result. Product strategy describes direction; unfinished tasks describe planned work.
3. Keep one maintained home per topic. Delete obsolete reports and migration logs; merge duplicated rules and replace repeated procedures with links. Keep useful invariants, recovery steps, permission limits, API contracts, and unresolved operational requirements. Prefer source pointers over copied file lists, versions, counts, or code examples that drift. Documentation maintenance does not authorize changing system behavior or relaxing policy; ask about consequential conflicts that sources cannot resolve.
4. Rewrite for the next reader: concrete purpose, shortest usable instructions, and relevant links. Remove generic advice, conversational history, redundant caveats, and unsupported claims. State verification limits where they matter. Update inbound links, anchors, plain-text paths, root indexes, and affected skill routing before removing a page. Avoid adding indexes that only point to other indexes.
5. Validate affected local links and anchors, removed-path references, edited skill metadata, and `git diff --check`. For guidance moves, refresh/check the Xcode navigator using [setup](../../../ios-app/Docs/SETUP.md#repository-guidance-in-the-navigator); keep the user's real index unchanged unless staging was requested. Run helper checks if executable behavior changed; docs alone need no app build.

Report what was removed/consolidated, before/after size, source checks, and unresolved drift. Claim currency only for the inspected scope. Prepare the handoff and remove a corresponding todo only when its entire outcome and required checks are complete. Commit, push, deployment, and account changes require their own authorization.
