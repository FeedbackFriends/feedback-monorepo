import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompilationTask
import org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile

plugins {
    alias(libs.plugins.springboot) version "3.2.1"
    id("io.spring.dependency-management") version "1.1.4"
    kotlin("jvm") version libs.versions.kotlin
    kotlin("plugin.spring") version libs.versions.kotlin
    id("com.google.cloud.tools.jib") version "3.4.4"
}

group = "dk.nicolai"
version = "0.0.5"

java {
    sourceCompatibility = JavaVersion.VERSION_17
}

repositories {
    mavenCentral()
}

val compileKotlin: KotlinCompilationTask<*> by tasks
compileKotlin.compilerOptions.allWarningsAsErrors.set(true)

dependencies {
    implementation(projects.persistence)
    implementation(projects.model)
    // Spring Boot
    implementation(libs.springboot.data.jpa)
    implementation(libs.springboot.mail)
    implementation(libs.springboot.web)
    implementation(libs.springboot.validation)
    implementation(libs.springboot.actuator)

    developmentOnly(libs.springboot.devtools)
    testImplementation(libs.springboot.test)

    implementation(libs.springboot.security)
    implementation(libs.springboot.test)
    implementation(libs.spring.security.test)
    implementation(libs.springboot.oauth2.resource.server)

    implementation(enforcedPlatform(libs.springboot.dependencies))

    implementation(libs.bundles.jackson)
    implementation(libs.kotlin.reflect)

    testImplementation(libs.junit.jupiter.api)
    testRuntimeOnly(libs.junit.jupiter.engine)

    // swagger
    implementation(libs.springdoc.openapi.starter.webmvc)

    implementation(libs.bundles.exposed)
    implementation(libs.firebase)
}

tasks.withType<KotlinJvmCompile>().configureEach {
    compilerOptions {
        freeCompilerArgs.add("-Xjsr305=strict")
        jvmTarget.set(JvmTarget.JVM_17)
    }
}
tasks.withType<Test> {
    useJUnitPlatform()
}


jib {
    dockerClient {
        executable = "/usr/local/bin/docker"
    }
    from {
        image = "eclipse-temurin:17-jre"
    }
    to {
        auth {
            username = System.getenv("DOCKER_USERNAME")
            password = System.getenv("DOCKER_PASSWORD")
        }
    }
}
