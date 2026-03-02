# Feedback Monorepo

Production deployment is defined by [render.yaml](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/render.yaml).

The active Render Blueprint defines:
- the `feedback-api` web service
- the `feedback-scheduler` background worker
- the `feedback-web` web service
- the `feedback-db` managed Postgres instance

Backend Dockerfiles live next to their apps in [backend/apps/api/Dockerfile](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/backend/apps/api/Dockerfile) and [backend/apps/scheduler/Dockerfile](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/backend/apps/scheduler/Dockerfile). The shared Spring container startup script lives in [backend/docker/start-spring.sh](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/backend/docker/start-spring.sh).

Render-specific setup steps, required environment variables, and secret-file requirements are documented in [render/README.md](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/render/README.md).

## Render Deployment

This repo keeps Render as the production deployment source of truth:
- Pushes to `main` run [`.github/workflows/ci.yml`](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/.github/workflows/ci.yml), which is the check Render waits for because the Blueprint uses `autoDeployTrigger: checksPass`.
- Render builds services directly from this repository using [render.yaml](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/render.yaml).
- [`.github/workflows/release.yml`](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/.github/workflows/release.yml) publishes release artifacts. It does not deploy Render services.

Current cost posture:
- `feedback-api` stays on Render `free`.
- `feedback-web` stays on Render `free`.
- `feedback-scheduler` stays on Render `starter`, because Render workers do not have a free tier.
- `feedback-db` stays on `basic-256mb`.

Free-tier tradeoffs:
- `feedback-api` and `feedback-web` can spin down after idle periods and incur cold starts.
- This setup is acceptable for low-traffic production or pre-launch use, but it is not a zero-latency production setup.
- The first infrastructure upgrade should be moving the API and web services from `free` to `starter`.

For local development, run `docker compose up --build` from the repo root to start `web`, `api`, `scheduler`, and Postgres using [docker-compose.yml](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/docker-compose.yml).
