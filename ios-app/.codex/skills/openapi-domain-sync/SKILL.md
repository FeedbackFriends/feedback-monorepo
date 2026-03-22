---
name: openapi-domain-sync
description: Use when working in this iOS app's Swift OpenAPI layer to mirror generated API endpoints into the handwritten Domain `APIClient`, create or update handwritten Domain models for app-consumed OpenAPI schemas, and maintain `Adapters/APIClient/APIClientLive.swift` plus `APIClientMappers.swift` as the anti-corruption layer over `Modules/Sources/OpenAPI/GeneratedSources/Client.swift` and `Types.swift`.
---

# OpenAPI Domain Sync

Use this skill when the user wants to:

- add missing app-facing endpoints to `Modules/Sources/Domain/Services/ApiClient.swift`
- create or update handwritten domain model types based on generated OpenAPI schema types
- generate or maintain `Modules/Sources/Adapters/APIClient/APIClientMappers.swift`
- keep the app boundary aligned with `Modules/Sources/OpenAPI/GeneratedSources/Client.swift`

## Boundary Rules

- `Modules/Sources/OpenAPI/GeneratedSources/` is generated code only. Never hand-edit it.
- `Modules/Sources/Domain/` owns app-facing models, errors, and the handwritten `APIClient`.
- `Modules/Sources/Adapters/APIClient/` owns all translation between generated OpenAPI types and Domain types.
- Do not copy generated transport wrappers like `Operations.*`, status-code enums, request/response wrappers, or `APIProtocol` helper types into `Domain`.
- Interpret "put `Types.swift` in Domain" as: create handwritten Domain equivalents for the schema concepts the app actually consumes, not a literal 1:1 clone of every generated type.

## Files To Inspect First

- `Modules/Sources/OpenAPI/GeneratedSources/Client.swift`
- `Modules/Sources/OpenAPI/GeneratedSources/Types.swift`
- `Modules/Sources/Domain/Services/ApiClient.swift`
- `Modules/Sources/Adapters/APIClient/APIClientLive.swift`
- `Modules/Sources/Adapters/APIClient/APIClientMappers.swift`
- `Modules/Sources/Domain/Models/API/`
- `Modules/Sources/Domain/Models/`
- `Modules/Sources/Domain/Errors/`

## Quick Start

Run the inventory script first:

```bash
python3 .codex/skills/openapi-domain-sync/scripts/inventory_openapi_domain_sync.py
```

That script prints:

- generated endpoint names from `Client.swift`
- handwritten endpoint names from `Domain/Services/ApiClient.swift`
- missing or extra `APIClient` entries
- current handwritten Domain public types
- top-level generated schema names from `Types.swift`

## Workflow

1. Inventory the generated surface.
   - Start with the script.
   - Confirm which generated `Client` methods are missing from `Domain.APIClient`.

2. Decide the app-facing shape.
   - Keep a single `APIClient` dependency.
   - Add one handwritten closure per generated endpoint unless there is a deliberate reason to exclude it.
   - Prefer domain-friendly arguments and return values over generated request/response wrappers.

3. Model the consumed schema types in `Domain`.
   - Create or update handwritten `Domain` models only for schema concepts the app uses.
   - Preserve app semantics and naming rather than blindly copying backend DTO names.
   - Prefer `Modules/Sources/Domain/Models/API/` for schema-shaped handwritten models that closely mirror OpenAPI-backed data.
   - If the generated schema is just an API payload and the app never stores or reasons about it directly, keep it in the adapter layer instead of introducing a new Domain type.

4. Update the mapper layer.
   - Add request mappers from Domain inputs to `Components.Schemas.*`.
   - Add response mappers from `Components.Schemas.*` to Domain models.
   - Add error mappers when the endpoint exposes structured API errors.

5. Update the live adapter.
   - Implement the new `APIClient` entry in `APIClientLive.swift`.
   - Keep all `.ok`, `.internalServerError`, `.undocumented`, and body decoding logic in the adapter layer.
   - Keep auth, cache, and session side effects in the live adapter, not in generated code and not in reducers.

6. Verify the boundary.
   - Search for `Components.Schemas` and `Operations.` outside `OpenAPI` and `Adapters/APIClient`.
   - Feature code and `Domain` should not depend on generated transport types.

## Generation Heuristics

- Use the generated operation name as the default `APIClient` method name unless the repo already uses a stable domain-specific name.
- If the endpoint returns a schema DTO already represented in `Domain`, map it immediately and return the Domain type.
- If the endpoint returns no meaningful payload, expose `Void`.
- If the endpoint exposes an API-specific response wrapper whose only app value is one or two fields, unwrap it in the adapter and return the app-relevant values.
- If a generated enum casing differs from `Domain`, normalize in `APIClientMappers.swift`.
- Prefer adding small mapper extensions over leaking generated DTOs into reducers, views, or `Domain`.

## When To Push Back

Push back on literal mirroring when the request implies copying generated transport types into `Domain`. In this repo:

- `Domain` should not own `Operations.*`
- `Domain` should not own generated HTTP response wrapper enums
- `Domain` should not return generated `Components.Schemas.*` directly from `APIClient`

The right target is a handwritten domain layer that mirrors app semantics, while the adapter layer absorbs generated-contract churn.

## Validation

- Run the inventory script again after edits.
- Build with Xcode MCP if available.
- If the build is blocked by the OpenAPI generator plugin, still verify:
  - no diagnostics in edited files
  - `APIClient` contains the intended endpoint surface
  - mapper code compiles cleanly in isolation when possible
