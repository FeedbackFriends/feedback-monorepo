# iOS workflows

Read [iOS app guidance](../../../ios-app/AGENTS.md) before iOS work, including tasks started from the monorepo root.

- For building the local backend and launching iOS together, use the [localhost workflow skill](../../../.agents/skills/lg-ios-run-local/SKILL.md).
  Use `$lg-ios-run-local both` for manager and anonymous apps on two simulators. Data is preserved by default; `seed-manager` prepares the sample fixture, and `reset-db` explicitly resets the entire local database.
- For an iOS simulator build against deployed production, use the [production workflow skill](../../../.agents/skills/lg-ios-run-production/SKILL.md).
- For all iOS build, test, launch, or verification work, read the [simulator guide](../../ios/agents/simulator.md).

For refinement, implementation, Swift conventions, verification, review, or bug investigation, use the root-discoverable skills in [iOS feature development](../../ios/agents/feature-workflow.md). The [refinement skill](../../../.agents/skills/lg-refine/SKILL.md) grills requirements and architecture in the conversation, then implementation follows the agreed plan. Root `todos.md` stays a simple nontechnical list. The guide also maps each kind of change to its verification and environment needs.

Setup is documented in the [iOS harness overview](../../ios/agent-harness.md).
