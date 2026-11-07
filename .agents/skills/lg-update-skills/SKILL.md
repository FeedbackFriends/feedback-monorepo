---
name: lg-update-skills
description: Update repository skills, refresh skills.sh installations, and reconcile custom workflows with the current LetsGrow system.
---

# Update skills

Read [harness ownership](../../../docs/agent-tooling.md#rules-and-skills), Git status, and the requested skills before changing them. Keep one canonical copy in root `.agents/skills/`.

- **Community skills:** use `skills-lock.json` for provenance. Run `npx --yes skills@latest update --project --yes <names...>` from the monorepo root; omit names only for an all-community update. For new or untracked upstream skills, use `npx --yes skills@latest add <owner/repo> --skill <names...> --agent codex --yes`. Keep the installer-generated lockfile tracked. Inspect local edits before reinstalling; preserve necessary repository rules in the owning docs or a custom workflow rather than patching vendored content. If the updater skips an installed skill, retry `add` with its recorded source and name and inspect the result. If a source moved, find its upstream replacement; report unavailable skills without silently substituting a different author.
- **Custom skills:** names and folders start with `lg-`. Use [writing-for-agents](../writing-for-agents/SKILL.md). Trace commands, tool boundaries, callers, and invariants against current code/configuration. Consolidate duplicate workflows and move lasting rules to their owning guides. Custom skills have no installer lock entry.

After successfully refreshing every community skill (including a check confirming it is already current), set **skills.sh updated at** in [the skills overview](../../../docs/skills.md) to the completion time in UTC ISO 8601 format (`YYYY-MM-DDTHH:MM:SSZ`). Partial, skipped, or failed refreshes leave that timestamp unchanged. Keep the overview's inventory and source links aligned with installed skills and the lockfile.

Check every changed skill's metadata and local references, updated source/diff, naming and lockfile coverage, duplicate copies, and `git diff --check`. Run relevant helper checks when executable content changes. Refresh the [guidance navigator](../../../ios-app/Docs/SETUP.md#repository-guidance-in-the-navigator) without changing the real Git index. Report updated skills, sources, checks, and unresolved drift. Follow the [task workflow](../../../docs/agents/task-workflow.md) for unfinished work. Installation/update does not authorize running the installed workflows, committing, or pushing.
