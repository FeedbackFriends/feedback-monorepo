# Agent Tooling

This repository keeps project guidance, skills, and MCP server definitions in
version control. Credentials and user-level MCP connections stay outside Git.

## Harness and skills

- Root [`AGENTS.md`](../AGENTS.md) defines repository-wide boundaries and
  conventions.
- App-specific guidance lives in [`web/AGENTS.md`](../web/AGENTS.md),
  [`backend/AGENTS.md`](../backend/AGENTS.md), and
  [`ios-app/AGENTS.md`](../ios-app/AGENTS.md).
- For iOS setup and verification, read the [iOS harness overview](../ios-app/Docs/agent-harness.md). The root instructions explicitly route to its nested simulator skill even when that skill is not in the initial skill picker.
- Project skills are stored under [`.agents/skills/`](../.agents/skills/):
  `coolify-operations`, `letsgrow-architecture`, `letsgrow-commit-and-push`,
  `letsgrow-domain`, and `ux-designer`.
- The root `letsgrow-ios-localhost` and `letsgrow-ios-production` skills prepare the chosen backend and build/launch the matching simulator scheme through Xcode MCP. See [build/run workflows](../ios-app/Docs/agent-harness.md#build-and-run-workflows).
- The `skills-lock.json` files are local installer state and are ignored by
  Git. The skill instructions themselves are committed in the repository.

For browser work, follow the [browser access guidance](agents/browser-access.md).

## MCP servers

Codex reads this repository's MCP definitions from
[`.codex/config.toml`](../.codex/config.toml):

- Coolify uses Streamable HTTP; its header helper reads `COOLIFY_MCP_TOKEN`
  from the local root `.env` file.
- Maestro runs the local `maestro mcp` command and requires the Maestro CLI.
- Xcode runs Apple's native `xcrun mcpbridge`; see the iOS harness overview for setup and a connection check.
- shadcn runs from `web/` through `npx`.
- GoDaddy uses its hosted MCP endpoint and may require account authentication
  in the MCP client.

The adjacent [`.agents/config.toml`](../.agents/config.toml) keeps the same
Xcode, Maestro, shadcn, and GoDaddy definitions for harnesses that read that format.
Codex uses `.codex/config.toml`.

The root [`.env.example`](../.env.example) contains an empty placeholder for
`COOLIFY_MCP_TOKEN`. Put the real token only in `.env`, keep `.env` ignored, and
restrict its permissions with `chmod 600 .env`. Never commit or paste token
values into documentation.

MCP definitions describe how to connect; they do not install the server
software or grant account access. Local CLIs, Codex authentication, and any
required account permissions must be set up on each machine. Personal or
organization-level connectors should remain in the user's Codex configuration
unless the whole team needs them.
