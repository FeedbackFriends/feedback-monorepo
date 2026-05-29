---
name: letsgrow-sync-openapi-ios
description: >-
  Use when syncing the iOS app's handwritten API boundary from
  `Modules/Sources/OpenAPI/GeneratedSources/Client.swift` and `Types.swift`:
  mirror generated client operations into `Domain/APIClient`, create same-named
  Domain API models for consumed schemas, add mapper files in
  `Modules/Sources/Adapters/APIClient/Mappers`, and update
  `Modules/Sources/Adapters/APIClient/Live` plus `AppMock/ApiClientMock.swift`.
---

# LetsGrow Sync OpenAPI iOS

Use this skill when the user wants to:

- sync handwritten iOS API code from `Modules/Sources/OpenAPI/GeneratedSources/Client.swift`
- add missing app-facing endpoints to `Modules/Sources/Domain/Services/ApiClient.swift`
- create or update same-named Domain API models for consumed generated schemas
- add or update mapper files in `Modules/Sources/Adapters/APIClient/Mappers/`
- keep `Modules/Sources/Adapters/APIClient/Live/` and `AppMock/ApiClientMock.swift` aligned with `APIClient`

## Source Of Truth

- Treat `Modules/Sources/OpenAPI/GeneratedSources/Client.swift` as the source of truth for operation names and the top-level `Components.Schemas.*` types that cross the app boundary.
- Treat `Modules/Sources/OpenAPI/GeneratedSources/Types.swift` as the source of truth for the field shape, enum cases, nested payloads, and convenience overloads of the schemas selected from `Client.swift`.
- Start from `Client.swift` to decide what needs syncing, then use `Types.swift` to implement the matching Domain model and mapper details.
- Never hand-edit generated files under `Modules/Sources/OpenAPI/GeneratedSources/`.

## Boundary Rules

- `Modules/Sources/Domain/` owns app-facing models, errors, and the handwritten `APIClient`.
- `Modules/Sources/Adapters/APIClient/` owns all translation between generated OpenAPI types and Domain types.
- Generated operation names from `Client.swift` are the default `APIClient` method names. If handwritten names drift, treat that as sync debt unless the user explicitly asks to preserve them.
- For consumed `Components.Schemas.X` types, prefer a same-named handwritten Domain model `X` in `Modules/Sources/Domain/Models/API/`.
- Mapper files should be keyed by the generated schema name so they stay easy to locate. Prefer `Requests/<SchemaName>+Mapping.swift` and `Responses/<SchemaName>+Mapping.swift`.
- Do not copy generated transport wrappers like `Operations.*`, status-code enums, response wrapper enums, or `APIProtocol` helper types into `Domain`.
- Every `APIClient` change must be reflected in both `Modules/Sources/Adapters/APIClient/Live/` and `AppMock/ApiClientMock.swift` in the same change.
- Do not introduce placeholder fallback values to satisfy schema drift (for example `title: ""`, `agenda: nil` just to keep old models, or `UUID(uuidString:) ?? UUID()`). Align the Domain model shape with the spec and fail fast (`fatalError`/force unwrap) when required contract values are invalid.

## Files To Inspect First

- `Modules/Sources/OpenAPI/GeneratedSources/Client.swift`
- `Modules/Sources/OpenAPI/GeneratedSources/Types.swift`
- `Modules/Sources/Domain/Services/ApiClient.swift`
- `Modules/Sources/Domain/Models/API/`
- `Modules/Sources/Adapters/APIClient/Mappers/`
- `Modules/Sources/Adapters/APIClient/Live/`
- `AppMock/ApiClientMock.swift`
- `Modules/Sources/Domain/Models/`
- `Modules/Sources/Domain/Errors/`

## Quick Start

Run the inventory script first:

```bash
python3 .agents/skills/letsgrow-sync-openapi-ios/scripts/inventory_openapi_domain_sync.py
```

That script prints:

- generated endpoint names from `Client.swift`
- schema and payload details from `Types.swift`
- handwritten endpoint names from `Domain/Services/ApiClient.swift`
- missing or extra `APIClient` entries
- `Client.swift` schema names without same-named Domain API models
- `Client.swift` schema names without same-named mapper files
- missing or extra initializer coverage in `Live` and `AppMock`

