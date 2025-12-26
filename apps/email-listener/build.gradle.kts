plugins {
    alias(libs.plugins.jib)
    kotlin("plugin.spring") version libs.versions.kotlin
    alias(libs.plugins.springboot)
    alias(libs.plugins.spring.dependencies)
}

dependencies {
    implementation(projects.persistence)
    implementation(projects.model)
    implementation(projects.icalParser)

    implementation(libs.springboot.starter)
    implementation(libs.springboot.mail)
    implementation(libs.sentry.spring.boot.starter)
    implementation(libs.sentry.logback)

    runtimeOnly(libs.postgres)

    testImplementation(libs.springboot.starter.test)
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
    to {
        image = "nicolaidam/feedback-email-listener:${project.version}"
        auth {
            username = System.getenv("DOCKER_USERNAME")
            password = System.getenv("DOCKER_PASSWORD")
        }
    }
}
