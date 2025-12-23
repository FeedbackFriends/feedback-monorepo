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
    // Spring Boot dependencies
    implementation(libs.springboot.starter)
    implementation(libs.springboot.starter.validation)
    implementation(libs.springboot.starter.web)
    implementation(libs.bundles.jackson)
    implementation(libs.ical4j)
    implementation(libs.firebase)
    implementation(libs.springboot.mail)
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
        image = "nicolaidam/feedback-scheduler:${project.version}"
        auth {
            username = System.getenv("DOCKER_USERNAME")
            password = System.getenv("DOCKER_PASSWORD")
        }
    }
}
