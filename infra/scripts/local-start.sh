#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "${SCRIPT_DIR}/../.." && pwd)
ENV_FILE="${ROOT_DIR}/.env"
VERSION=${VERSION:-local}
GRADLE_WARNING_MODE="${GRADLE_WARNING_MODE:-summary}"
DOCKER_DEFAULT_PLATFORM="${DOCKER_DEFAULT_PLATFORM:-}"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing .env at repo root: ${ENV_FILE}" >&2
  exit 1
fi

set -a
source "${ENV_FILE}"
set +a

if [[ -z "${DOCKER_DEFAULT_PLATFORM}" ]]; then
  case "$(uname -m)" in
    arm64|aarch64)
      DOCKER_DEFAULT_PLATFORM="linux/amd64"
      ;;
  esac
fi

if [[ -n "${DOCKER_DEFAULT_PLATFORM}" ]]; then
  export DOCKER_DEFAULT_PLATFORM
fi

echo "Building backend images with Jib (version: ${VERSION})..."
(cd "${ROOT_DIR}/backend" && ./gradlew --no-daemon --warning-mode="${GRADLE_WARNING_MODE}" :api:jibDockerBuild :scheduler:jibDockerBuild --no-configuration-cache -Pversion="${VERSION}")

echo "Building web image (version: ${VERSION})..."
docker build -t "nicolaidam/feedback-web:${VERSION}" "${ROOT_DIR}/web"

echo "Ensuring Docker network exists..."
docker network create feedback-network >/dev/null 2>&1 || true

echo "Starting services with Docker Compose..."
(cd "${ROOT_DIR}" \
  && API_VERSION="${VERSION}" \
  && SCHEDULER_VERSION="${VERSION}" \
  && WEB_VERSION="${VERSION}" \
  ENV_FILE="${ENV_FILE}" \
  FIREBASE_CONFIG_FILE="${ROOT_DIR}/firebase_config.json" \
  docker compose -f infra/docker-compose.yml up -d --remove-orphans)
