---
name: pr-workflow
description: Prepare pull request output and follow repository PR working norms. Use when a task is wrapping up, when the user asks for a PR title or description, when summarizing validation, or when deciding how to scope and present changes for review.
---

# Pull Request Workflow

Use this skill when the work is likely complete or when the user asks for PR-related output.

## Goals

- keep changes reviewable and scoped to one concern
- present operational impact clearly
- suggest a PR title and PR description when the task looks done
- report what was validated and what was not

## Workflow

1. Check the current scope.
If the diff mixes unrelated concerns, call that out and avoid presenting it as a clean PR without noting the problem.

2. Check local instructions first.
Use the `AGENTS.md` in the current working directory for area-specific PR norms, validation commands, screenshots, migration notes, or deployment callouts.

3. Summarize the change in reviewer language.
Focus on user-visible behavior, deployment impact, data changes, CI/CD changes, secrets, domains, and cost-impacting edits when relevant.

4. State validation clearly.
List the checks that were run. If checks were not run, say so directly instead of implying they passed.

5. Suggest a PR when appropriate.
When the task appears complete, include:
- a short proposed PR title
- a concise PR description
- validation notes

## PR Description Shape

Prefer a compact structure like:

```md
## Summary
- ...

## Validation
- ...
```

Add extra sections only when they materially help review, such as:
- `## Deployment impact`
- `## Secrets / config`
- `## Screenshots`
- `## Migrations`

## Review Norms

- Prefer small, reviewable PRs over bundled changes.
- Call out risky assumptions, skipped validation, and follow-up work.
- Mention new secrets, tokens, env vars, or branch-protection implications.
- Mention cost-affecting infra changes such as Render plan, disk, region, or service-count changes.
- For frontend work, mention screenshots when the local instructions expect them.
- For backend work, mention migrations, API contract changes, or operational consequences when applicable.

## Output Style

- Keep PR titles short, imperative, and specific.
- Keep PR descriptions concise and scannable.
- Do not invent validation that was not run.
- If the task is not actually done, do not force a PR recommendation.
