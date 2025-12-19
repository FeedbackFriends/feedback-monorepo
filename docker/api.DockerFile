FROM gradle:8.5-jdk21 AS builder
WORKDIR /home/gradle/project

# Copy Gradle wrapper and core build files first to leverage Docker layer caching.
COPY gradlew gradlew.bat settings.gradle.kts build.gradle.kts gradle.properties ./
COPY gradle/ gradle/
RUN chmod +x gradlew

# Copy only build scripts to warm dependency caches without invalidating on source changes.
COPY apps/api/build.gradle.kts apps/api/
COPY apps/scheduler/build.gradle.kts apps/scheduler/
COPY lib/model/build.gradle.kts lib/model/
COPY lib/firebase/build.gradle.kts lib/firebase/
COPY lib/persistence/build.gradle.kts lib/persistence/
RUN ./gradlew --no-daemon :api:dependencies

# Bring in the full source tree for the actual build.
COPY . .
RUN ./gradlew --no-daemon :api:clean :api:build -x test

FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
COPY --from=builder /home/gradle/project/apps/api/build/libs/api.jar app.jar
CMD ["java", "-jar", "app.jar"]
