#!/usr/bin/env bash
set -euo pipefail

# Deploys docker-compose on the remote Debian host.
# Mirrors .github/workflows/deploy.yml server-side steps.

REMOTE_USER=${REMOTE_USER:-debian}
REMOTE_HOST=${REMOTE_HOST:-127.0.0.1}
REMOTE_CONFIG_DIR=${REMOTE_CONFIG_DIR:-/home/debian/config}
TMP_COMPOSE=${TMP_COMPOSE:-/tmp/docker-compose.yml}
NGINX_TAR=${NGINX_TAR:-/tmp/nginx.tar.gz}
COMPOSE_FILE=${COMPOSE_FILE:-backend/docker-compose.yml}
APPLY_FIREWALL=${APPLY_FIREWALL:-0}
FIREWALL_TMP=${FIREWALL_TMP:-/tmp/apply-ufw.sh}
SSH_OPTS=${SSH_OPTS:-}

if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "Compose file not found: $COMPOSE_FILE" >&2
  exit 1
fi

if [[ -z "${DOCKER_TAG:-}" ]]; then
  echo "DOCKER_TAG is required" >&2
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
  sshpass -p "${DEBIAN_PASSWORD}" ssh ${SSH_OPTS} "${REMOTE_USER}@${REMOTE_HOST}" << EOF
set -e
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
sudo sed -i '/^VERSION=/d' .env
export VERSION="${DOCKER_TAG}"
docker network create feedback-network >/dev/null 2>&1 || true
docker image prune -af
docker compose -f docker-compose.yml pull
docker compose -f docker-compose.yml up -d --remove-orphans
docker image prune -f
if [[ "${APPLY_FIREWALL}" == "1" ]]; then
  bash -s < ${REMOTE_CONFIG_DIR}/apply-ufw.sh
fi
EOF
else
  scp ${SSH_OPTS} "$DOCKER_COMPOSE_TMP" "${REMOTE_USER}@${REMOTE_HOST}:${TMP_COMPOSE}"
  scp ${SSH_OPTS} "$NGINX_TMP" "${REMOTE_USER}@${REMOTE_HOST}:${NGINX_TAR}"
  scp ${SSH_OPTS} infra/firewall/apply-ufw.sh "${REMOTE_USER}@${REMOTE_HOST}:${FIREWALL_TMP}"
  ssh ${SSH_OPTS} "${REMOTE_USER}@${REMOTE_HOST}" << EOF
set -e
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
sudo sed -i '/^VERSION=/d' .env
export VERSION="${DOCKER_TAG}"
docker network create feedback-network >/dev/null 2>&1 || true
docker image prune -af
docker compose -f docker-compose.yml pull
docker compose -f docker-compose.yml up -d --remove-orphans
docker image prune -f
if [[ "${APPLY_FIREWALL}" == "1" ]]; then
  bash -s < ${REMOTE_CONFIG_DIR}/apply-ufw.sh
fi
EOF
fi

rm -f "$DOCKER_COMPOSE_TMP"
rm -f "$NGINX_TMP"
