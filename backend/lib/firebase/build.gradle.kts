plugins {
    kotlin("plugin.spring") version libs.versions.kotlin
    alias(libs.plugins.springboot)
    alias(libs.plugins.spring.dependencies)
}

dependencies {
    implementation(projects.model)

    implementation(libs.jackson.module.kotlin)

    implementation(libs.springboot.starter)
    implementation(libs.springboot.starter.validation)
    implementation(libs.springboot.starter.web)

    implementation(libs.firebase)
}

tasks.bootJar {
    enabled = false
}

tasks.bootRun {
    enabled = false
}
