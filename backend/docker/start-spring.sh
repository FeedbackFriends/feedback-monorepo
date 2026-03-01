#!/bin/sh
set -eu

# Render Postgres exposes a postgresql:// connection string. Convert that to
# the jdbc:postgresql:// form Spring expects if an explicit JDBC URL is absent.
if [ -n "${DATABASE_URL:-}" ] && [ -z "${SPRING_DATASOURCE_URL:-}" ]; then
  stripped="${DATABASE_URL#postgresql://}"
  stripped="${stripped#postgres://}"
  host_and_db="${stripped#*@}"
  host_and_db="${host_and_db%%\?*}"
  host="${host_and_db%%/*}"
  db="${host_and_db#*/}"

  if [ "${host}" = "${host_and_db}" ] || [ -z "${db}" ]; then
    echo "Unable to derive SPRING_DATASOURCE_URL from DATABASE_URL" >&2
    exit 1
  fi

  export SPRING_DATASOURCE_URL="jdbc:postgresql://${host}/${db}"
fi

management_args=""
if [ -n "${MANAGEMENT_SERVER_PORT:-}" ]; then
  management_args="-Dmanagement.server.port=${MANAGEMENT_SERVER_PORT}"
fi

exec sh -c "java ${JAVA_OPTS:--Xmx512m} -Dserver.port=${PORT:-8080} ${management_args} -jar /app/app.jar"
