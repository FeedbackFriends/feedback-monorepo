#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export PATH="/usr/local/bin:/opt/homebrew/bin:${PATH}"
require_docker_daemon() {
  local current_context="${1:-$(docker context show 2>/dev/null || echo unknown)}"
  if ! docker info >/dev/null 2>&1; then
    echo "Docker daemon is not reachable (context: ${current_context}). Start Docker and retry ./scripts/shared/reset-and-start-local-stack.sh." >&2
    exit 1
  fi
}

cd "$REPO_ROOT"
require_docker_daemon
docker compose down --volumes --remove-orphans
./scripts/shared/generate-api-artifacts.sh
(cd backend && ./gradlew --no-daemon --no-configuration-cache buildLocalImages)
docker compose up --build "$@"
