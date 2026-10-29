# AGENTS.md refactor review

## App indexes

- [Web](../../web/AGENTS.md): 83 → 16 lines; details in `web/docs/agents/`.
- [Backend](../../backend/AGENTS.md): 75 → 24 lines; details in `backend/docs/agents/`.
- [iOS](../../ios-app/AGENTS.md): existing working-tree guidance preserved in `ios-app/Docs/agents/`.

The app guides inherit repository-wide Git, generated-artifact, and browser rules from the root. App-specific commands and restrictions remain discoverable in their indexes.

## Skill indexes

The UX Designer, React Composition Patterns, and React Best Practices `AGENTS.md` files now route to relevant rules. Original compiled guidance is preserved in each skill's `references/complete-guide.md`; each `SKILL.md` routes to the index instead of requiring the full compilation.

## Contradiction requiring a decision

The iOS testing guidance says “Use Maestro for user-facing mobile journeys when appropriate,” while the simulator policy allows separate Maestro flows when explicitly requested. The user's choice is pending. Both statements remain intact; this refactor has not selected or changed the policy.

## Deletion and consolidation flags

- Removed “Build the actual product experience first, not a marketing placeholder”: context-dependent and too broad for every web task.
- Removed “Make text fit its container across mobile and desktop”: generic advice; the concrete mobile/desktop validation requirement remains.
- Removed “Keep logs useful and low-noise”: no measurable criterion; the specific ban on logging secrets, tokens, Firebase values, and Zoho credentials remains.
- Consolidated repeated `NEXT_PUBLIC_*` warnings in the web API/auth guide.
- Removed repeated scope paragraphs, retaining one-sentence app descriptions and the shared ownership guide.
- Kept inherited Git rules in the root; iOS-specific branch restrictions and current-branch push behavior remain in the iOS index.
- Removed lengthy skill compilations from automatic `AGENTS.md` loading, preserving them as optional references alongside the existing individual rule files.

## Directory structure

```text
web/docs/agents/
  architecture.md
  ui.md
  api-and-auth.md
  validation.md
backend/docs/agents/
  architecture.md
  api-contract.md
  persistence.md
  validation.md
  runtime.md
ios-app/Docs/agents/
  architecture.md
  api-contract.md
  ui.md
  simulator.md
  visual-review.md
  testing.md
  product-language.md
<skill>/references/
  complete-guide.md
  <category>.md       # React category indexes; UX links directly to rules/
```
