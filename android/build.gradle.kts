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
    
    // Force compileSdk 36 for all modules to support newest androidx libraries
    project.afterEvaluate {
        if (project.plugins.hasPlugin("com.android.library") || project.plugins.hasPlugin("com.android.application")) {
             project.extensions.configure<com.android.build.gradle.BaseExtension> {
                 compileSdkVersion(35)
             }
        }
    }
    project.configurations.all {
        resolutionStrategy {
            force("androidx.core:core:1.15.0")
            force("androidx.core:core-ktx:1.15.0")
            force("androidx.activity:activity:1.9.3")
            force("androidx.activity:activity-ktx:1.9.3")
            force("androidx.browser:browser:1.8.0")
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Fix for Isarlibs namespace missing in AGP 8+
// Fix for Isarlibs namespace missing in AGP 8+
subprojects {
    val project = this
    if (project.name == "isar_flutter_libs") {
        if (project.state.executed) {
             fixIsarNamespace(project)
        } else {
             project.afterEvaluate {
                 fixIsarNamespace(project)
             }
        }
    }
    // Fix for Telephony namespace missing in AGP 8+
    if (project.name == "telephony") {
        if (project.state.executed) {
             fixTelephonyNamespace(project)
        } else {
             project.afterEvaluate {
                 fixTelephonyNamespace(project)
             }
        }
    }
}

fun fixIsarNamespace(project: Project) {
    val android = project.extensions.findByName("android")
    if (android != null) {
        try {
            val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
            setNamespace.invoke(android, "dev.isar.isar_flutter_libs")
            println("Fixed namespace for isar_flutter_libs")
        } catch (e: Exception) {
            println("Failed to set namespace for isar_flutter_libs: ${e.message}")
        }
    }
}

fun fixTelephonyNamespace(project: Project) {
    val android = project.extensions.findByName("android")
    if (android != null) {
        try {
            val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
            setNamespace.invoke(android, "com.shounakmulay.telephony")
            println("Fixed namespace for telephony")
        } catch (e: Exception) {
            println("Failed to set namespace for telephony: ${e.message}")
        }
    }
}
