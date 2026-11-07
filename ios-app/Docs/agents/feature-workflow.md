# iOS feature development

Start at the monorepo root. The shared [task workflow](../../../docs/agents/task-workflow.md) connects product decisions, implementation, and verification across platforms. This page adds iOS-specific guidance. Use the shared draft → refinement → implementation lifecycle. A clear direct implementation request still gets a proportionate task file before code changes, without an extra approval ceremony.

| Task | Entry point | Result |
| --- | --- | --- |
| Capture upcoming work or write a task plan | [$lg-create-task](../../../.agents/skills/lg-create-task/SKILL.md) | One task file with the canonical structure and status |
| Shape an idea or stress-test a plan | [$lg-refine](../../../.agents/skills/lg-refine/SKILL.md) | Code-grounded plan saved to `tasks/ios-<slug>.md`, ready for another agent |
| Implement a feature or fix | [$lg-implement](../../../.agents/skills/lg-implement/SKILL.md) | Implemented slice; the same task file records progress, acceptance, verification, and handoff |
| Write/refactor Swift | [Swift guidance](swift.md) | LetsGrow architecture, UI, localization, and testing conventions applied |
| Check behavior or reproduce steps | [$lg-verify](../../../.agents/skills/lg-verify/SKILL.md) | Separate build, test, lint, login, UI, and visual evidence |
| Review code or a diff | [$lg-review](../../../.agents/skills/lg-review/SKILL.md) | Ranked findings grounded in a concrete failure path |
| Find an unknown bug cause | [$lg-investigate](../../../.agents/skills/lg-investigate/SKILL.md) | Evidence, reproduction, cause/confidence, and a regression scenario |

These are agent prompts, not shell commands. Natural-language requests work too. Existing launch, login, screenshot, notification, and API-sync skills continue to own their procedures; see [shared iOS workflows](../../../docs/agents/ios-workflows.md) and [simulator guidance](simulator.md).

Task structure, readiness, phases, completion, and handoff are owned by [create-task](../../../.agents/skills/lg-create-task/SKILL.md). Keep iOS progress/evidence in the same root task file; put enduring knowledge in its owning guide.

## Choose verification by the change

Use the smallest combination that can detect the actual regression. The [simulator workflow](../../../.agents/skills/lg-ios-run-simulator/SKILL.md) owns execution and result reporting; [testing](testing.md) owns lint and test policy. UI changes retain the [full-catalog visual review](visual-review.md) requirement.

| Change | Behavioral evidence | Runtime/data needs |
| --- | --- | --- |
| Reducer or validation | Relevant TestStore tests: state transitions, effects, rejected invalid/duplicate actions, failure recovery | Injected dependencies; no live backend required for unit tests |
| Domain mapper or API/cache mutation | Relevant mapper/adapter/cache tests, then affected live path | Localhost and existing fixture unless preparation requested |
| SwiftUI layout, components, or copy | Build, complete screenshot catalog/review; interact with changed controls and native presentation | Stable preview fixtures plus a live simulator; check affected language/long-content layouts |
| Auth, role, root or navigation state | Reducer tests plus owner and anonymous entry/transition paths that changed | Localhost; two simulators when simultaneous roles are needed |
| Session/PIN/feedback journey | Relevant reducers plus manager creates/selects session → anonymous enters PIN/submits → manager sees result | Two local simulators, reachable session, explicitly requested product mutations |
| Notification or deep-link routing | Parsing/routing tests plus the affected native path; notification runner when requested | Follow the [notification skill](../../../.agents/skills/lg-ios-test-notifications/SKILL.md); do not equate a routing test with delivered push |
| Contract changes | Regenerate clients; relevant backend, mapper and feature tests; affected live path | Backend guidance and [API generation](../../../docs/agents/api-contract.md) |
| Documentation/skills only | Skill validation, local link checks, scenario walkthroughs for routing and permissions | No app build, backend reset, or simulator launch needed |

A build proves compilation. A discovered and passing test proves the behavior it asserts. A fresh snapshot proves its fixture layout. A successful live journey proves the observed path on the selected backend/account. Record each separately.

## Environment and fixture selection

| Intent | Prompt | Data effect |
| --- | --- | --- |
| Run with existing login/data | `$lg-ios-localhost` | Preserve data |
| Work as sample owner | `$lg-ios-localhost manager` | Login only; fixture must already exist |
| Prepare owner sample data | `$lg-ios-localhost manager seed-manager` | Replace sample manager fixture and its associated data |
| Owner and anonymous together | `$lg-ios-localhost both` | Preserve data; verify roles on two simulators |
| Fresh sample data for both roles | `$lg-ios-localhost both seed-manager` | Replace manager fixture; anonymous identity is preserved when already anonymous |
| Deliberately reset all local data | `$lg-ios-localhost both reset-db` | Delete all local database data and recreate manager fixture |
| Run deployed API | `$lg-ios-production` | Production Release launch with normal login; real production data |

The [localhost skill](../../../.agents/skills/lg-ios-localhost/SKILL.md) owns exact preparation/reset semantics and loopback restrictions. A request for seeded data selects fixture preparation; it does not imply `reset-db`. A launch request does not imply a feedback submission. Prefer deterministic injected test data for unusual errors, times, and edge cases rather than building new live fixture endpoints solely for a reducer test.

## Example requests

```text
$lg-refine Let owners duplicate an activity's question setup.
# Refinement saves tasks/ios-duplicate-activity.md.
$lg-implement tasks/ios-duplicate-activity.md
$lg-ios-localhost both seed-manager
$lg-verify On localhost, create a session as manager, submit feedback as anonymous,
  and check that the manager sees the new response.
$lg-ios-production
$lg-review Review the current changes for shared-state and navigation regressions.
$lg-investigate Why does opening a feedback notification show the wrong session?
```
