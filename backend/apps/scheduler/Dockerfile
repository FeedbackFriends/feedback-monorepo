FROM gradle:8.5-jdk17 AS build

WORKDIR /workspace/backend

# Copy Gradle metadata first so dependency resolution can be cached.
COPY backend/gradle ./gradle
COPY backend/gradlew backend/gradlew.bat backend/build.gradle.kts backend/settings.gradle.kts backend/gradle.properties ./
COPY backend/apps/api/build.gradle.kts ./apps/api/build.gradle.kts
COPY backend/apps/scheduler/build.gradle.kts ./apps/scheduler/build.gradle.kts
COPY backend/lib/model/build.gradle.kts ./lib/model/build.gradle.kts
COPY backend/lib/persistence/build.gradle.kts ./lib/persistence/build.gradle.kts
COPY backend/lib/firebase/build.gradle.kts ./lib/firebase/build.gradle.kts
COPY backend/lib/ical-parser/build.gradle.kts ./lib/ical-parser/build.gradle.kts

RUN ./gradlew --no-daemon :scheduler:dependencies

COPY backend/apps ./apps
COPY backend/lib ./lib

RUN ./gradlew --no-daemon :scheduler:bootJar -x test

FROM eclipse-temurin:17-jre

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends dumb-init \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /workspace/backend/apps/scheduler/build/libs/*.jar /app/app.jar

ENV PORT=8080
ENV MANAGEMENT_SERVER_PORT=8091
ENV SPRING_PROFILES_ACTIVE=prod

ENTRYPOINT ["dumb-init", "--"]
CMD ["sh", "-c", "if [ -n \"${SPRING_DATASOURCE_URL:-}\" ] && [ \"${SPRING_DATASOURCE_URL#jdbc:}\" = \"${SPRING_DATASOURCE_URL}\" ]; then export SPRING_DATASOURCE_URL=\"jdbc:${SPRING_DATASOURCE_URL}\"; fi; exec java ${JAVA_OPTS:--Xmx512m} -Dserver.port=${PORT:-8080} ${MANAGEMENT_SERVER_PORT:+-Dmanagement.server.port=${MANAGEMENT_SERVER_PORT}} -jar /app/app.jar"]
