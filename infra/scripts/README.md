## Scripts

Place setup and redeploy helpers here.

Current:
- `build-and-push-web.sh`: builds and pushes the web Docker image for a supplied `DOCKER_TAG`
- `deploy-remote.sh`: used by the backend and web deploy workflows
- `local-db-reset.sh`: drops and recreates the local Postgres `feedback_db` database using `.env`
