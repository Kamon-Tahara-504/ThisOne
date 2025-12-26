plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// key.propertiesファイルを読み込む
import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.tahara.thisone"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.tahara.thisone"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }

    // リリース署名設定
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // リリース署名を使用（key.propertiesが存在する場合）
            // 存在しない場合はデバッグ署名にフォールバック
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

// Flutterツールが期待する場所（プロジェクトルートのbuild/app/outputs/flutter-apk/）にAPKファイルをコピーするタスク
tasks.register("copyDebugApkToFlutterExpectedLocation") {
    doLast {
        val debugApkPath = file("${layout.buildDirectory.get()}/outputs/apk/debug/app-debug.apk")
        val projectRootDir = rootProject.projectDir.parentFile
        val expectedDir = file("$projectRootDir/build/app/outputs/flutter-apk")
        val expectedPath = file("$expectedDir/app-debug.apk")

        if (debugApkPath.exists()) {
            expectedDir.mkdirs()
            debugApkPath.copyTo(expectedPath, overwrite = true)
            println("Debug APK copied to Flutter expected location: $expectedPath")
        } else {
            println("Debug APK not found at: $debugApkPath")
        }
    }
}

// assembleDebugタスクの後にAPKをコピーするタスクを実行
tasks.configureEach {
    if (name == "assembleDebug") {
        finalizedBy("copyDebugApkToFlutterExpectedLocation")
    }
}
