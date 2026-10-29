# iOS API integration

Paths are relative to `ios-app/` unless stated otherwise.

## OpenAPI Way Of Working

- Treat `Modules/Sources/OpenAPI/GeneratedSources/Client.swift` and `Types.swift` as generated contract code only.
- Keep the handwritten app-facing API surface in `Modules/Sources/Domain/Services/ApiClient.swift`.
- `Modules/Sources/Adapters/APIClient/Live/` calls the generated `APIProtocol`, handles response cases, and coordinates auth, cache, and session side effects.
- `Modules/Sources/Adapters/APIClient/Mappers/` translates between generated OpenAPI schema types and Domain models.
- `Modules/Sources/Domain/Models/API/` is the preferred home for handwritten Domain models that closely mirror API request/response concepts.
- Do not mirror every generated schema into Domain. Add Domain equivalents only for concepts the app actually uses.
- Regenerate API artifacts from the monorepo root with `./scripts/generate-api-artifacts.sh`.
