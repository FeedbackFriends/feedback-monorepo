# Repository Guidelines

## Project Structure & Module Organization
- `infra/docker-compose.yml` defines the services and networks used for deployment.
- `infra/nginx/` holds the base `nginx.conf`, `conf.d/` includes, and `sites-available/` vhosts synced to the server.
- `infra/firewall/` contains UFW helper scripts (see `apply-ufw.sh`).
- `infra/scripts/` includes local build/run helpers and the remote deploy script.
- `infra/firebase_config.json` is a repo copy used by Docker Compose; production uses `/home/debian/config/firebase_config.json`.

## Build, Test, and Development Commands
- `./infra/scripts/local-start.sh`: builds backend images with Gradle Jib, builds the web image, then runs `docker compose up -d`. Requires `.env` at repo root.
- `./infra/scripts/local-stop.sh`: stops local services via `docker compose down`.
- `./infra/scripts/deploy-remote.sh`: deploys to a Debian host via SSH/SCP. Requires `DOCKER_TAG`; optional `REMOTE_HOST`, `REMOTE_USER`, and `APPLY_FIREWALL=1`.
- Manual validation: `docker compose -f infra/docker-compose.yml config` and `nginx -t` on the target host.

## Coding Style & Naming Conventions
- Shell scripts are Bash with `set -euo pipefail`; keep 2-space indentation and avoid complex subshells when possible.
- Use kebab-case for script names and lowercase for config paths.
- Nginx sites live in `infra/nginx/sites-available/` and are symlinked to `sites-enabled` on deploy.

## Testing Guidelines
- There is no automated test suite in `infra/`.
- Validate config changes by running the local compose build or `nginx -t` on the host before deploy.

## Commit & Pull Request Guidelines
- Git history shows short, informal messages (e.g., `fix`, `wip`). Prefer concise, imperative summaries and avoid `wip` for merged commits.
- PRs should describe infra impact, list config changes, and note any manual steps (e.g., firewall updates or nginx reloads).

## Security & Configuration Tips
- Do not commit secrets. Local `.env` lives at repo root; production env/config files live under `/home/debian/config`.
- Update `infra/nginx/` or `infra/firewall/` carefully and verify before deployment.
