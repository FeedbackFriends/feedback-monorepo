# Agent harness architecture

The harness is the repository's instructions, workflows, todos, tool connections, and checks. The agent client provides the model, tool execution, permissions, and personal plugins; this repository has no separate agent runtime.

```mermaid
flowchart TD
    Request[User request] --> Agent[Agent session]
    Policy[Root and app AGENTS.md] --> Agent
    Guides[Owning guides and skills] --> Agent
    Agent <--> Tasks[Root todos: unfinished work]
    Agent --> Tools[MCP and explicit commands]
    Tools --> Apps[Web, backend, iOS, infrastructure]
    Apps --> Evidence[Tests and observable checks]
    Evidence --> Agent
    Agent --> Review[Human review handoff]
    Git[Git events] --> CI[CI and releases]
```

Reading guidance does not execute a hook or grant tool permission. The agent performs the workflow; scripts and CI enforce their own checks.

## Ownership and discovery

| Home | Owns |
| --- | --- |
| [Root AGENTS.md](AGENTS.md) and app policies | Shared boundaries and routes to platform rules |
| [Docs index](docs/README.md) and root `docs/{shared,ios,backend,web}/` | Shared knowledge and platform-specific invariants, with one maintained home per topic |
| [Root .agents/skills](.agents/skills) | Reusable execution procedures |
| [todos.md](todos.md) | Simple nontechnical backlog, added to only on explicit user request |
| [.codex/config.toml](.codex/config.toml) | Project MCP startup and connection definitions |
| [.mcp.json](.mcp.json) and `.claude/skills/` aliases | Claude Code MCP connections and discovery of canonical skills |
| Scripts, test suites, and [.github/workflows](.github/workflows) | Executable checks and automation |

