plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.safeguard.frontend"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    signingConfigs {
        // MODIFICA QUI: Cambiato nome da "debug" a "sharedDebug" per evitare conflitti
        create("sharedDebug") {
            // Cerca il file dentro la cartella 'frontend/android/app/'
            storeFile = file("debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.safeguard.frontend"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("debug") {
            // MODIFICA QUI: Usiamo la configurazione "sharedDebug" creata sopra
            signingConfig = signingConfigs.getByName("sharedDebug")
        }

        getByName("release") {
            // Anche per la release (temporaneamente) usiamo la chiave condivisa
            signingConfig = signingConfigs.getByName("sharedDebug")
        }
    }
}

flutter {
    source = "../.."
}