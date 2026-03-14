import io.spring.gradle.dependencymanagement.dsl.DependencyManagementExtension
import org.gradle.api.artifacts.VersionCatalogsExtension

plugins {
    kotlin("jvm") version libs.versions.kotlin
    alias(libs.plugins.spring.dependencies) apply false
}

val versionCatalog = extensions.getByType<VersionCatalogsExtension>().named("libs")
val commonsLang3Version = versionCatalog.findVersion("commonsLang3").get().requiredVersion
val jacksonVersion = versionCatalog.findVersion("jackson").get().requiredVersion
val testcontainersVersion = versionCatalog.findVersion("testcontainers").get().requiredVersion

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

    pluginManager.withPlugin("io.spring.dependency-management") {
        extensions.configure<DependencyManagementExtension>("dependencyManagement") {
            imports {
                mavenBom("com.fasterxml.jackson:jackson-bom:$jacksonVersion")
                mavenBom("org.testcontainers:testcontainers-bom:$testcontainersVersion")
            }

            dependencies {
                dependency("org.apache.commons:commons-lang3:$commonsLang3Version")
            }
        }
    }
}
