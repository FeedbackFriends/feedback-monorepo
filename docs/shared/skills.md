# Skills overview

**skills.sh updated at:** `2026-11-09T16:35:00Z`

Repository skills live in [root `.agents/skills/`](../../.agents/skills). Claude Code discovers the same content through per-skill symlinks under `.claude/skills/`. When adding, removing, or renaming a skill, maintain its alias as well as this catalog; edit canonical content only. Open a skill for its full procedure and invocation rules. This catalog excludes personal skills and local Apple exports.

Custom workflows use `lg-` names that describe the action. Group platform workflows under `lg-ios-`, `lg-web-`, or `lg-coolify-`; keep shared workflow names short. Community provenance is recorded in [skills-lock.json](../../skills-lock.json); use [the community update procedure](#update-community-skills) for installer updates and [lg-maintain-harness](../../.agents/skills/lg-maintain-harness/SKILL.md) for repository-owned guidance improvements. Use [lg-audit-community-skills](../../.agents/skills/lg-audit-community-skills/SKILL.md) to assess suitability, alternatives, gaps, and overlap before changing the collection. Keep this catalog aligned when skills are added, removed, or renamed.

## LetsGrow workflows

| Skill | Purpose |
| --- | --- |
| [lg-audit-community-skills](../../.agents/skills/lg-audit-community-skills/SKILL.md) | Compare installed community skills with skills.sh alternatives and recommend a coherent collection. |
| [lg-commit-and-push](../../.agents/skills/lg-commit-and-push/SKILL.md) | Commit or push when requested. |
| [lg-coolify-operate](../../.agents/skills/lg-coolify-operate/SKILL.md) | Operate and troubleshoot Coolify production deployments. |
| [lg-add-todo](../../.agents/skills/lg-add-todo/SKILL.md) | Add a short nontechnical item to `todos.md` only when requested. |
| [lg-maintain-harness](../../.agents/skills/lg-maintain-harness/SKILL.md) | Simplify custom skills, AGENTS.md, rules, and documentation; audit guidance against source. |
| [lg-ios-run-local](../../.agents/skills/lg-ios-run-local/SKILL.md) | Start local backend and one employee simulator; `login-only` skips backend startup. |
| [lg-ios-run-production](../../.agents/skills/lg-ios-run-production/SKILL.md) | Launch a Release simulator app against deployed production. |
| [lg-ios-capture-screenshots](../../.agents/skills/lg-ios-capture-screenshots/SKILL.md) | Capture and compare the curated iOS screenshot catalog. |
| [lg-ios-sync-api](../../.agents/skills/lg-ios-sync-api/SKILL.md) | Sync handwritten iOS API boundaries with generated clients. |
| [lg-ios-test-notifications](../../.agents/skills/lg-ios-test-notifications/SKILL.md) | Run the iOS notification test command. |
| [lg-deliver](../../.agents/skills/lg-deliver/SKILL.md) | Coordinate outcome agreement, implementation, verification, independent review, finding resolution, and human handoff. |
| [lg-plan](../../.agents/skills/lg-plan/SKILL.md) | Grill requirements and architecture with the user before implementation. |
| [lg-web-style](../../.agents/skills/lg-web-style/SKILL.md) | Implement web styling with existing tokens and components. |

## Community skills

| Skill | Purpose | skills.sh |
| --- | --- | --- |
| [agent-browser](../../.agents/skills/agent-browser/SKILL.md) | Automate browser navigation, interaction, and testing. | [vercel-labs/agent-browser](https://skills.sh/vercel-labs/agent-browser/agent-browser) |
| [copywriting](../../.agents/skills/copywriting/SKILL.md) | Write evidence-backed Danish-first marketing copy. | [coreyhaines31/marketingskills](https://skills.sh/coreyhaines31/marketingskills/copywriting) |
| [customer-research](../../.agents/skills/customer-research/SKILL.md) | Plan customer research and synthesize evidence for product decisions. | [coreyhaines31/marketingskills](https://skills.sh/coreyhaines31/marketingskills/customer-research) |
| [email-best-practices](../../.agents/skills/email-best-practices/SKILL.md) | Build accessible, reliable email flows and deliverability. | [resend/email-best-practices](https://skills.sh/resend/email-best-practices/email-best-practices) |
| [find-skills](../../.agents/skills/find-skills/SKILL.md) | Discover skills for a requested capability. | [vercel-labs/skills](https://skills.sh/vercel-labs/skills/find-skills) |
| [frontend-design](../../.agents/skills/frontend-design/SKILL.md) | Design distinctive web interfaces. | [anthropics/skills](https://skills.sh/anthropics/skills/frontend-design) |
| [next-best-practices](../../.agents/skills/next-best-practices/SKILL.md) | Apply Next.js architecture and implementation guidance. | [vercel-labs/openreview](https://skills.sh/vercel-labs/openreview/next-best-practices) |
| [next-dev-loop](../../.agents/skills/next-dev-loop/SKILL.md) | Verify running Next.js changes through framework diagnostics and an isolated browser. | [vercel/next.js](https://skills.sh/vercel/next.js/next-dev-loop) |
| [next-upgrade](../../.agents/skills/next-upgrade/SKILL.md) | Upgrade Next.js using migration guides and codemods. | [vercel-labs/openreview](https://skills.sh/vercel-labs/openreview/next-upgrade) |
| [onboarding](../../.agents/skills/onboarding/SKILL.md) | Design first-use journeys and shorten the path to useful value. | [coreyhaines31/marketingskills](https://skills.sh/coreyhaines31/marketingskills/onboarding) |
| [playwright-cli](../../.agents/skills/playwright-cli/SKILL.md) | Automate browsers and work with Playwright tests. | [microsoft/playwright-cli](https://skills.sh/microsoft/playwright-cli/playwright-cli) |
| [seo-audit](../../.agents/skills/seo-audit/SKILL.md) | Diagnose technical and on-page SEO problems. | [coreyhaines31/marketingskills](https://skills.sh/coreyhaines31/marketingskills/seo-audit) |
| [shadcn](../../.agents/skills/shadcn/SKILL.md) | Find, add, compose, and maintain shadcn components. | [shadcn/ui](https://skills.sh/shadcn/ui/shadcn) |
| [supabase-postgres-best-practices](../../.agents/skills/supabase-postgres-best-practices/SKILL.md) | Review Postgres queries, indexing, schema, and locking. | [supabase/agent-skills](https://skills.sh/supabase/agent-skills/supabase-postgres-best-practices) |
| [ui-ux-pro-max](../../.agents/skills/ui-ux-pro-max/SKILL.md) | Consult searchable UI/UX patterns and design references. | [nextlevelbuilder/ui-ux-pro-max-skill](https://skills.sh/nextlevelbuilder/ui-ux-pro-max-skill/ui-ux-pro-max) |
| [vercel-composition-patterns](../../.agents/skills/vercel-composition-patterns/SKILL.md) | Design scalable React component APIs and composition. | [vercel-labs/agent-skills](https://skills.sh/vercel-labs/agent-skills/vercel-composition-patterns) |
| [vercel-react-best-practices](../../.agents/skills/vercel-react-best-practices/SKILL.md) | Improve React and Next.js performance. | [vercel-labs/agent-skills](https://skills.sh/vercel-labs/agent-skills/vercel-react-best-practices) |
| [web-design-guidelines](../../.agents/skills/web-design-guidelines/SKILL.md) | Review UI against web interface and accessibility guidance. | [vercel-labs/agent-skills](https://skills.sh/vercel-labs/agent-skills/web-design-guidelines) |
| [writing-for-agents](../../.agents/skills/writing-for-agents/SKILL.md) | Write concise, effective agent instructions and skills. | [mattpocock/skills](https://skills.sh/mattpocock/skills/writing-for-agents) |

## Local Apple skills

Apple guidance lives directly in `.agents/skills/`, alongside tracked custom and community skills. Apple folders and Claude discovery aliases are ignored by generated `.gitignore` files; the ignored `.agents/skills/.apple-skills.json` records their inventory. Run `python3 scripts/shared/update-xcode-skills.py` on initial setup and after Xcode upgrades; see [Apple skills setup](../ios/development.md#apple-skills-setup). The community updater excludes that inventory while keeping community provenance in `skills-lock.json` and maintaining its separate freshness timestamp.

## Update community skills

[Update community skills](../../.github/workflows/update-community-skills.yml) runs every Monday at 06:23 UTC and supports manual runs from GitHub Actions. It validates and refreshes all locked community skills, records the successful completion timestamp above, and commits directly to `main`. Failed or partial refreshes are not committed and do not advance the timestamp. A concurrent change to `main` causes the normal push to fail; rerun from the latest main.

The workflow uses the built-in `GITHUB_TOKEN` with `contents: write`; repository rules must allow it to push to `main`. No additional secret or PR is needed. Bot-token pushes do not trigger other GitHub Actions workflows, so this workflow performs its own focused validation.

For a local refresh, inspect local edits first, then run from the monorepo root:

```sh
python3 scripts/shared/update-community-skills.py
```

The [helper](../../scripts/shared/update-community-skills.py) reinstalls explicit names from each recorded source through `skills.sh add`, avoiding observed skips of nested Next.js skills by `skills update`. `skills-lock.json` owns provenance. Unavailable sources, skipped installs, and inventory mismatches fail the run. Keep community content upstream-owned and update inventory/source links when adding or removing skills.

Custom skills and repository guidance remain maintained through [lg-maintain-harness](../../.agents/skills/lg-maintain-harness/SKILL.md); ordinary tasks do not wait on community freshness. Local updates do not authorize committing, pushing, or executing installed workflows.
