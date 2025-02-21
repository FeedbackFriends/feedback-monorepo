import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompilationTask
import org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile

plugins {
    kotlin("jvm") version libs.versions.kotlin
    alias(libs.plugins.springboot) version "3.2.1"
    id("io.spring.dependency-management") version "1.1.4"
    kotlin("plugin.spring") version libs.versions.kotlin
}

group = "dk.example.feedback.persistence"

java {
    sourceCompatibility = JavaVersion.VERSION_17
}

repositories {
    mavenCentral()
}

val compileKotlin: KotlinCompilationTask<*> by tasks
compileKotlin.compilerOptions.allWarningsAsErrors.set(true)

dependencies {
    implementation(projects.model)
    runtimeOnly(libs.h2database)
    implementation(libs.liquibase)
    runtimeOnly(libs.postgresql)
    implementation(libs.bundles.exposed)
    implementation(libs.springboot.data.jpa)

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
