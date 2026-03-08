plugins {
    alias(libs.plugins.jib)
    kotlin("plugin.spring") version libs.versions.kotlin
    alias(libs.plugins.springboot)
    alias(libs.plugins.spring.dependencies)
}

dependencies {

    implementation(projects.persistence)
    implementation(projects.model)
    implementation(projects.firebase)
    implementation(projects.icalParser)

    implementation(libs.springboot.starter)
    implementation(libs.springboot.starter.actuator)
    implementation(libs.springboot.starter.validation)
    implementation(libs.springboot.starter.web)

    implementation(libs.bundles.jackson)

    implementation(libs.firebase)

    runtimeOnly(libs.liquibase.core)
    runtimeOnly(libs.postgres)

    testImplementation(libs.springboot.starter.test)
    testImplementation(libs.springboot.testcontainers)
    testImplementation(libs.testcontainers.postgresql)
    testImplementation(libs.kotlin.test.junit5)
    runtimeOnly(libs.h2)
    testRuntimeOnly(libs.junit.platform.launcher)
}

tasks.withType<Test> {
    useJUnitPlatform()
}

tasks.withType<com.google.cloud.tools.jib.gradle.BuildDockerTask>().configureEach {
    notCompatibleWithConfigurationCache("Jib Docker task is not configuration-cache compatible in this setup.")
}

// Generate build metadata so Spring can read the build version at runtime.
springBoot {
    buildInfo()
}

jib {
    from {
        image = "eclipse-temurin:21-jre"
    }
    to {
        image = "nicolaidam/feedback-scheduler:${project.version}"
        auth {
            username = System.getenv("DOCKER_USERNAME")
            password = System.getenv("DOCKER_PASSWORD")
        }
    }
}
