import com.android.build.gradle.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    plugins.withId("com.android.library") {
        extensions.findByType(LibraryExtension::class.java)?.let { androidExt ->
            if (androidExt.namespace.isNullOrBlank()) {
                val manifestFile = project.file("src/main/AndroidManifest.xml")
                val manifestPackage =
                    if (manifestFile.exists()) {
                        Regex("package\\s*=\\s*\"([^\"]+)\"")
                            .find(manifestFile.readText())
                            ?.groupValues
                            ?.getOrNull(1)
                    } else {
                        null
                    }

                if (!manifestPackage.isNullOrBlank()) {
                    androidExt.namespace = manifestPackage
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
