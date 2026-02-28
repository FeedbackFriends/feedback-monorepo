#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "${SCRIPT_DIR}/../.." && pwd)
ENV_FILE="${ROOT_DIR}/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing .env at repo root: ${ENV_FILE}" >&2
  exit 1
fi

set -a
source "${ENV_FILE}"
set +a

if [[ -z "${SPRING_DATASOURCE_URL:-}" ]]; then
  echo "SPRING_DATASOURCE_URL is not set in ${ENV_FILE}" >&2
  exit 1
fi

SPRING_DATASOURCE_USERNAME="${SPRING_DATASOURCE_USERNAME:-postgres}"
SPRING_DATASOURCE_PASSWORD="${SPRING_DATASOURCE_PASSWORD:-postgres}"

if ! command -v psql >/dev/null 2>&1; then
  echo "psql is required to reset the database." >&2
  exit 1
fi
URL_PREFIX="jdbc:postgresql://"
if [[ "${SPRING_DATASOURCE_URL}" != "${URL_PREFIX}"* ]]; then
  echo "SPRING_DATASOURCE_URL must start with ${URL_PREFIX}" >&2
  exit 1
fi

URL_NO_PREFIX="${SPRING_DATASOURCE_URL#${URL_PREFIX}}"
HOSTPORT="${URL_NO_PREFIX%%/*}"
DB_NAME="feedback_db"

if [[ -z "${HOSTPORT}" || -z "${DB_NAME}" ]]; then
  echo "Could not parse host or database name from SPRING_DATASOURCE_URL." >&2
  exit 1
fi

DB_HOST="${HOSTPORT%%:*}"
DB_PORT="${HOSTPORT#*:}"
if [[ "${DB_HOST}" == "${HOSTPORT}" ]]; then
  DB_PORT="5432"
fi

if [[ -z "${DB_HOST}" || -z "${DB_PORT}" ]]; then
  echo "Could not parse host or port from SPRING_DATASOURCE_URL." >&2
  exit 1
fi

echo "Resetting ${DB_NAME} on ${DB_HOST}:${DB_PORT}..."

PGPASSWORD="${SPRING_DATASOURCE_PASSWORD:-}" \
psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${SPRING_DATASOURCE_USERNAME}" -d postgres -v ON_ERROR_STOP=1 <<SQL
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = '${DB_NAME}' AND pid <> pg_backend_pid();
DROP DATABASE IF EXISTS "${DB_NAME}";
CREATE DATABASE "${DB_NAME}" OWNER "${SPRING_DATASOURCE_USERNAME}";
SQL

echo "Database reset complete."
