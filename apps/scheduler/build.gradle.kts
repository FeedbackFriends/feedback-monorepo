plugins {
    alias(libs.plugins.jib)
}

dependencies {
    implementation(projects.persistence)
    implementation(projects.model)
    implementation(projects.firebase)

    implementation(libs.springboot.data.jpa)
    implementation(libs.springboot.mail)
    implementation(libs.springboot.web)
    implementation(libs.springboot.actuator)

    developmentOnly(libs.springboot.devtools)
    testImplementation(libs.springboot.test)


//    implementation(enforcedPlatform(libs.springboot.dependencies))

    implementation(libs.bundles.jackson)
    implementation(libs.kotlin.reflect)
    implementation(libs.ical4j)

    testImplementation(libs.junit.jupiter.api)
    testRuntimeOnly(libs.junit.jupiter.engine)
    implementation(libs.firebase)
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
