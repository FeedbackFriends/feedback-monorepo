## Infra

This folder mirrors server-side infra configs so the repo can be moved or rebuilt on a new host.

Deployment steps are mirrored from `.github/workflows/deploy.yml`, `.github/workflows/deploy-backend.yml`, and `.github/workflows/deploy-frontend.yml`.
The deploy script syncs `infra/nginx/` to the server and uses `infra/docker-compose.yml`.

### Prerequisites
- Debian host with sudo access.
- Docker Engine + Docker Compose plugin installed (use Docker's official Debian repo).
- Nginx installed and enabled.
- UFW installed.
- `/home/debian/config` exists and contains `.env` and `firebase_config.json`.
