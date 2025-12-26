plugins {
    kotlin("jvm") version libs.versions.kotlin
    id("org.owasp.dependencycheck") version "9.0.10"
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
    apply(plugin = "org.owasp.dependencycheck")
}

dependencyCheck {
    failBuildOnCVSS = 7.0f
    formats = listOf("HTML", "SARIF")
    nvd {
        apiKey = System.getenv("NVD_API_KEY")
    }
}
