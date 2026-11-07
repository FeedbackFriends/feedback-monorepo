# Skills overview

**skills.sh updated at:** `2026-11-07T19:26:02Z`

Repository skills live in [root `.agents/skills/`](../.agents/skills/). Claude Code discovers the same content through per-skill symlinks under `.claude/skills/`. When adding, removing, or renaming a skill, maintain its alias as well as this catalog; edit canonical content only. Open a skill for its full procedure and invocation rules. This catalog excludes personal skills and local Apple exports.

Custom workflows use `lg-` names. Community provenance is recorded in [skills-lock.json](../skills-lock.json); use [the community update procedure](#update-community-skills) for installer updates and [lg-improve-harness](../.agents/skills/lg-improve-harness/SKILL.md) for repository-owned guidance improvements. Keep this catalog aligned when skills are added, removed, or renamed.

## LetsGrow workflows

| Skill | Purpose |
| --- | --- |
| [lg-commit-and-push](../.agents/skills/lg-commit-and-push/SKILL.md) | Commit or push when requested. |
| [lg-coolify-operations](../.agents/skills/lg-coolify-operations/SKILL.md) | Operate and troubleshoot Coolify production deployments. |
| [lg-create-task](../.agents/skills/lg-create-task/SKILL.md) | Capture an idea as a local draft task. |
| [lg-implement](../.agents/skills/lg-implement/SKILL.md) | Implement a saved task and prepare its handoff. |
| [lg-improve-harness](../.agents/skills/lg-improve-harness/SKILL.md) | Improve custom skills, AGENTS.md, rules, docs, and guidance routing. |
| [lg-investigate](../.agents/skills/lg-investigate/SKILL.md) | Trace a bug and record its cause and follow-up. |
| [lg-ios-localhost](../.agents/skills/lg-ios-localhost/SKILL.md) | Start the local backend and launch manager/anonymous apps. |
| [lg-ios-login](../.agents/skills/lg-ios-login/SKILL.md) | Launch iOS with a local test-account login. |
| [lg-ios-production](../.agents/skills/lg-ios-production/SKILL.md) | Launch a Release simulator app against deployed production. |
| [lg-ios-screenshots](../.agents/skills/lg-ios-screenshots/SKILL.md) | Capture and compare the curated iOS screenshot catalog. |
| [lg-ios-sync-openapi](../.agents/skills/lg-ios-sync-openapi/SKILL.md) | Sync handwritten iOS API boundaries with generated clients. |
| [lg-ios-test-notifications](../.agents/skills/lg-ios-test-notifications/SKILL.md) | Run the iOS notification test command. |
| [lg-maintain-docs](../.agents/skills/lg-maintain-docs/SKILL.md) | Audit, trim, and update documentation against source. |
| [lg-refine](../.agents/skills/lg-refine/SKILL.md) | Settle requirements and architectural decisions. |
| [lg-review](../.agents/skills/lg-review/SKILL.md) | Review changes for concrete regressions. |
| [lg-tailwind-nextjs-expert](../.agents/skills/lg-tailwind-nextjs-expert/SKILL.md) | Implement web styling with existing tokens and components. |
| [lg-verify](../.agents/skills/lg-verify/SKILL.md) | Verify acceptance criteria or reproduce behavior. |

## Community skills

| Skill | Purpose | skills.sh |
| --- | --- | --- |
| [agent-browser](../.agents/skills/agent-browser/SKILL.md) | Automate browser navigation, interaction, and testing. | [vercel-labs/agent-browser](https://skills.sh/vercel-labs/agent-browser/agent-browser) |
| [email-best-practices](../.agents/skills/email-best-practices/SKILL.md) | Build accessible, reliable email flows and deliverability. | [resend/email-best-practices](https://skills.sh/resend/email-best-practices/email-best-practices) |
| [find-skills](../.agents/skills/find-skills/SKILL.md) | Discover skills for a requested capability. | [vercel-labs/skills](https://skills.sh/vercel-labs/skills/find-skills) |
| [frontend-design](../.agents/skills/frontend-design/SKILL.md) | Design distinctive web interfaces. | [anthropics/skills](https://skills.sh/anthropics/skills/frontend-design) |
| [maestro-mobile-testing](../.agents/skills/maestro-mobile-testing/SKILL.md) | Author and debug Maestro mobile E2E flows. | [tovimx/maestro-mobile-testing-skill](https://skills.sh/tovimx/maestro-mobile-testing-skill/maestro-mobile-testing) |
| [marketing-psychology](../.agents/skills/marketing-psychology/SKILL.md) | Apply behavioral principles to marketing decisions. | [coreyhaines31/marketingskills](https://skills.sh/coreyhaines31/marketingskills/marketing-psychology) |
| [next-best-practices](../.agents/skills/next-best-practices/SKILL.md) | Apply Next.js architecture and implementation guidance. | [vercel-labs/openreview](https://skills.sh/vercel-labs/openreview/next-best-practices) |
| [next-cache-components](../.agents/skills/next-cache-components/SKILL.md) | Use Next.js cache components and revalidation APIs. | [vercel-labs/openreview](https://skills.sh/vercel-labs/openreview/next-cache-components) |
| [next-upgrade](../.agents/skills/next-upgrade/SKILL.md) | Upgrade Next.js using migration guides and codemods. | [vercel-labs/openreview](https://skills.sh/vercel-labs/openreview/next-upgrade) |
| [playwright-cli](../.agents/skills/playwright-cli/SKILL.md) | Automate browsers and work with Playwright tests. | [microsoft/playwright-cli](https://skills.sh/microsoft/playwright-cli/playwright-cli) |
| [retro](../.agents/skills/retro/SKILL.md) | Reflect on a session and suggest harness improvements. | [mattpocock/skills](https://skills.sh/mattpocock/skills/retro) |
| [seo-audit](../.agents/skills/seo-audit/SKILL.md) | Diagnose technical and on-page SEO problems. | [coreyhaines31/marketingskills](https://skills.sh/coreyhaines31/marketingskills/seo-audit) |
| [shadcn](../.agents/skills/shadcn/SKILL.md) | Find, add, compose, and maintain shadcn components. | [shadcn/ui](https://skills.sh/shadcn/ui/shadcn) |
| [ui-ux-pro-max](../.agents/skills/ui-ux-pro-max/SKILL.md) | Consult searchable UI/UX patterns and design references. | [nextlevelbuilder/ui-ux-pro-max-skill](https://skills.sh/nextlevelbuilder/ui-ux-pro-max-skill/ui-ux-pro-max) |
| [vercel-composition-patterns](../.agents/skills/vercel-composition-patterns/SKILL.md) | Design scalable React component APIs and composition. | [vercel-labs/agent-skills](https://skills.sh/vercel-labs/agent-skills/vercel-composition-patterns) |
| [vercel-react-best-practices](../.agents/skills/vercel-react-best-practices/SKILL.md) | Improve React and Next.js performance. | [vercel-labs/agent-skills](https://skills.sh/vercel-labs/agent-skills/vercel-react-best-practices) |
| [wait-what](../.agents/skills/wait-what/SKILL.md) | Re-explain an unclear response in plain language. | [mattpocock/skills](https://skills.sh/mattpocock/skills/wait-what) |
| [web-design-guidelines](../.agents/skills/web-design-guidelines/SKILL.md) | Review UI against web interface and accessibility guidance. | [vercel-labs/agent-skills](https://skills.sh/vercel-labs/agent-skills/web-design-guidelines) |
| [webapp-testing](../.agents/skills/webapp-testing/SKILL.md) | Test web applications with Playwright. | [anthropics/skills](https://skills.sh/anthropics/skills/webapp-testing) |
| [writing-for-agents](../.agents/skills/writing-for-agents/SKILL.md) | Write concise, effective agent instructions and skills. | [mattpocock/skills](https://skills.sh/mattpocock/skills/writing-for-agents) |

## Local Apple skills

Apple guidance lives directly in `.agents/skills/`, alongside tracked custom and community skills. Apple folders and Claude discovery aliases are ignored by generated `.gitignore` files; the ignored `.agents/skills/.apple-skills.json` records their inventory. Run `python3 scripts/update-xcode-skills.py` on initial setup and after Xcode upgrades; see [Apple skills setup](../ios-app/Docs/agent-harness.md#apple-skills-setup). The community updater excludes that inventory while keeping community provenance in `skills-lock.json` and maintaining its separate freshness timestamp.

## Update community skills

[Update community skills](../.github/workflows/update-community-skills.yml) runs every Monday at 06:23 UTC and supports manual runs from GitHub Actions. It validates and refreshes all locked community skills, records the successful completion timestamp above, and commits directly to `main`. Failed or partial refreshes are not committed and do not advance the timestamp. A concurrent change to `main` causes the normal push to fail; rerun from the latest main.

The workflow uses the built-in `GITHUB_TOKEN` with `contents: write`; repository rules must allow it to push to `main`. No additional secret or PR is needed. Bot-token pushes do not trigger other GitHub Actions workflows, so this workflow performs its own focused validation.

For a local refresh, inspect local edits first, then run from the monorepo root:

```sh
python3 scripts/update-community-skills.py
```

The [helper](../scripts/update-community-skills.py) reinstalls explicit names from each recorded source through `skills.sh add`, avoiding observed skips of nested Next.js skills by `skills update`. `skills-lock.json` owns provenance. Unavailable sources, skipped installs, and inventory mismatches fail the run. Keep community content upstream-owned and update inventory/source links when adding or removing skills.

Custom skills and repository guidance remain maintained through [lg-improve-harness](../.agents/skills/lg-improve-harness/SKILL.md); ordinary tasks do not wait on community freshness. Local updates do not authorize committing, pushing, or executing installed workflows.
