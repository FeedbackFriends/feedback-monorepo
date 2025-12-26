plugins {
    kotlin("jvm") version libs.versions.kotlin
}

repositories {
    mavenCentral()
}

kotlin {
    jvmToolchain(17)
    compilerOptions {
        freeCompilerArgs.addAll("-Xjsr305=strict")
    }
}

subprojects {
    apply(plugin = "org.jetbrains.kotlin.jvm")
}
