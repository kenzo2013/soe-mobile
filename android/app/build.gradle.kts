import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

/** Reads `android/<name>` when it exists (both files below are generated and gitignored). */
fun loadProperties(name: String): Properties {
    val properties = Properties()
    val file = rootProject.file(name)
    if (file.exists()) file.inputStream().use { properties.load(it) }
    return properties
}

// App identity (SOE or SOE Test), written by scripts/build.sh and scripts/run.sh into
// android/env.properties. Without that file (fresh clone, plain `flutter run`), the build is
// the production app.
val envProperties = loadProperties("env.properties")
val appId: String = envProperties.getProperty("APP_ID", "cm.soe.mobile")
val appName: String = envProperties.getProperty("APP_NAME", "SOE")
val appIcon: String = envProperties.getProperty("APP_ICON", "ic_launcher")

// Play upload key: android/key.properties + keys/upload-keystore.jks, restored from Doppler by
// scripts/build.sh. Without them, release builds fall back to the debug keys so that
// `flutter run --release` keeps working locally (Play refuses such a build).
val keyProperties = loadProperties("key.properties")
val hasUploadKey = keyProperties.getProperty("storeFile") != null

android {
    namespace = "cm.soe.mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        if (hasUploadKey) {
            create("release") {
                // Relative to android/ (e.g. ../keys/upload-keystore.jks).
                storeFile = rootProject.file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    defaultConfig {
        // The namespace stays cm.soe.mobile: only the installed identity varies.
        applicationId = appId
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        resValue("string", "app_name", appName)
        manifestPlaceholders["appIcon"] = "@mipmap/$appIcon"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (hasUploadKey) "release" else "debug")
        }
    }
}

flutter {
    source = "../.."
}
