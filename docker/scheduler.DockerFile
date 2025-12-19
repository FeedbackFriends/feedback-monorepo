FROM gradle:8.5-jdk21 AS builder
WORKDIR /home/gradle/project

# Copy Gradle wrapper and shared build metadata up front for better caching.
COPY gradlew gradlew.bat settings.gradle.kts build.gradle.kts gradle.properties ./
COPY gradle/ gradle/
RUN chmod +x gradlew

# Copy only build scripts to pre-fetch dependencies without invalidating on source edits.
COPY apps/api/build.gradle.kts apps/api/
COPY apps/scheduler/build.gradle.kts apps/scheduler/
COPY lib/model/build.gradle.kts lib/model/
COPY lib/firebase/build.gradle.kts lib/firebase/
COPY lib/persistence/build.gradle.kts lib/persistence/
RUN ./gradlew --no-daemon :scheduler:dependencies

# Copy the full source tree and build the scheduler artifact.
COPY . .
RUN ./gradlew --no-daemon :scheduler:clean :scheduler:build -x test

FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
COPY --from=builder /home/gradle/project/apps/scheduler/build/libs/scheduler.jar app.jar
CMD ["java", "-jar", "app.jar"]
