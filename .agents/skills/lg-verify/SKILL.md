---
name: lg-verify
description: Verify a LetsGrow task or reproduce specified behavior across iOS, backend, web, or tooling using the owning platform's tests, runtime checks, and evidence. Honors narrower build-only, launch-only, or test-only requests.
---

# Verify a LetsGrow task

Read [root policy](../../../AGENTS.md), the task's acceptance/verification/handoff sections, and the [platform verification map](../../../docs/agents/task-workflow.md#platform-guidance-and-verification). Read each affected app's guidance. Extract actions and observable outcomes; separate reported symptoms from expected behavior. Honor a narrower build/test/launch request without adding an unrelated full workflow.

## Select checks by the changed behavior

- **iOS:** follow [iOS verification](references/ios.md) for native Xcode operations, local/production account and data selection, live journeys, and visual review.
- **Backend:** follow [backend validation](../../../backend/docs/agents/validation.md). From `backend/`, run the affected module tests, such as `./gradlew :api:test` or `./gradlew :persistence:test`; persistence/migration changes also need affected API coverage. Use existing JUnit/MockMvc/integration helpers. An HTTP journey must check response behavior and persisted effects where relevant, rather than treating health as proof of the feature.
- **Web:** follow [web validation](../../../web/docs/agents/validation.md), including lint, relevant builds/Playwright journeys, and responsive inspection for visual changes.
- **Contract:** run the root API generation script and inspect the generated diff, then verify affected producer and consumer behavior.
- **Tooling/docs:** validate changed helper behavior or skill metadata/links and task routing as relevant. Documentation-only changes do not need an app build or service startup.

Prefer deterministic injected/test data for unusual failures, times, and concurrency cases. Reuse existing local data unless fixture preparation was requested. Read [runtime guidance](../../../docs/agents/runtime-and-deployment.md) before starting services; root `scripts/run` resets Compose volumes and is not a harmless health check. A verification plan does not grant permission for resets, deployment, or unspecified production mutations.

For a cross-platform task, verify both sides of the boundary and the affected integration journey. A passing backend test does not establish iOS UI correctness, and a passing snapshot does not establish API persistence.

## Report evidence and update the task

Report actual command/tool, environment, relevant accounts/data operations, counts/outcomes, and artifacts. Separate compilation, tests, launch/health, authentication, live behavior, and visual evidence. Mark omitted/blocked checks with a reason; stale logs/screenshots are not fresh verification.

When a task file was supplied, record results and remaining checks in its Handoff and update acceptance checkboxes only when proven. Do not mark a task done while required checks remain. Fix regressions when verification is part of an authorized implementation; standalone verification/reproduction reports findings without expanding into a fix.
