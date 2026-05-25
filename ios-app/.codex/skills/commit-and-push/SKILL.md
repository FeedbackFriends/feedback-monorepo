---
name: commit-and-push
description: Commit intended local changes in small independent Git commits when possible, then push them. Use when the user asks Codex to commit, push, publish, save work to GitHub, or otherwise create Git commits and send them upstream. If the user does not name a branch, push to the current branch.
---

# Commit And Push

## Workflow

Use this workflow only after the user explicitly asks to commit and push.

1. Inspect the worktree with `git status --short` and review relevant diffs before staging.
2. Determine the push branch:
   - If the user names a branch, push to that branch.
   - If the user does not name a branch, push to the current branch from `git branch --show-current`.
   - If the current branch cannot be determined, stop and ask the user for the branch.
3. Split the intended changes into the smallest independent commits that still make sense:
   - Group changes by user-visible behavior, bug fix, test addition, docs update, generated artifact update, or mechanical cleanup.
   - Keep each commit buildable and coherent on its own.
   - Do not split a tightly coupled change just to make commits smaller.
4. Stage only the paths or hunks for the next independent commit. Do not stage unrelated user work.
5. Create each commit with a clear message describing that commit's scope. If the user supplied one commit message, use it only when making a single commit; otherwise write focused messages for each independent commit.
6. Push the resulting commit or commits to the selected branch.

## Guardrails

- Do not create or switch branches unless the user explicitly asks for that.
- Do not push to a different branch just because an upstream is configured differently; use the user-named branch or the current branch.
- Do not amend, rebase, reset, force-push, or delete branches unless the user explicitly asks.
- Prefer multiple small commits over one large commit when the changes are separable.
- If there are unrelated changes, leave them unstaged and mention them in the final response.
- If there is nothing to commit, do not create an empty commit unless the user explicitly asks.
- If tests or checks are relevant and reasonably available, run them before committing; otherwise state what was not run.

## Commands

Prefer explicit, non-interactive commands:

```bash
git status --short
git diff -- <paths>
git diff --cached
git branch --show-current
git add <intended-paths>
git commit -m "<message>"
git push origin <branch>
```
