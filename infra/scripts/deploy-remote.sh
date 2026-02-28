#!/usr/bin/env bash
set -euo pipefail

# Deploys docker-compose on the remote Debian host.
# Shared by the web GitHub Actions deploy workflow.

REMOTE_USER=${REMOTE_USER:-debian}
REMOTE_HOST=${REMOTE_HOST:-127.0.0.1}
REMOTE_CONFIG_DIR=${REMOTE_CONFIG_DIR:-/home/debian/config}
TMP_COMPOSE=${TMP_COMPOSE:-/tmp/docker-compose.yml}
NGINX_TAR=${NGINX_TAR:-/tmp/nginx.tar.gz}
COMPOSE_FILE=${COMPOSE_FILE:-infra/docker-compose.yml}
APPLY_FIREWALL=${APPLY_FIREWALL:-0}
FIREWALL_TMP=${FIREWALL_TMP:-/tmp/apply-ufw.sh}
SSH_OPTS=${SSH_OPTS:-}
DEPLOY_SERVICES=${DEPLOY_SERVICES:-api scheduler web}
FULL_DEPLOY=${FULL_DEPLOY:-1}
API_DOCKER_TAG=${API_DOCKER_TAG:-}
SCHEDULER_DOCKER_TAG=${SCHEDULER_DOCKER_TAG:-}
WEB_DOCKER_TAG=${WEB_DOCKER_TAG:-}

if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "Compose file not found: $COMPOSE_FILE" >&2
  exit 1
fi

read -r -a DEPLOY_SERVICE_ARRAY <<< "${DEPLOY_SERVICES}"

if [[ "${FULL_DEPLOY}" == "1" ]]; then
  DEPLOY_SERVICE_ARRAY=(api scheduler web)
  DEPLOY_SERVICES="api scheduler web"
  API_DOCKER_TAG=${API_DOCKER_TAG:-${DOCKER_TAG:-}}
  SCHEDULER_DOCKER_TAG=${SCHEDULER_DOCKER_TAG:-${DOCKER_TAG:-}}
  WEB_DOCKER_TAG=${WEB_DOCKER_TAG:-${DOCKER_TAG:-}}
fi

if [[ ${#DEPLOY_SERVICE_ARRAY[@]} -eq 0 ]]; then
  echo "DEPLOY_SERVICES must include at least one service" >&2
  exit 1
fi

for service in "${DEPLOY_SERVICE_ARRAY[@]}"; do
  case "${service}" in
    api)
      if [[ -z "${API_DOCKER_TAG}" ]]; then
        echo "API_DOCKER_TAG or DOCKER_TAG is required when deploying api" >&2
        exit 1
      fi
      ;;
    scheduler)
      if [[ -z "${SCHEDULER_DOCKER_TAG}" ]]; then
        echo "SCHEDULER_DOCKER_TAG or DOCKER_TAG is required when deploying scheduler" >&2
        exit 1
      fi
      ;;
    web)
      if [[ -z "${WEB_DOCKER_TAG}" ]]; then
        echo "WEB_DOCKER_TAG or DOCKER_TAG is required when deploying web" >&2
        exit 1
      fi
      ;;
    *)
      echo "Unsupported service in DEPLOY_SERVICES: ${service}" >&2
      exit 1
      ;;
  esac
done

REMOTE_EXPORTS=$(cat <<EOF
export DEPLOY_SERVICES="${DEPLOY_SERVICES}"
export FULL_DEPLOY="${FULL_DEPLOY}"
export API_DOCKER_TAG="${API_DOCKER_TAG}"
export SCHEDULER_DOCKER_TAG="${SCHEDULER_DOCKER_TAG}"
export WEB_DOCKER_TAG="${WEB_DOCKER_TAG}"
EOF
)

