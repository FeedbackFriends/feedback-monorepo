dependencies {
    implementation(libs.jackson.module.kotlin)
}

tasks.bootJar {
    enabled = false
}

tasks.bootRun {
    enabled = false
}
