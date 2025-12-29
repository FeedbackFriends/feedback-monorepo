plugins {
    kotlin("plugin.spring") version libs.versions.kotlin
    alias(libs.plugins.springboot)
    alias(libs.plugins.spring.dependencies)
}

dependencies {
    implementation(projects.model)

    implementation(libs.springboot.starter)

    implementation(libs.ical4j)

    testImplementation(libs.springboot.starter.test)
    testImplementation(libs.kotlin.test.junit5)
}

tasks.bootJar {
    enabled = false
}

tasks.bootRun {
    enabled = false
}

tasks.withType<Test> {
    useJUnitPlatform()
}