REMOTE_COMMANDS=$(cat <<EOF
set -e
${REMOTE_EXPORTS}
sudo mv ${TMP_COMPOSE} ${REMOTE_CONFIG_DIR}/docker-compose.yml
sudo mv ${FIREWALL_TMP} ${REMOTE_CONFIG_DIR}/apply-ufw.sh
sudo chmod +x ${REMOTE_CONFIG_DIR}/apply-ufw.sh
sudo tar -xzf ${NGINX_TAR} -C /etc/nginx
sudo rm -f ${NGINX_TAR}
sudo mkdir -p /etc/nginx/sites-enabled
for site in /etc/nginx/sites-available/*; do
  sudo ln -sf "\${site}" "/etc/nginx/sites-enabled/\$(basename "\${site}")"
done
sudo nginx -t
sudo systemctl reload nginx
cd ${REMOTE_CONFIG_DIR}
sudo touch .env
sudo sed -i '/^VERSION=/d' .env
if [[ -n "\${API_DOCKER_TAG}" ]]; then
  sudo sed -i '/^API_VERSION=/d' .env
  printf 'API_VERSION=%s\n' "\${API_DOCKER_TAG}" | sudo tee -a .env >/dev/null
fi
if [[ -n "\${SCHEDULER_DOCKER_TAG}" ]]; then
  sudo sed -i '/^SCHEDULER_VERSION=/d' .env
  printf 'SCHEDULER_VERSION=%s\n' "\${SCHEDULER_DOCKER_TAG}" | sudo tee -a .env >/dev/null
fi
if [[ -n "\${WEB_DOCKER_TAG}" ]]; then
  sudo sed -i '/^WEB_VERSION=/d' .env
  printf 'WEB_VERSION=%s\n' "\${WEB_DOCKER_TAG}" | sudo tee -a .env >/dev/null
fi
set -a
source .env
set +a
docker network create feedback-network >/dev/null 2>&1 || true
export ENV_FILE="${REMOTE_CONFIG_DIR}/.env"
export FIREBASE_CONFIG_FILE="${REMOTE_CONFIG_DIR}/firebase_config.json"
docker image prune -af
if [[ "\${FULL_DEPLOY}" == "1" ]]; then
  docker compose -f docker-compose.yml pull
  docker compose -f docker-compose.yml up -d --remove-orphans
else
  read -r -a DEPLOY_SERVICE_ARRAY <<< "\${DEPLOY_SERVICES}"
  docker compose -f docker-compose.yml pull "\${DEPLOY_SERVICE_ARRAY[@]}"
  docker compose -f docker-compose.yml up -d --no-deps "\${DEPLOY_SERVICE_ARRAY[@]}"
fi
docker image prune -f
if [[ "${APPLY_FIREWALL}" == "1" ]]; then
  bash -s < ${REMOTE_CONFIG_DIR}/apply-ufw.sh
fi
EOF
)

if [[ -z "${DOCKER_TAG:-}" && "${FULL_DEPLOY}" == "1" ]]; then
  echo "DOCKER_TAG is required for a full deploy" >&2
  exit 1
fi

DOCKER_COMPOSE_TMP=$(mktemp)

cp "$COMPOSE_FILE" "$DOCKER_COMPOSE_TMP"

NGINX_TMP=$(mktemp)
tar -czf "$NGINX_TMP" -C infra/nginx nginx.conf sites-available

if [[ -n "${DEBIAN_PASSWORD:-}" ]]; then
  SSH_OPTS="${SSH_OPTS} -o StrictHostKeyChecking=no"
  sshpass -p "${DEBIAN_PASSWORD}" scp ${SSH_OPTS} "$DOCKER_COMPOSE_TMP" "${REMOTE_USER}@${REMOTE_HOST}:${TMP_COMPOSE}"
  sshpass -p "${DEBIAN_PASSWORD}" scp ${SSH_OPTS} "$NGINX_TMP" "${REMOTE_USER}@${REMOTE_HOST}:${NGINX_TAR}"
  sshpass -p "${DEBIAN_PASSWORD}" scp ${SSH_OPTS} infra/firewall/apply-ufw.sh "${REMOTE_USER}@${REMOTE_HOST}:${FIREWALL_TMP}"
  sshpass -p "${DEBIAN_PASSWORD}" ssh ${SSH_OPTS} "${REMOTE_USER}@${REMOTE_HOST}" "${REMOTE_COMMANDS}"
else
  scp ${SSH_OPTS} "$DOCKER_COMPOSE_TMP" "${REMOTE_USER}@${REMOTE_HOST}:${TMP_COMPOSE}"
  scp ${SSH_OPTS} "$NGINX_TMP" "${REMOTE_USER}@${REMOTE_HOST}:${NGINX_TAR}"
  scp ${SSH_OPTS} infra/firewall/apply-ufw.sh "${REMOTE_USER}@${REMOTE_HOST}:${FIREWALL_TMP}"
  ssh ${SSH_OPTS} "${REMOTE_USER}@${REMOTE_HOST}" "${REMOTE_COMMANDS}"
fi

rm -f "$DOCKER_COMPOSE_TMP"
rm -f "$NGINX_TMP"
