---
name: tailwind-nextjs-expert
description: Expert guidance for Tailwind + Next.js UI implementation and design-system hygiene. Use when creating or updating UI, when asked for Tailwind best practices, or when globals.css, tailwind.config.ts, or design tokens are mentioned. Enforce semantic tokens, minimal globals, and incremental design-system evolution.
---

# Tailwind Nextjs Expert

## Overview

Implement UI with Tailwind and semantic tokens while keeping the design system simple and incremental.

## Core Rules

- Do not hard-code design decisions; use Tailwind utilities and CSS variables.
- Keep things simple; add to the design system only when needed.
- Let the design system evolve naturally as the codebase grows.

## Mental Model

- Design tokens define values.
- Tailwind utilities apply those values.
- Components express meaning.

## Where Things Live

### globals.css

- Keep design tokens as CSS variables.
- Keep base defaults and true system styles only.

### tailwind.config.ts

- Expose tokens as semantic utilities (`primary`, `foreground`, `muted`, `brand.*`).
- Define type scale, spacing, and animation scales.

### components/

- Use semantic utilities, never raw values.
- Use Tailwind for layout, spacing, responsive behavior, and states.

## When to Use Tailwind Directly

- Layout and structure (flex/grid/alignment).
- Spacing and sizing.
- Responsive behavior.
- Interaction states.
- One-off visual adjustments.

## When to Abstract

- Create a reusable class or component only for repetition or a named UI role.
- Avoid abstracting one-offs.

## Naming & Typography

- Prefer semantic names over visual names.
- Use the named type scale; avoid ad-hoc font sizes.

## Color Usage

- Use semantic color utilities only.
- Add new colors as tokens first.

## Global CSS Rules

- Keep base styles minimal.
- Avoid dumping shared patterns that are not reused.
- Rely on `globals.css` for base styles on native elements (e.g., `p`, `h1`–`h6`, `a`, `button`) when available.
- If those elements already have global styling, omit typography/color classes and only add utility classes for layout or spacing.
example
```jsx
<h2>Title</h2>
<p className="max-w-xl">…</p>
```

## Final Check

If removing Tailwind breaks layout, that is fine. If removing Tailwind breaks meaning, the abstraction is wrong.
