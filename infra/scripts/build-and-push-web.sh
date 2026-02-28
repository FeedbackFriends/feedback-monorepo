#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "${SCRIPT_DIR}/../.." && pwd)
DOCKER_IMAGE=${DOCKER_IMAGE:-nicolaidam/feedback-web}

if [[ -z "${DOCKER_TAG:-}" ]]; then
  echo "DOCKER_TAG is required" >&2
  exit 1
fi

docker build -t "${DOCKER_IMAGE}:${DOCKER_TAG}" "${ROOT_DIR}/web"
docker push "${DOCKER_IMAGE}:${DOCKER_TAG}"
