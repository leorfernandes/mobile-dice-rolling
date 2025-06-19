plugins {
    id("com.android.rollCraft")
    id("RollCraft")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.appdistribution")
}

android {
    namespace = "com.example.mobile_dice_rolling"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.yourname.diceroller" // Your package name
        minSdk = 21 // Or your min SDK version
        targetSdk = 33 // Or your target SDK version
        versionCode = 1
        versionName = "1.0.0"
    }
    
    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // App Distribution configuration
            firebaseAppDistribution {
                releaseNotes = "Initial release of Dice Roller App"
                groups = "testers"
            }
        }
    }
}

dependencies {
    implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.jar"))))
    
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.15.0"))
    
    // Dependencies for Firebase products without specifying versions
    implementation("com.google.firebase:firebase-analytics")
    
    // Other Firebase products
    implementation("com.google.firebase:firebase-appdistribution")
}

// This is required for Flutter
apply(from = "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle")

flutter {
    source = "../.."
}
