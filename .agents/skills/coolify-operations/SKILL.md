---
name: coolify-operations
description: Operate and troubleshoot the LetsGrow production deployment on Coolify. Use for releases, failed deployments, unhealthy services, HTTP 502 responses, and Coolify MCP setup.
---

# Coolify Operations

Use this skill for LetsGrow deployment and production-runtime work.

## Source of truth

- Production runs the root `docker-compose.yml` through Coolify.
- The Compose services are `api`, `scheduler`, and `web`; production uses the mutable `prod` images and `pull_policy: always`.
- GitHub Actions publishes images and calls the Coolify deploy API with `force=true` so mutable tags are pulled again.
- The API health endpoint is `https://api.letsgrow.dk/actuator/health`.
- Do not read, print, or commit secrets from `.env`, GitHub Actions, or Coolify.

## Deployment verification

1. Confirm CI passed and the expected API, scheduler, and web `prod` images were published.
2. Confirm the Coolify deploy API accepted the forced deployment request.
3. Check Coolify deployment history and service state. If the API is unhealthy, inspect API container logs and the deployment build/runtime logs before changing configuration.
4. Check database connectivity, required environment-variable presence, image architecture, and container health. Never print environment values.
5. Verify `https://api.letsgrow.dk/actuator/health` returns HTTP 200 and `https://letsgrow.dk` returns a successful response.
6. Report what was verified and any remaining unhealthy service. A queued deployment is not evidence that the application is healthy.

The production API requires `FEEDBACK_ADMIN_EMAILS` to contain at least one
comma-separated email address while test-admin endpoints are disabled. Treat
this as an access-control allowlist; do not infer or add addresses without the
owner's instruction.

## Coolify MCP

If a Coolify MCP connection is available, start with the infrastructure overview and search for the LetsGrow Compose resource. Inspect deployment history, resource/service health, and supported log summaries. Use a team-scoped token with read access for inspection; add deploy permission only when the task requires lifecycle operations. Keep the token in the MCP client's secret storage.

The MCP endpoint is the trusted Coolify instance's HTTPS URL ending in `/mcp`, using Streamable HTTP and a Bearer token. Do not expose it through the customer-facing LetsGrow domain. See `docs/deployment/coolify.md` for setup details.

## Access limits

The current agent session may not have a Coolify MCP connector. A GitHub Actions `COOLIFY_TOKEN` is not automatically available to local tools. If logs cannot be accessed, say which Coolify dashboard/log access is missing and ask for the relevant deployment logs or a configured MCP connection. Never claim the backend is working based only on successful CI or a queued deployment.
