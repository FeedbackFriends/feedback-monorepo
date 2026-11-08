---
name: lg-web-style
description: Implement LetsGrow web UI with existing Tailwind tokens and shared components. Use for styling, responsive layouts, or design-token changes.
---

# Implement web styling

Read [web policy](../../../web/AGENTS.md) and [UI guidance](../../../docs/web/agents/ui.md). Inspect the affected component, `web/components.json`, and `web/src/app/globals.css` before editing.

1. Reuse the existing shadcn primitive or product component and semantic tokens. Compose layout, spacing, responsive behavior, and states with Tailwind utilities. Keep feature behavior outside UI primitives.
2. Extend existing CSS theme tokens only when the design needs a shared value. Keep global CSS limited to tokens and actual base/shared styles; abstract repeated compositions or named UI roles when useful. Inspect marketing consumers before changing shared primitives.
3. Verify the affected responsive layouts and loading/disabled/error states using [web validation](../../../docs/web/agents/validation.md). Report actual checks and remaining gaps.
