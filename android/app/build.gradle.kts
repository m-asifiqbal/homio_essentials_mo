import java.util.Base64

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// --dart-define / --dart-define-from-file values reach Gradle as base64 "KEY=value" pairs.
// Read so a release config file can also set the AdMob *app* id in the manifest.
val dartDefines: Map<String, String> = (project.findProperty("dart-defines") as String?)
    ?.split(",")
    ?.mapNotNull { entry ->
        val pair = String(Base64.getDecoder().decode(entry), Charsets.UTF_8).split("=", limit = 2)
        if (pair.size == 2) pair[0] to pair[1] else null
    }
    ?.toMap() ?: emptyMap()

android {
    namespace = "com.iqballabs.homiopedia"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.iqballabs.homiopedia"
        minSdk = maxOf(flutter.minSdkVersion, 23) // google_mobile_ads needs 23+
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // AdMob app id for AndroidManifest.xml; defaults to Google's TEST app id.
        manifestPlaceholders["admobAppId"] =
            dartDefines["ADMOB_APP_ID_ANDROID"]?.takeIf { it.isNotBlank() } ?: "ca-app-pub-3940256099942544~3347511713"
    }

    buildTypes {
        release {
            // TODO: release signing config before publishing.
            signingConfig = signingConfigs.getByName("debug")
            // Keep rules for WorkManager's reflective Room database (see proguard-rules.pro).
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
