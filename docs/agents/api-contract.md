# API contract

Backend controllers, DTOs, and OpenAPI configuration are the source of truth for API shape. They generate `contracts/openapi/feedback-api.yaml`, which feeds:

- `web/src/lib/api/generated/openapi.ts`
- `ios-app/Modules/Sources/OpenAPI/GeneratedSources/`

Never hand-edit the contract or generated clients. Regenerate them from the monorepo root:

```bash
./scripts/generate-api-artifacts.sh
```

See the [contract documentation](../../contracts/openapi/README.md) and the owning app's `AGENTS.md` for app-specific integration and validation.
