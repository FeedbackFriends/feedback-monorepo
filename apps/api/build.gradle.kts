plugins {
    alias(libs.plugins.jib)
    alias(libs.plugins.openapi)
    kotlin("plugin.spring") version libs.versions.kotlin
    alias(libs.plugins.springboot)
    alias(libs.plugins.spring.dependencies)
}

dependencies {
    implementation(projects.persistence)
    implementation(projects.model)
    implementation(projects.firebase)

    implementation(libs.springboot.starter)
    implementation(libs.springboot.starter.validation)
    implementation(libs.springboot.starter.web)
    implementation(libs.springboot.security)
    implementation(libs.springboot.oauth2.resource.server)

    implementation(libs.springdoc.openapi.starter.webmvc)

    implementation(libs.bundles.jackson)
    implementation(libs.springdoc.openapi.starter.webmvc)
    implementation(libs.firebase)

    runtimeOnly(libs.liquibase.core)
    runtimeOnly(libs.postgres)

    testImplementation(libs.springboot.starter.test)
    testImplementation(libs.springboot.testcontainers)
    testImplementation(libs.testcontainers.postgresql)
    testImplementation(libs.kotlin.test.junit5)
    testRuntimeOnly(libs.h2)
    testRuntimeOnly(libs.junit.platform.launcher)
}

tasks.withType<Test> {
    useJUnitPlatform()
}

// Generate build metadata so Spring can read the build version at runtime.
springBoot {
    buildInfo()
}

jib {
    from {
        image = "eclipse-temurin:21-jdk"
    }
    to {
        image = "nicolaidam/feedback-api:${project.version}"
        auth {
            username = System.getenv("DOCKER_USERNAME")
            password = System.getenv("DOCKER_PASSWORD")
        }
    }
}

openApi {
    apiDocsUrl.set("http://localhost:8080/v3/api-docs.yaml")
    outputFileName.set("openapi.yaml")
    waitTimeInSeconds.set(15)
}
