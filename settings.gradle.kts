rootProject.name = "feedback"
enableFeaturePreview("TYPESAFE_PROJECT_ACCESSORS")

File("$rootDir", "apps").listFiles()?.forEach {
    if (it.isDirectory && File(it, "build.gradle.kts").exists()) {
        val pName = ":${it.name}"
        include(pName)
        project(pName).projectDir = file("$rootDir/apps/${it.name}")
    }
}
File("$rootDir", "lib").listFiles()?.forEach {
    if (it.isDirectory && File(it, "build.gradle.kts").exists()) {
        val pName = ":${it.name}"
        include(pName)
        project(pName).projectDir = file("$rootDir/lib/${it.name}")
    }
}
