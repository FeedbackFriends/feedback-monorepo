import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
	id("org.springframework.boot") version "3.2.1"
	id("io.spring.dependency-management") version "1.1.4"
	kotlin("jvm") version "1.9.21"
	kotlin("plugin.spring") version "1.9.21"

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
		image = "nicolaidam/feedback:0.0.20"
		auth {
			username = System.getenv("DOCKER_USERNAME")
			password = System.getenv("DOCKER_PASSWORD")
		}
	}
}
//jib {
//	dockerClient {
//		executable = "/usr/local/bin/docker"
//	}
//	from {
//		image = "openjdk:17-jdk"
//	}
//	to {
//		image = "nicolaidam/feedback:0.0.11"
//	}
//	extraDirectories {
//		paths {
//			path {
//				// copies the contents of 'src/main/another/dir' into '/extras' on the container
//				from { file("config") }
//				into = "/app/config"
//			}
////			path {
////				from { file("firebase_config.json") }
////				into = "/app/config"
////			}
//		}
//	}
//}
