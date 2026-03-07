FROM gradle:8.5-jdk17 AS build

WORKDIR /workspace/backend

COPY backend .

RUN set -eux; \
    ./gradlew --no-daemon :scheduler:bootJar -x test; \
    app_jar="$(find apps/scheduler/build/libs -maxdepth 1 -type f -name '*.jar' ! -name '*-plain.jar' | head -n 1)"; \
    [ -n "${app_jar}" ]; \
    install -m 0644 "${app_jar}" /workspace/app.jar

FROM eclipse-temurin:17-jre

WORKDIR /app

RUN set -eux; \
    groupadd --system --gid 10001 app; \
    useradd --system --uid 10001 --gid 10001 --home /app --shell /usr/sbin/nologin app

COPY --from=build /workspace/app.jar /app/app.jar

ENV PORT=8080
ENV MANAGEMENT_SERVER_PORT=8091
ENV SPRING_PROFILES_ACTIVE=prod

USER 10001:10001

CMD ["sh", "-ec", "if [ -n \"${SPRING_DATASOURCE_URL:-}\" ] && [ \"${SPRING_DATASOURCE_URL#jdbc:}\" = \"${SPRING_DATASOURCE_URL}\" ]; then export SPRING_DATASOURCE_URL=\"jdbc:${SPRING_DATASOURCE_URL}\"; fi; exec java ${JAVA_OPTS:--Xmx512m} -Dserver.port=\"${PORT:-8080}\" ${MANAGEMENT_SERVER_PORT:+-Dmanagement.server.port=${MANAGEMENT_SERVER_PORT}} -jar /app/app.jar"]