Start sessions at the monorepo root. Follow [documentation and helper placement](AGENTS.md#documentation-and-helper-placement) for the maintained layout and its exceptions. Route app instructions to the owning guide. Root skills are also discoverable from app subdirectories. Personal/plugin skills and credentials are outside the maintained repository harness. Codex and Claude Code share rules, procedures, tasks, and verification; only discovery and tool connection configuration belong to the client.

## Rules and skills

Rules describe constraints that apply whenever an area is edited: module boundaries, generated-file ownership, product language, and authorization. Keep them in the owning guide. Skills describe reusable jobs such as refinement, implementation, verification, simulator launch, or deployment. A skill links to rules rather than copying them. Metadata under `agents/` does not create worker agents.

Browse the [skills overview](docs/shared/skills.md) for every repository skill and its community source. All repository skills have one canonical home under root `.agents/skills/`:

- Custom workflows use `lg-` names, with platform prefixes when relevant.
- Claude Code's `.claude/skills/<name>` entries are directory symlinks to the same-named canonical skills. Preserve these aliases when adding, removing, or renaming skills; community updates replace canonical content and keep aliases intact. See [Claude skill discovery](https://code.claude.com/docs/en/skills).
- Community skills are installed through [skills.sh](https://skills.sh/) and recorded in the tracked [skills-lock.json](skills-lock.json). Preserve upstream contents; keep repository-specific rules in our guides.
- Use [lg-maintain-harness](.agents/skills/lg-maintain-harness/SKILL.md) to improve custom workflows, policy, rules, and documentation, including audits against source. Community installation updates follow [their separate procedure](docs/shared/skills.md#update-community-skills).

## Task and verification flow

The [task workflow](AGENTS.md#delivery-workflow) owns full-scope grilling and agreement → build and verification → self-review and independent review → finding resolution → handoff and the [human review handoff](AGENTS.md#prepare-the-human-review). Root `todos.md` holds short, nontechnical items only. Add items only on explicit user request. `lg-deliver` coordinates delivery; `lg-plan` settles material requirements and architecture up front. Keep plans and evidence in the conversation without creating task files. After agreement, continue across phase boundaries through review and fixes to completion.

Use the owning platform's tools and validation: [iOS workflows](docs/ios/development.md#setup-and-tooling), [backend validation](backend/AGENTS.md#backend-commands-and-validation), [web validation](web/AGENTS.md#web-commands-and-validation), and [browser access](AGENTS.md#browser-access). The [API guide](AGENTS.md#api-contract) owns backend-to-generated-client flow. The [runtime guide](AGENTS.md#runtime-and-deployment) owns service commands, including the volume reset performed by `scripts/shared/reset-and-start-local-stack.sh`.

Implementation finishes with relevant automated tests, required lint/build checks, applicable agent review, and resolution of material findings. Human manual testing follows handoff and does not block task completion. Runtime and visual procedures apply when explicitly requested.

Report actual evidence: build, tests, app launch, service health, and a live user journey establish different things. Documentation-only changes need link, metadata, source-claim, and routing checks; they do not require an app build. Substantive changes require a fresh read-only reviewer agent or session under the shared workflow; trivial edits may use self-review.

## Hooks and automation

The checked-in configuration enables no agent lifecycle/edit hooks. CI and explicit helpers are separate:

| Mechanism | Behavior and source |
| --- | --- |
| Local Swift lint | [Changed-line lint](scripts/ios/lint-swift-changes.py) runs explicitly or in CI |
| GitHub Actions | [CI/CD](AGENTS.md#cicd) owns builds, tests, artifact checks, and release automation; release workflows can publish images, deploy, and push tags |
| Community skills | [Weekly/manual workflow](.github/workflows/update-community-skills.yml) refreshes upstream skills and commits validated results directly to `main`; independent of task execution |
| Xcode Cloud | [Post-clone](ios-app/CI_scripts/ci_post_clone.sh) sets build preferences and can push a version tag when `GITHUB_WRITE_PAT` is configured; [pre-build](ios-app/CI_scripts/ci_pre_xcodebuild.sh) writes local build secrets. Both skip work when `TEST_RUNNER_CI=TRUE` |

Local Git hooks, client settings, and remotely managed Xcode Cloud workflows can add behavior outside checked-in configuration. Inspect them when relevant; a helper stored under `hooks/` is not evidence that an event invokes it.

## MCP and client boundary

The [Codex configuration](.codex/config.toml) and [Claude Code configuration](.mcp.json) connect native Xcode (`xcrun mcpbridge`), Coolify, Maestro, shadcn, and GoDaddy. Keep their server commands, arguments, URLs, and authentication behavior aligned when changing a connection. These small native configurations are maintained explicitly rather than generated. The [compatibility configuration](.agents/config.toml) repeats some connections for other clients; Claude Code uses `.mcp.json`, not this TOML file. App-local agent configuration folders are not maintained; shared skills and client connections live at the repository root. Inspect tools actually exposed in the session rather than assuming every client merges these files or every configured server is connected.

Connections do not install CLIs, grant account access, or schedule work. The Coolify [auth helper](scripts/shared/print-coolify-auth-headers.py) reads `COOLIFY_MCP_TOKEN` from the ignored root `.env`; keep real credentials outside Git and restrict that file with `chmod 600 .env`. [iOS harness setup](docs/ios/development.md#apple-skills-setup) owns Xcode connection details and local Apple skill export. `scripts/shared/update-xcode-skills.py` exports the selected Xcode's guidance directly into `.agents/skills/` and creates local Claude discovery aliases. Apple content, its `.apple-skills.json` inventory, and its aliases are ignored by Git. Apple skills need no plugin marketplace configuration; MCP connections remain client-specific.

## Claude Code setup

Start a current Claude Code version at the monorepo root and load [AGENTS.md](AGENTS.md) directly. It owns shared policy and records that both Codex and Claude Code are active. A separate `CLAUDE.md` is unnecessary. If instructions are absent, check `/config` → Project instructions; an ancestor `CLAUDE.md` can take precedence, so select `claude-md-and-agents-md` when needed. See [Claude instruction loading](https://code.claude.com/docs/en/memory#agentsmd). Read the nearest app `AGENTS.md` before editing its subtree, as root policy requires. Keep client-specific connection files and skill discovery working for both clients.

Verify a new session:

1. Run `/context all` and confirm the repository instructions load. Before editing an app, confirm its `AGENTS.md` is read.
2. Open the `/` command picker and confirm `/lg-deliver` and `/lg-plan` is available from the repository skill aliases. Read a skill through its canonical `.agents/skills/` path when following supporting links or editing it.
3. Run `/mcp` to inspect project server definitions and approve the intended connections. `claude mcp list` reports pending approval separately from connection failures. Keep personal approvals in the ignored `.claude/settings.local.json`; the shared config grants no tool permissions.
4. For iOS work, call `XcodeListWorkspaces` and match the current checkout before following the shared simulator workflow. Connection health alone does not verify a build, launch, or login.

Claude uses `headersHelper` for the same Coolify helper that Codex names `http_headers_helper`. No credential belongs in `.mcp.json` or tracked Claude settings. Follow [Claude MCP authentication](https://code.claude.com/docs/en/mcp#use-dynamic-headers-for-custom-authentication) for client diagnostics.

The [local iOS skill](.agents/skills/lg-ios-run-local/SKILL.md) owns backend preparation and employee launch on one simulator in both clients. `login-only` uses an already running backend; explicit `account <account-id>` supports an existing test account. Data is preserved unless a reset is explicitly requested. Personal Codex plugins and execution wrappers are not automatically available in Claude.

When repository-owned guidance files move, repair callers and indexes. Add executable hooks only for concrete failures they can reliably detect.