## Workflow

1. Inventory the generated surface.
   - Start with the script.
   - Confirm which generated `Client` methods are missing from `Domain.APIClient`, `Live`, and `AppMock`.
   - Confirm which `Components.Schemas.*` names referenced by `Client.swift` do not yet have same-named Domain API models or mapper files.
   - Open `Types.swift` for the specific schemas you are about to sync so the Domain model and mapper match the generated field shape.

2. Decide the app-facing shape.
   - Keep a single `APIClient` dependency.
   - Add one handwritten closure per generated client method unless there is a deliberate, explicit reason to exclude it.
   - Default to the generated operation name from `Client.swift`.
   - Keep local-only helpers, such as cache listeners, explicit and justified rather than mixing them into the generated sync surface.

3. Model the consumed schema types in `Domain`.
   - Create or update handwritten `Domain` models only for schema concepts the app uses.
   - Prefer `Modules/Sources/Domain/Models/API/` for same-named models that mirror consumed OpenAPI-backed data.
   - Keep transport-only wrappers out of `Domain`, but preserve schema naming for the actual payload model where it crosses the app boundary.
   - If the generated schema is only an adapter implementation detail and never crosses the handwritten `APIClient` boundary, keep it in the adapter layer instead of adding a Domain model.

4. Update the mapper layer.
   - Add request mappers from Domain inputs to `Components.Schemas.*`.
   - Add response mappers from `Components.Schemas.*` to Domain models.
   - Add error mappers when the endpoint exposes structured API errors.
   - Keep mapper filenames keyed by generated schema names so a search for the schema lands in the correct mapper file immediately.

5. Update the live adapter.
   - Update `Modules/Sources/Adapters/APIClient/Live/APIClient+Live.swift` plus the relevant split `APIClient+Live*.swift` helper files.
   - Keep all `.ok`, `.internalServerError`, `.undocumented`, and body decoding logic in the adapter layer.
   - Keep auth, cache, and session side effects in the live adapter, not in generated code and not in reducers.

6. Update the mock adapter.
   - Keep `AppMock/ApiClientMock.swift` initializer labels aligned with `APIClient`.
   - Return deterministic placeholder Domain values using the same handwritten boundary types that the live client returns.

7. Verify the boundary.
   - Search for `Components.Schemas` and `Operations.` outside `OpenAPI` and `Adapters/APIClient`.
   - Feature code and `Domain` should not depend on generated transport types.

## Generation Heuristics

- Use the generated operation name as the default `APIClient` method name.
- If the endpoint returns a consumed schema already represented in `Domain`, map it immediately and return the same-named handwritten Domain type.
- If the endpoint returns no meaningful payload, expose `Void`.
- If the endpoint exposes an API-specific response wrapper whose only app value is one or two fields, unwrap it in the adapter and return the app-relevant values.
- If a generated enum casing differs from `Domain`, normalize in `APIClientMappers.swift`.
- Prefer adding small mapper extensions over leaking generated DTOs into reducers, views, or `Domain`.

## When To Push Back

Push back on literal mirroring when the request implies copying generated transport types into `Domain`. In this repo:

- `Domain` should not own `Operations.*`
- `Domain` should not own generated HTTP response wrapper enums
- `Domain` should not return generated `Components.Schemas.*` directly from `APIClient`
- `Client.swift` is the source of truth for what to sync first; do not start by cloning all of `Types.swift`
- `Types.swift` is a schema reference, not a checklist for copying every generated type into `Domain`

The right target is a handwritten Domain layer with same-named consumed payload models, while the adapter layer absorbs generated-contract churn and transport wrappers.

## Validation

- Run the inventory script again after edits.
- If the inventory still shows missing `APIClient`, `Live`, or `AppMock` coverage for generated methods, the sync is incomplete.
- If the inventory still shows missing same-named Domain API models or mapper files for consumed schemas, the sync is incomplete unless you have an explicit reason to keep those schemas adapter-only.
- Build with Xcode MCP if available.
- If the build is blocked by the OpenAPI generator plugin, still verify:
  - no diagnostics in edited files
  - `APIClient` contains the intended endpoint surface
  - `Live` and `AppMock` initializer labels match `APIClient`
  - mapper code compiles cleanly in isolation when possible
