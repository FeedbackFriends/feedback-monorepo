plugins {
    alias(libs.plugins.jib)
}

dependencies {
    implementation(projects.persistence)
    implementation(projects.model)

    implementation(libs.springboot.data.jpa)
    implementation(libs.springboot.mail)
    implementation(libs.springboot.web)
    implementation(libs.springboot.validation)
    implementation(libs.springboot.actuator)

    developmentOnly(libs.springboot.devtools)
    testImplementation(libs.springboot.test)

    implementation(libs.springboot.security)
    implementation(libs.springboot.test)
    implementation(libs.spring.security.test)
    implementation(libs.springboot.oauth2.resource.server)

    implementation(enforcedPlatform(libs.springboot.dependencies))

    implementation(libs.bundles.jackson)
    implementation(libs.kotlin.reflect)

    testImplementation(libs.junit.jupiter.api)
    testRuntimeOnly(libs.junit.jupiter.engine)
    implementation(libs.bundles.exposed)
    implementation(libs.firebase)
}

tasks.withType<Test> {
    useJUnitPlatform()
}

jib {
    dockerClient {
        executable = "/usr/local/bin/docker"
    }
    from {
        image = "eclipse-temurin:21-jre"
    }
    to {
        auth {
            username = System.getenv("DOCKER_USERNAME")
            password = System.getenv("DOCKER_PASSWORD")
        }
    }
}
