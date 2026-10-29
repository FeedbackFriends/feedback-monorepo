# API, authentication, and environment

Paths are relative to `web/` unless stated otherwise.

## API Contract

- `src/lib/api/generated/openapi.ts` is generated from `contracts/openapi/feedback-api.yaml`; never hand-edit it.
- When the contract changes, regenerate from the monorepo root with `./scripts/generate-api-artifacts.sh` and update typed call sites.
- Backend controllers, DTOs, and OpenAPI configuration own API shape; see the [shared API contract guide](../../../docs/agents/api-contract.md).

## Auth And Environment

- Firebase client auth lives under `src/lib/auth/`.
- E2E auth helpers live under `src/lib/auth/e2e-auth-client.ts`.
- Root `.env` supplies runtime values. Never commit secrets.
- Treat `NEXT_PUBLIC_*` values as client-exposed and never put secrets in them.
