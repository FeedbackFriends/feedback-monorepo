//plugins {
//    alias(libs.plugins.jib)
//    id("org.springdoc.openapi-gradle-plugin") version "1.9.0"
//}
//
//dependencies {
//
//    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core")
//    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")
//
//    implementation(projects.persistence)
//    implementation(projects.model)
//
//    implementation(libs.springboot.data.jpa)
//    implementation(libs.springboot.web)
//    implementation(libs.springboot.actuator)
//
//    developmentOnly(libs.springboot.devtools)
//    testImplementation(libs.springboot.test)
//
//    implementation(libs.springboot.security)
//    implementation(libs.springboot.test)
//    implementation(libs.spring.security.test)
//    implementation(libs.springboot.oauth2.resource.server)
//    implementation(enforcedPlatform(libs.springboot.dependencies))
//    implementation(libs.bundles.jackson)
//    implementation(libs.kotlin.reflect)
//    testImplementation(libs.junit.jupiter.api)
//    testRuntimeOnly(libs.junit.jupiter.engine)
//    implementation(libs.springdoc.openapi.starter.webmvc)
//    implementation(libs.firebase)
//}
//
//tasks.withType<Test> {
//    useJUnitPlatform()
//}
//
//jib {
//    dockerClient {
//        executable = "/usr/local/bin/docker"
//    }
//    from {
//        image = "eclipse-temurin:17-jre"
//    }
//    to {
//        auth {
//            username = System.getenv("DOCKER_USERNAME")
//            password = System.getenv("DOCKER_PASSWORD")
//        }
//    }
//}
//
//openApi {
//    apiDocsUrl.set("http://localhost:8080/v3/api-docs.yaml")
//    outputFileName.set("openapi.yaml")
//    waitTimeInSeconds.set(15)
//}

import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompilationTask
import org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile

plugins {
    alias(libs.plugins.springboot) version "3.2.1"
    id("io.spring.dependency-management") version "1.1.4"
    kotlin("jvm") version libs.versions.kotlin
    kotlin("plugin.spring") version libs.versions.kotlin
    id("com.google.cloud.tools.jib") version "3.4.4"
    id("org.springdoc.openapi-gradle-plugin") version "1.9.0"
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

    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")

    implementation(projects.persistence)
    implementation(projects.model)

    implementation(libs.springboot.data.jpa)
    implementation(libs.springboot.web)
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
    implementation(libs.springdoc.openapi.starter.webmvc)
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


if (hasProperty("buildScan")) {
    extensions.findByName("buildScan")?.withGroovyBuilder {
        setProperty("termsOfServiceUrl", "https://gradle.com/terms-of-service")
        setProperty("termsOfServiceAgree", "yes")
    }
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

openApi {
    apiDocsUrl.set("http://localhost:8080/v3/api-docs.yaml")
    outputFileName.set("openapi.yaml")
    waitTimeInSeconds.set(15)
}
