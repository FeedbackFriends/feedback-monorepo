#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "${SCRIPT_DIR}/../.." && pwd)
ENV_FILE="${ROOT_DIR}/.env"
VERSION=${VERSION:-local}

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing .env at repo root: ${ENV_FILE}" >&2
  exit 1
fi

set -a
source "${ENV_FILE}"
set +a

echo "Building backend images with Jib (version: ${VERSION})..."
(cd "${ROOT_DIR}/backend" && ./gradlew --no-daemon :api:jibDockerBuild :scheduler:jibDockerBuild :email-listener:jibDockerBuild --no-configuration-cache -Pversion="${VERSION}")

echo "Building web image (version: ${VERSION})..."
docker build -t "nicolaidam/feedback-web:${VERSION}" "${ROOT_DIR}/web"

echo "Starting services with Docker Compose..."
(cd "${ROOT_DIR}" \
  && VERSION="${VERSION}" \
  ENV_FILE="${ENV_FILE}" \
  FIREBASE_CONFIG_FILE="${ROOT_DIR}/firebase_config.json" \
  docker compose -f infra/docker-compose.yml up -d --remove-orphans)
