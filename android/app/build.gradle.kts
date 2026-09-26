import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
// Local-only escape hatch: `flutter run --release -P allowDebugSigning=true`
// signs the release build with the debug key when key.properties is missing.
// Without it, release builds fail instead of silently shipping a debug-signed
// artifact.
val allowDebugSigning =
    (project.findProperty("allowDebugSigning") as String?)?.toBoolean() == true

android {
    namespace = "com.autocronica.carfaults"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Real package: register this exact ID + the debug/release SHA-1
        // fingerprints (`./gradlew signingReport`) as an Android OAuth
        // client in Google Cloud Console for Google Sign-In to work.
        applicationId = "com.autocronica.carfaults"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = when {
                hasReleaseKeystore -> signingConfigs.getByName("release")
                allowDebugSigning -> signingConfigs.getByName("debug")
                else -> null
            }
        }
    }
}

tasks.matching { it.name == "preReleaseBuild" }.configureEach {
    val missingReleaseKeystore = !hasReleaseKeystore && !allowDebugSigning
    doFirst {
        if (missingReleaseKeystore) {
            throw GradleException(
                "android/key.properties not found: refusing to build a release " +
                    "without the release signing key. Create key.properties, or " +
                    "pass -P allowDebugSigning=true for a local-only debug-signed build.",
            )
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
