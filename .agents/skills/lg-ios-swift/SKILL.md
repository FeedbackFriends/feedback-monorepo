---
name: lg-ios-swift
description: Write or refactor Swift in LetsGrow's SwiftUI/TCA iOS app using its Domain/Adapters boundaries, shared Bootstrap, design system, localization, and test patterns. Use for code changes rather than generic Swift questions.
---

# Write Swift for LetsGrow

Read [iOS policy](../../../ios-app/AGENTS.md) and [Swift implementation guidance](../../../ios-app/Docs/agents/swift.md) before writing Swift. Inspect the owning module and nearest relevant test; repository source and resolved dependency versions take precedence over generic examples.

Load the relevant guidance:

- Reducers, services, shared state, module boundaries: [architecture](../../../ios-app/Docs/agents/architecture.md).
- SwiftUI: [UI conventions](../../../ios-app/Docs/agents/ui.md) and the [design-system skill](../../../ios-app/.agents/skills/lg-ios-design-system/SKILL.md), including its current component inventory.
- Visible copy, dates, counts, and errors: [product language](../../../ios-app/Docs/agents/product-language.md) and the linked localization workflow.
- API behavior: [API integration](../../../ios-app/Docs/agents/api-contract.md); use the [sync skill](../../../ios-app/.agents/skills/lg-ios-sync-openapi/SKILL.md) when handwritten Domain/adapters need reconciliation with generated APIs.
- Tests/lint: [testing](../../../ios-app/Docs/agents/testing.md). New test targets must also be included in the active test plan and verified through discovery.

Use Apple's current documentation/guidance exposed by native Xcode MCP for unfamiliar or version-sensitive APIs. If available and relevant, use the installed SwiftUI or Swift concurrency skills for deeper platform guidance; they supplement LetsGrow's architecture. Do not copy tool-specific rules or Apple skill bundles into this repository.

For code changes, finish through [implementation verification](../lg-verify/SKILL.md), scoped to the request. A request to explain existing Swift is read-only and does not need a build or launch.
