# Agent Tooling

This repository keeps project guidance, skills, and MCP server definitions in
version control. Credentials and user-level MCP connections stay outside Git.

## Harness and skills

- Root [`AGENTS.md`](../AGENTS.md) defines repository-wide boundaries and
  conventions.
- App-specific guidance lives in [`web/AGENTS.md`](../web/AGENTS.md),
  [`backend/AGENTS.md`](../backend/AGENTS.md), and
  [`ios-app/AGENTS.md`](../ios-app/AGENTS.md).
- Project skills are stored under [`.agents/skills/`](../.agents/skills/):
  `coolify-operations`, `letsgrow-architecture`, `letsgrow-commit-and-push`,
  `letsgrow-domain`, and `ux-designer`.
- The `skills-lock.json` files are local installer state and are ignored by
  Git. The skill instructions themselves are committed in the repository.

## MCP servers

Codex reads this repository's MCP definitions from
[`.codex/config.toml`](../.codex/config.toml):

- Coolify uses Streamable HTTP; its header helper reads `COOLIFY_MCP_TOKEN`
  from the local root `.env` file.
- Maestro runs the local `maestro mcp` command and requires the Maestro CLI.
- shadcn runs from `web/` through `npx`.
- GoDaddy uses its hosted MCP endpoint and may require account authentication
  in the MCP client.

The adjacent [`.agents/config.toml`](../.agents/config.toml) keeps the same
Maestro, shadcn, and GoDaddy definitions for harnesses that read that format.
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
