# Documentation

Maintained documentation lives here: `shared/`, `ios/`, `backend/`, and `web/`.
Helper scripts live under root `scripts/`: [shared helpers](../scripts/shared) and [iOS helpers](../scripts/ios).
App READMEs and `AGENTS.md` files remain entry points beside their code.
Use this index to find the maintained source rather than copying it.

| Topic | Start here |
| --- | --- |
| Product, audience, UX, marketing, and terminology | [Product guidance](shared/product/lets-grow-strategi-teamtrivsel.md) |
| Monorepo architecture and contract flow | [Architecture](shared/architecture.md) |
| Agent harness, skills, tools, hooks, and layout | [Harness architecture](shared/agent-tooling.md) |
| Available skills and community sources | [Skills overview](shared/skills.md) |
| Task lifecycle and implementation | [Task workflow](shared/agents/task-workflow.md), [unfinished tasks](../todos.md) |
| Architectural implementation handoff | [Human review](../.agents/skills/lg-implement/SKILL.md#prepare-the-human-review) |
| Repository ownership and shared conventions | [Repository scope](shared/agents/repository-scope.md) |
| Shared API contract and generated clients | [API contract](shared/agents/api-contract.md) |
| Local services and production | [Runtime and deployment](shared/agents/runtime-and-deployment.md) |
| CI and releases | [CI/CD](shared/agents/ci-cd.md) |
| Browser access | [Browser policy](shared/agents/browser-access.md) |
| Web | [Policy, architecture, and guide map](../web/AGENTS.md) |
| Backend | [App overview](../backend/README.md), [policy and guide map](../backend/AGENTS.md) |
| iOS | [App overview](../ios-app/README.md), [policy and guide map](../ios-app/AGENTS.md), [iOS harness](ios/agent-harness.md) |

Repository-wide instructions start at [AGENTS.md](../AGENTS.md). LetsGrow workflow
skills live in [root .agents/skills](../.agents/skills); rules and durable knowledge
live in the guides above. Personal/plugin skills and credentials are managed
outside this repository.
