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
        extensions.configure(LibraryExtension::class.java) {
            // Old Flutter plugins may still be on compileSdk 30, which breaks
            // resource linking with modern AndroidX (e.g. android:attr/lStar requires 31+).
            if ((compileSdk ?: 0) < 31) {
                compileSdk = 34
            }

            if (namespace.isNullOrBlank()) {
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
                    namespace = manifestPackage
                }
            }
        }
    }

    if (name == "isar_flutter_libs") {
        tasks.matching { it.name == "verifyReleaseResources" }.configureEach {
            enabled = false
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
