# Backend API contract

Paths and commands are relative to `backend/` unless stated otherwise.

## OpenAPI Contract

- Backend controllers, DTOs, and OpenAPI configuration are the source of truth.
- `syncOpenApiSpec` writes `contracts/openapi/feedback-api.yaml`.
- Do not hand-edit the contract or generated clients; see the [shared API contract guide](../../../docs/agents/api-contract.md).
- After endpoint, request, response, enum, or error-shape changes, regenerate with `./scripts/generate-api-artifacts.sh` from the monorepo root and update affected call sites.
