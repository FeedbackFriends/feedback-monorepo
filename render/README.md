# Render Deployment Notes

This project is deployed on Render from the Git repository using the Blueprint in [../render.yaml](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/render.yaml).

## Services

- `feedback-api`: public Spring Boot API, Docker runtime, Render `free` plan.
- `feedback-web`: public Next.js frontend, Docker runtime, Render `free` plan.
- `feedback-scheduler`: background worker, Docker runtime, Render `starter` plan.
- `feedback-db`: managed Postgres, `basic-256mb`.

## Why The API And Web Stay Free

The current setup is intentionally cost-sensitive:
- keep the API and frontend on `free` while traffic is still low
- keep the scheduler on `starter` because Render does not provide free workers
- accept cold starts on `feedback-api` and `feedback-web`

This is a valid low-cost deployment, but it is not a fully hardened production tier. When response-time consistency matters, upgrade the web services to `starter`.

## Deploy Flow

Render deploys from Git, not from the Docker Hub images built in GitHub Actions.

- [../.github/workflows/ci.yml](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/.github/workflows/ci.yml) must pass on `main`
- [../render.yaml](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/render.yaml) uses `autoDeployTrigger: checksPass`
- Render rebuilds the services from this repository after the branch check succeeds
- [../.github/workflows/release.yml](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/.github/workflows/release.yml) only publishes release artifacts and validates the Blueprint

## Required Render Configuration

Secrets and environment values are not committed to the repo.

Required manual configuration in Render:
- Set all `sync: false` environment variables declared in [../render.yaml](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/render.yaml)
- Add a secret file named `firebase_config.json`
- Mount that file at `/etc/secrets/firebase_config.json` for both `feedback-api` and `feedback-scheduler`

The API and scheduler both expect:
- `FIREBASE_CONFIG_PATH=/etc/secrets/firebase_config.json`

## Health Checks And Monorepo Behavior

The Blueprint is configured so:
- `feedback-api` uses `/actuator/health`
- `feedback-web` uses `/api/health`
- backend services only rebuild when `backend/**` or `render.yaml` changes
- the frontend only rebuilds when `web/**` or `render.yaml` changes

## Operational Notes

- The scheduler should keep Liquibase enabled so it does not fail if it starts before another service has migrated the database.
- If Render logs show `firebase_config.json` missing, the secret file mount is not configured correctly.
- If Render stops auto-deploying after merges, check whether [../.github/workflows/ci.yml](/Users/nicolaidam/Documents/Projects/Feedback/feedback-mono/.github/workflows/ci.yml) is passing on `main`.
