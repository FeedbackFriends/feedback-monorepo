plugins {
    alias(libs.plugins.springboot)
    kotlin("plugin.spring") version libs.versions.kotlin
}

dependencies {
    implementation(projects.model)
    runtimeOnly(libs.h2database)
    runtimeOnly(libs.liquibase.core)
    runtimeOnly(libs.postgres)
    implementation(libs.exposed.springboot.starter)
    implementation(libs.exposed.javatime)
}
tasks.bootJar {
    enabled = false
}
tasks.bootRun {
    enabled = false
}
