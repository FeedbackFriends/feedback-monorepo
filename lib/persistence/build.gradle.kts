plugins {
    alias(libs.plugins.springboot)
    kotlin("plugin.spring") version libs.versions.kotlin
}

dependencies {
    implementation(projects.model)
    implementation(libs.exposed.springboot.starter)
    implementation(libs.exposed.javatime)
}
tasks.bootJar {
    enabled = false
}
tasks.bootRun {
    enabled = false
}
