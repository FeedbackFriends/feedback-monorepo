# iOS feature development

Start at the monorepo root. The shared [task workflow](../../shared/agents/task-workflow.md) connects product decisions, implementation, and verification across platforms. This page adds iOS-specific guidance. Use the shared todo → grill → implementation flow. Keep detailed plans and evidence in the conversation; add todos only when explicitly requested.

| Task | Entry point | Result |
| --- | --- | --- |
| Capture a requested todo | [$lg-add-todo](../../../.agents/skills/lg-add-todo/SKILL.md) | A short, nontechnical item in root `todos.md` |
| Shape an idea or stress-test a plan | [$lg-refine](../../../.agents/skills/lg-refine/SKILL.md) | Requirements and architecture grilled with the user; an agreed plan in the conversation |
| Implement a feature or fix | [$lg-implement](../../../.agents/skills/lg-implement/SKILL.md) | Implemented slice with automated verification and a conversation handoff |
| Write/refactor Swift | [Swift guidance](swift.md) | LetsGrow architecture, UI, localization, and testing conventions applied |
| Review code or a diff | [$lg-review](../../../.agents/skills/lg-review/SKILL.md) | Ranked findings grounded in a concrete failure path |

These are agent prompts, not shell commands. Natural-language requests work too. Existing launch, login, screenshot, notification, and API-sync skills continue to own their procedures; see [iOS workflows](../agent-harness.md#workflows) and [simulator guidance](simulator.md).

The [shared task workflow](../../shared/agents/task-workflow.md) owns backlog simplicity, refinement, and completion. Keep iOS plans and evidence in the conversation; put enduring knowledge in its owning guide.

## Choose verification by the change

Use the smallest combination that can detect the actual regression. The [simulator guide](simulator.md) owns project-specific execution rules and result reporting; [testing](testing.md) owns lint and test policy. Implementation finishes with relevant automated tests, build and lint checks. Human manual testing and [visual review](visual-review.md) follow handoff; the runtime paths below are guidance for explicitly requested testing, not implementation completion gates.

| Change | Behavioral evidence | Runtime/data needs |
| --- | --- | --- |
| Reducer or validation | Relevant TestStore tests: state transitions, effects, rejected invalid/duplicate actions, failure recovery | Injected dependencies; no live backend required for unit tests |
| Domain mapper or API/cache mutation | Relevant mapper/adapter/cache tests, then affected live path | Localhost and existing fixture unless preparation requested |
| SwiftUI layout, components, or copy | Build, complete screenshot catalog/review; interact with changed controls and native presentation | Stable preview fixtures plus a live simulator; check affected language/long-content layouts |
| Auth, role, root or navigation state | Reducer tests plus owner and anonymous entry/transition paths that changed | Localhost; two simulators when simultaneous roles are needed |
| Session/PIN/feedback journey | Relevant reducers plus manager creates/selects session → anonymous enters PIN/submits → manager sees result | Two local simulators, reachable session, explicitly requested product mutations |
| Notification or deep-link routing | Parsing/routing tests plus the affected native path; notification runner when requested | Follow the [notification skill](../../../.agents/skills/lg-ios-test-notifications/SKILL.md); do not equate a routing test with delivered push |
| Contract changes | Regenerate clients; relevant backend, mapper and feature tests; affected live path | Backend guidance and [API generation](../../shared/agents/api-contract.md) |
| Documentation/skills only | Skill validation, local link checks, scenario walkthroughs for routing and permissions | No app build, backend reset, or simulator launch needed |

A build proves compilation. A discovered and passing test proves the behavior it asserts. A fresh snapshot proves its fixture layout. A successful live journey proves the observed path on the selected backend/account. Record each separately.

## Environment and fixture selection

| Intent | Prompt | Data effect |
| --- | --- | --- |
| Run with existing login/data | `$lg-ios-run-local` | Preserve data |
| Work as sample owner | `$lg-ios-run-local manager` | Login only; fixture must already exist |
| Prepare owner sample data | `$lg-ios-run-local manager seed-manager` | Replace sample manager fixture and its associated data |
| Owner and anonymous together | `$lg-ios-run-local both` | Preserve data; verify roles on two simulators |
| Fresh sample data for both roles | `$lg-ios-run-local both seed-manager` | Replace manager fixture; anonymous identity is preserved when already anonymous |
| Deliberately reset all local data | `$lg-ios-run-local both reset-db` | Delete all local database data and recreate manager fixture |
| Run deployed API | `$lg-ios-run-production` | Production Release launch with normal login; real production data |

The [localhost skill](../../../.agents/skills/lg-ios-run-local/SKILL.md) owns exact preparation/reset semantics and loopback restrictions. A request for seeded data selects fixture preparation; it does not imply `reset-db`. A launch request does not imply a feedback submission. Prefer deterministic injected test data for unusual errors, times, and edge cases rather than building new live fixture endpoints solely for a reducer test.

## Example requests

```text
$lg-refine Let owners duplicate an activity's question setup.
# Grill the requirements and architecture in the conversation.
$lg-implement Implement the agreed duplication behavior.
$lg-ios-run-local both seed-manager
$lg-ios-run-production
$lg-review Review the current changes for shared-state and navigation regressions.
```
