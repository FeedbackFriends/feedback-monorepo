---
name: lg-investigate
description: Investigate a LetsGrow bug across iOS, backend, web, or tooling by tracing reproduction steps, runtime evidence, state, API contracts, persistence, and integrations. Produces a grounded diagnosis and local follow-up task; implements a fix only when requested.
---

# Investigate a LetsGrow bug

Read [root policy](../../../AGENTS.md), the existing task/report, and each affected app's guidance. Determine the symptom, expected outcome, environment/version/revision, account access, relevant activity/session, and shortest reproduction. Look up facts before asking. Separate the reporter's observations from their explanation and label unknowns.

Trace the actual boundary chain: client entry/state/effect → service or adapter → API handler → business rule/persistence/integration as applicable. An iOS-only problem may end in its reducer; a scheduler failure may have no client. Use nearby tests and sibling callers to check whether the proposed cause explains the evidence.

Check stale state, auth/identity transitions, response/error mapping, cancellation, transaction boundaries, concurrent requests, job timing, time zones, and notification routing when relevant. Use native Xcode debugging for iOS; use the owning backend/web runtime and diagnostics guidance for those surfaces. Query available telemetry only when relevant and accessible; do not assume particular hosted logging services exist or expose credentials/private feedback in the report.

Use the owning platform guidance to reproduce the requested behavior, preferably locally when representative. Honor explicit production requests and their mutation limits. Do not reset data, deploy, or mutate live accounts beyond the requested reproduction. A non-reproduction has limits; it does not prove the report wrong.

Construct a timeline using real state/constants. Rank plausible causes by evidence/confidence and identify the check that would distinguish remaining hypotheses. Check whether the cause is in a client, backend/contract, environment, or expected behavior, and whether the examined revision already has a fix.

Deliver the reproduction result, evidence/timeline, likely cause and confidence, smallest recommended fix/regression scenario, and open questions. Investigation alone stops at diagnosis. For requested follow-up work, save those findings with [create-task](../lg-create-task/SKILL.md). If a fix is also authorized, pass the saved task to [implementation](../lg-implement/SKILL.md) once the cause is grounded. Task tracking never uses GitHub Issues or Projects.
