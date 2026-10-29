# Runtime and deployment

## Local Docker Compose

- `docker-compose.yml` is the production-like base stack using published `feedback-api:prod`, `feedback-scheduler:prod`, and `feedback-web:prod` images plus the shared environment contract.
- `docker-compose.override.yml` adds local development wiring, published ports, and local images.
- Compose reads variables from a root `.env` file when present.

Run these commands from the monorepo root:

```bash
./scripts/run
./scripts/run -d
docker compose down
docker compose logs -f
docker compose ps
```

`./scripts/run` stops the stack with `docker compose down --volumes --remove-orphans`, regenerates API artifacts, rebuilds backend images, and starts Compose. For local backend plus iOS work, follow [iOS workflows](ios-workflows.md), which routes to the data-preserving startup workflow.

## Environment

- Keep secrets in `.env`, GitHub secrets, or Coolify-managed environment variables; never commit real secret values.
- Treat `NEXT_PUBLIC_*` values as client-exposed.
- Treat `COOLIFY_TOKEN` as a secret; never expose it in logs, docs, or commits.
- When adding or changing runtime configuration, call out new environment variables, ports, domains, image tags, or deployment assumptions.

## Production deployment

Production uses Coolify. Keep deployment changes aligned with the [current Coolify setup](../deployment/coolify.md).

- Production runtime should pull mutable `prod` image tags.
- Keep local Compose behavior and Coolify runtime expectations consistent.
