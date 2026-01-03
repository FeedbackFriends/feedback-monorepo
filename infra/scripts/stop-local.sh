#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "${SCRIPT_DIR}/../.." && pwd)
ENV_FILE="${ROOT_DIR}/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing .env at repo root: ${ENV_FILE}" >&2
  exit 1
fi

echo "Stopping services with Docker Compose..."
(cd "${ROOT_DIR}" \
  && ENV_FILE="${ENV_FILE}" \
  FIREBASE_CONFIG_FILE="${ROOT_DIR}/firebase_config.json" \
  docker compose -f infra/docker-compose.yml down)
