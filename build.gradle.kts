import org.jetbrains.kotlin.gradle.tasks.KotlinCompilationTask
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    alias(libs.plugins.springboot) version "3.2.1"
	id("io.spring.dependency-management") version "1.1.4"
    kotlin("jvm") version libs.versions.kotlin
    kotlin("plugin.spring") version libs.versions.kotlin
	id("com.google.cloud.tools.jib") version libs.versions.jib
	id("org.springdoc.openapi-gradle-plugin") version "1.9.0"
}

java {
	sourceCompatibility = JavaVersion.VERSION_17
}

repositories {
	mavenCentral()
}

val compileKotlin: KotlinCompilationTask<*> by tasks
compileKotlin.compilerOptions.allWarningsAsErrors.set(true)

tasks.withType<KotlinCompile> {
	kotlinOptions {
		freeCompilerArgs += "-Xjsr305=strict"
		jvmTarget = "17"
	}
}

tasks.withType<Test> {
	useJUnitPlatform()
}

tasks.bootJar {
	enabled = false
}

tasks.bootRun {
	enabled = false
}

if (hasProperty("buildScan")) {
	extensions.findByName("buildScan")?.withGroovyBuilder {
		setProperty("termsOfServiceUrl", "https://gradle.com/terms-of-service")
		setProperty("termsOfServiceAgree", "yes")
	}
}

subprojects {
    apply(plugin = "org.springframework.boot")
    apply(plugin = "io.spring.dependency-management")
    apply(plugin = "org.jetbrains.kotlin.jvm")
    apply(plugin = "org.jetbrains.kotlin.plugin.spring")

    kotlin {
        jvmToolchain(21)
        compilerOptions {
            freeCompilerArgs.add("-Xjsr305=strict")
        }
    }
}
