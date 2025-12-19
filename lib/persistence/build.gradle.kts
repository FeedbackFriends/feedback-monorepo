dependencies {
    implementation(projects.model)
    runtimeOnly(libs.h2database)
    implementation(libs.liquibase)
    runtimeOnly(libs.postgresql)
    implementation(libs.bundles.exposed)
}
tasks.bootJar {
    enabled = false
}
tasks.bootRun {
    enabled = false
}
