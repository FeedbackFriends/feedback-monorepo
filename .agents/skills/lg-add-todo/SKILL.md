---
name: lg-add-todo
description: Add a simple nontechnical item to root todos.md only when the user explicitly asks to capture a todo.
---

# Capture a LetsGrow todo

Read [root policy](../../../AGENTS.md) and the [task workflow](../../../docs/shared/agents/task-workflow.md).

1. Add an item only when the user explicitly asks to capture a todo. Implementation, investigation, refinement, and cleanup requests do not implicitly add backlog items.
2. Read root [todos.md](../../../todos.md) and reuse a matching item rather than duplicating it. The list is prioritized from highest to lowest. Preserve the existing order unless reprioritization is requested; append new items unless the user specifies their priority.
3. Write one plain Markdown bullet without a checkbox, with one or two short lines describing the problem or desired outcome in plain language. Keep technical details, acceptance criteria, status metadata, and implementation plans in the conversation.
4. Report the added or updated item. Capture does not start refinement or implementation. Use [lg-plan](../lg-plan/SKILL.md) when the user later wants to grill the idea.
