# Coolify Deployment

Production runs through Coolify using the root `docker-compose.yml`. Local
development overrides in `docker-compose.override.yml` are not part of the
production resource.

## Release flow

The GitHub Actions release workflow builds and publishes
`nicolaidam/feedback-api:prod`, `nicolaidam/feedback-scheduler:prod`, and
`nicolaidam/feedback-web:prod`, then sends a forced deployment request to the
Coolify API with `force=true`. This ensures Coolify pulls the newly published
mutable `prod` image tags.

Required GitHub Actions secrets:

- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`
- `COOLIFY_BASE_URL` - base URL of the Coolify instance.
- `COOLIFY_RESOURCE_UUID` - UUID of the LetsGrow Compose resource.
- `COOLIFY_TOKEN` - bearer token with deploy permission for the resource.

Keep secret values in GitHub Actions or Coolify. Do not copy them into this
repository or print them in logs.

## Coolify resource

Create a Docker Compose resource from the repository root and use
`docker-compose.yml`. Configure the production environment variables required
by that Compose file, including database credentials, Firebase configuration,
JWT settings, Zoho credentials, `IMAGE_PLATFORM`, and the public web
configuration. Set the LetsGrow public domain on the `web` service at port
`3000`; the API service listens on `8080` and exposes its management endpoint
on `8090` internally.

The API health endpoint is:

```text
https://api.letsgrow.dk/actuator/health
```

The public site is `https://letsgrow.dk`.

## Verifying and troubleshooting a deployment

A successful GitHub build or an accepted Coolify deployment request does not
prove that the containers started correctly. Verify the deployment state and
API health after each production release.

For HTTP 502 from the API domain:

1. Inspect the latest Coolify deployment result and API container state.
2. Read the API deployment and container logs.
3. Confirm the API image was pulled and is running the expected architecture.
4. Check required environment-variable presence and database connectivity
   without exposing their values.
5. Check whether the API process is listening on port `8080` and whether the
   management endpoint responds on `8090` inside the Coolify network.
6. Verify the public health endpoint returns HTTP 200 after remediation.

## Coolify MCP

Coolify provides a remote MCP endpoint at the trusted instance URL ending in
`/mcp`. Enable API and MCP access in Coolify, enable MCP for the relevant team,
and create a team-scoped API token. Use `read` for inspection; add
`read:sensitive` only when supported log summaries require it, and add `deploy`
only if the client needs to start or restart resources. Do not use a root token
for routine operations.

Configure the AI client for Streamable HTTP at the Coolify instance's `/mcp`
endpoint with the token supplied through secret storage. Keep the MCP endpoint
on a dedicated infrastructure hostname or the Coolify host; do not attach it to
`letsgrow.dk`. MCP respects token permissions and team scope, and may return
redacted log summaries rather than full container logs.

Official setup and security references:

- [Coolify MCP setup](https://coolify.io/docs/mcp/setup)
- [How Coolify MCP works](https://coolify.io/docs/mcp/how-mcp-works)
- [Coolify MCP security](https://coolify.io/docs/mcp/security)
- [Coolify deploy API](https://coolify.io/docs/api/endpoints/deployments/deploy-by-tag-or-uuid)
