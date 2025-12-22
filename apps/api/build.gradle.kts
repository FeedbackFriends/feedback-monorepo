plugins {
    alias(libs.plugins.jib)
    id("org.springdoc.openapi-gradle-plugin") version "1.9.0"
}

dependencies {

    testRuntimeOnly(libs.junit.jupiter.engine)
    developmentOnly(libs.springboot.devtools)

    implementation(projects.persistence)
    implementation(projects.model)
    implementation(projects.firebase)
    implementation(libs.springboot.data.jpa)
    implementation(libs.springboot.web)
    implementation(libs.springboot.actuator)
    implementation(libs.springboot.security)
    implementation(libs.spring.security.test)
    implementation(libs.springboot.oauth2.resource.server)
    implementation(enforcedPlatform(libs.springboot.dependencies))
    implementation(libs.bundles.jackson)
    implementation(libs.kotlin.reflect)
    implementation(libs.springdoc.openapi.starter.webmvc)
    implementation(libs.firebase)
    implementation(libs.jackson.module.kotlin)

    // TODO: Remove
    implementation(libs.junit.jupiter.api)
    implementation(libs.springboot.test)

    testImplementation(libs.junit.jupiter.api)
    testImplementation(libs.springboot.test)
    testImplementation(libs.h2database)
    implementation(libs.liquibase)
    testImplementation(libs.bundles.exposed)
    testImplementation(libs.spring.security.test)
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test")

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
