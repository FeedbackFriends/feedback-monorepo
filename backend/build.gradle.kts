import io.spring.gradle.dependencymanagement.dsl.DependencyManagementExtension
import org.gradle.api.artifacts.VersionCatalogsExtension
import org.gradle.api.tasks.Copy

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

tasks.register<Copy>("syncOpenApiSpec") {
    group = "documentation"
    description = "Generates the API OpenAPI spec and copies it to the monorepo contracts directory."

    dependsOn(":api:generateOpenApiDocs")

    from(layout.projectDirectory.dir("apps/api/build")) {
        include("openapi.yaml")
        rename { "feedback-api.yaml" }
    }
    into(layout.projectDirectory.dir("../contracts/openapi"))
}
