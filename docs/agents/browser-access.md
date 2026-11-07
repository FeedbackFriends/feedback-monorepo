# Browser access

- Use an isolated in-app browser for browser tasks by default.
- Do not connect to the user's personal Chrome or other browser profile unless the user explicitly requests it for that task.
- If a site requires authentication, have the user sign in to the isolated browser; do not transfer credentials or cookies from a personal browser.

## Tool ownership

Use `agent-browser` for exploratory browser automation when its CLI is available and compatible with the required isolated browser. Use `playwright-cli` for recording, tracing, and debugging the existing TypeScript Playwright suite; keep repeatable checks in `web/tests/` under the existing Playwright configuration. Check tool availability before choosing it; installing a skill does not install its CLI. Use available isolated browser tools when the preferred CLI is unavailable.

Follow the [web validation guide](../../web/docs/agents/validation.md) for test commands. Establish readiness through locators and web assertions rather than mandatory `networkidle` or fixed delays; see [Playwright readiness guidance](https://playwright.dev/docs/api/class-page#page-wait-for-load-state). Keep authentication state within the isolated task context.

## Browser CLI setup

Install the standalone developer tool and its managed Chrome once per machine:

```sh
npm install --global agent-browser@latest
agent-browser install
agent-browser skills get core
```

Check the package's current Node.js requirements before installing (`npm view agent-browser engines`); the browser CLI is separate from the web app's pinned Node.js runtime and dependencies. The native CLI must be available on `PATH`; check `agent-browser --version`. For Next.js runtime verification, follow [web validation](../../web/docs/agents/validation.md#nextjs-runtime-verification), including the skill's browser-version floor and runtime preflight. Use a named isolated session scoped to the worktree; restore only that task context's saved authentication.
