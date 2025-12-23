plugins {
    kotlin("plugin.spring") version libs.versions.kotlin
    alias(libs.plugins.springboot)
    alias(libs.plugins.spring.dependencies)
}

dependencies {
    implementation(libs.jackson.module.kotlin)
//    implementation(libs.springboot.web)

    implementation(libs.springboot.starter)
    implementation(libs.springboot.starter.validation)
    implementation(libs.springboot.starter.web)


    implementation(libs.firebase)
    implementation(projects.model)
}

tasks.bootJar {
    enabled = false
}

tasks.bootRun {
    enabled = false
}
