import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
	id("org.springframework.boot") version "3.2.1"
	id("io.spring.dependency-management") version "1.1.4"
	id("com.google.cloud.tools.jib") version "3.4.2"
	kotlin("jvm") version "1.9.21"
	kotlin("plugin.spring") version "1.9.21"
}

group = "dk.ufst.appudvikling"
version = "0.0.1-SNAPSHOT"

java {
	sourceCompatibility = JavaVersion.VERSION_17
}

repositories {
	mavenCentral()
}

dependencies {
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
	// implementation(libs.spring.security.oauth2.jose)
	implementation(libs.springboot.oauth2.resource.server)

	implementation(enforcedPlatform(libs.springboot.dependencies))

	runtimeOnly(libs.h2database)

	implementation(libs.bundles.jackson)
	implementation(libs.kotlin.reflect)
	implementation(libs.liquibase)

	runtimeOnly(libs.postgresql)

	testImplementation(libs.junit.jupiter.api)
	testRuntimeOnly(libs.junit.jupiter.engine)

	// swagger
	implementation(libs.springdoc.openapi.starter.webmvc)

	implementation(libs.bundles.exposed)
	implementation(libs.firebase)

	// logging
	implementation("org.apache.logging.log4j:log4j-core:2.20.0")
	implementation("org.apache.logging.log4j:log4j-api:2.20.0")
}

configurations {
	all {
		exclude(group = "org.springframework.boot", module = "spring-boot-starter-logging")
	}
}

tasks.withType<KotlinCompile> {
	kotlinOptions {
		freeCompilerArgs += "-Xjsr305=strict"
		jvmTarget = "17"
	}
}

tasks.withType<Test> {
	useJUnitPlatform()
}

jib {
	jib.from.image = "eclipse-temurin:17-jdk"
	jib.to.image = "nicolaidam/feedback:latest"
	container {
		ports = listOf("8080")
	}
}
