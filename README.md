# Feedback Monorepo

Production deployment is defined by [render.yaml](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/render.yaml).

The active Render Blueprint defines:
- the `feedback-api` web service
- the `feedback-scheduler` background worker
- the `feedback-web` web service
- the `feedback-db` managed Postgres instance

Backend Dockerfiles live next to their apps in [backend/apps/api/Dockerfile](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/backend/apps/api/Dockerfile) and [backend/apps/scheduler/Dockerfile](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/backend/apps/scheduler/Dockerfile). The shared Spring container startup script lives in [backend/docker/start-spring.sh](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/backend/docker/start-spring.sh).

Render-specific setup steps, required environment variables, and secret-file requirements are documented in [render/README.md](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/render/README.md).

For local development, run `docker compose up --build` from the repo root to start `web`, `api`, `scheduler`, and Postgres using [docker-compose.yml](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/docker-compose.yml).
