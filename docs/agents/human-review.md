# Human review after implementation

The human review should assess architectural decisions. Implementation follows existing coding standards and patterns by default; the agent owns applying those conventions, checking correctness, and running relevant verification before handoff. Agent code review continues to look for bugs and contract breaks.

During implementation or a phase handoff with remaining work, maintain `## Human review` in the task file and include a concise version in the response with a link to that file. On full task completion, include the human review and actual verification results directly in the final response, then remove the task file under the [completion procedure](../../.agents/skills/lg-create-task/SKILL.md#lifecycle-and-handoff). Link to existing source/docs/artifacts rather than the removed task. Update it at a handoff or blockage with the implemented scope and remaining uncertainty. Describe the final change for someone who has not seen the conversation, grouping by responsibility or app concept rather than listing edits chronologically.

## What the section contains

- **Change and flow:** the concrete behavior/result and how the request, action, or data moves through the affected components. Include the previous and resulting behavior when that clarifies the decision.
- **Architectural decisions:** who owns the behavior/state/data, module and dependency boundaries, public/API/persistence contracts, and compatibility or rollout implications that changed. For each consequential choice, state the decision, why it fits, the meaningful tradeoff or plausible alternative, and links to the source that makes it reviewable. Identify decisions newly made during implementation versus choices already settled in the plan.
- **Reading path:** a short ordered route through the relevant source symbols/files, explaining what each shows. Use precise file/line links in the final response and portable relative links in the task. Include a test when it demonstrates an important boundary or invariant. Scale the reading path to the change rather than enumerating every touched file.
- **Verification and limits:** summarize actual evidence, material risks, and remaining checks, linking to existing verification artifacts; for unfinished work, the task may hold detailed results. Make clear what still needs human judgement.

Use short paragraphs or a small table when that makes decisions easier to compare. Scale detail to architectural significance. For a routine change with no architectural decision, say that the existing architecture/pattern is retained, identify it, and give the relevant reading path and verification. Do not invent alternatives or decision requests just to fill the section.

Call out any deliberate departure from existing coding standards with its reason and impact. Resolve ordinary convention violations before handoff; do not present them as choices for the human to settle. Materially unresolved product or architectural choices belong in the task's open questions, rather than being hidden in a list of implementation details.

The section records the author's explanation and evidence. It is not evidence that human review occurred and does not add a separate approval gate to an already authorized implementation.
