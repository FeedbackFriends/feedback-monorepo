# iOS verification

Read [iOS policy](../../../../ios-app/AGENTS.md), the [verification matrix](../../../../ios-app/Docs/agents/feature-workflow.md#choose-verification-by-the-change), and the [simulator guide](../../../../ios-app/Docs/agents/simulator.md). It owns LetsGrow-specific execution rules and result reporting; loaded Apple guidance owns native tool procedures.

## Environment and data

- Reuse an existing local stack/data; use the [login skill](../../lg-ios-login/SKILL.md) if authentication is needed.
- For backend preparation/account modes, use [localhost](../../lg-ios-localhost/SKILL.md). `manager`, `anonymous`, and `both` select access; `seed-manager` explicitly replaces the sample manager fixture. A request for seeded sample data authorizes that preparation, not a whole-database reset.
- For an explicit production request, use [production](../../lg-ios-production/SKILL.md). Tests still use Localhost. Do not use local fixture/auth operations in production; product mutations must be within the user's requested action.

State the environment, accounts, and fixture operations. If existing data cannot reach the required state, report what is missing rather than silently resetting data or inventing a passing scenario.

## Live behavior and layout

Pair each action with an observable expected result. Base native interaction on the latest hierarchy and inspect presentation/screenshots when needed. For async or stale-state failures, preserve action order and inspect focused logs rather than repeatedly tapping or sleeping.

A manager/anonymous feedback journey generally needs two simulators and explicitly requested local session/feedback mutations. Launching both accounts alone needs role verification, not feedback submission.

UI changes follow [visual review](../../../../ios-app/Docs/agents/visual-review.md) and the [screenshots skill](../../lg-ios-screenshots/SKILL.md), including the full catalog and preservation of approved baselines until acceptance. A snapshot or preview proves fixture layout, not live authentication/navigation/API behavior.

Report build, tests, Swift lint, launch, login, interaction, visual results, and blockers separately using the simulator guide’s reporting rules. Keep a successfully launched app available for manual testing and close interaction sessions as the guide requires.
