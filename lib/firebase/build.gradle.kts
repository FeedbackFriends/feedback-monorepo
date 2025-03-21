dependencies {
    implementation(libs.jackson.module.kotlin)
    implementation(libs.springboot.data.jpa)
    implementation(libs.springboot.web)
    implementation(libs.springboot.actuator)
    implementation(libs.springboot.security)
    implementation(libs.spring.security.test)
    implementation(libs.firebase)
    implementation(projects.model)
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")
}
