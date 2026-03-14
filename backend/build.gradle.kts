import io.spring.gradle.dependencymanagement.dsl.DependencyManagementExtension
import org.gradle.api.artifacts.VersionCatalogsExtension

plugins {
    kotlin("jvm") version libs.versions.kotlin
    alias(libs.plugins.spring.dependencies) apply false
}

val versionCatalog = extensions.getByType<VersionCatalogsExtension>().named("libs")
val assertjVersion = versionCatalog.findVersion("assertj").get().requiredVersion
val commonsCompressVersion = versionCatalog.findVersion("commonsCompress").get().requiredVersion
val commonsLang3Version = versionCatalog.findVersion("commonsLang3").get().requiredVersion
val grpcVersion = versionCatalog.findVersion("grpc").get().requiredVersion
val jacksonVersion = versionCatalog.findVersion("jackson").get().requiredVersion
val logbackVersion = versionCatalog.findVersion("logback").get().requiredVersion
val forcedDependencies =
    listOf(
        "org.apache.commons:commons-compress:$commonsCompressVersion",
    ) +
        listOf(
            "grpc-alts",
            "grpc-api",
            "grpc-auth",
            "grpc-context",
            "grpc-core",
            "grpc-googleapis",
            "grpc-grpclb",
            "grpc-inprocess",
            "grpc-netty-shaded",
            "grpc-opentelemetry",
            "grpc-protobuf",
            "grpc-protobuf-lite",
            "grpc-rls",
            "grpc-services",
            "grpc-stub",
            "grpc-util",
            "grpc-xds",
        ).map { "io.grpc:$it:$grpcVersion" }

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
            }

            dependencies {
                dependency("org.assertj:assertj-core:$assertjVersion")
                dependency("org.apache.commons:commons-lang3:$commonsLang3Version")
                dependency("ch.qos.logback:logback-classic:$logbackVersion")
                dependency("ch.qos.logback:logback-core:$logbackVersion")
            }
        }
    }

    configurations.configureEach {
        resolutionStrategy.force(*forcedDependencies.toTypedArray())
    }
}
