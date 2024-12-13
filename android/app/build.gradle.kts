plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    ndkVersion = "27.0.12077973"
    namespace = "com.monacosimone.yesplus.yesplus"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }

    flavorDimensions += "client"
    productFlavors {
        create("standard") {
            dimension = "client"
            applicationIdSuffix = ".standard"
            versionNameSuffix = "-standard"
            applicationId = "com.monacosimone.yesplus"
            versionName = "1.0.0"
            resValue("string", "app_name", "YesPlus")
            /* ndk {
                abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a", "x86", "x86_64"))
            } */
        }
        create("gelomare") {
            dimension = "client"
            applicationIdSuffix = ".gelomare"
            versionNameSuffix = "-gelomare"
            applicationId = "com.monacosimone.yesplus"
            versionName = "1.0.0"
            resValue("string", "app_name", "Yes+ Gelomare")
            /* ndk {
                abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a", "x86", "x86_64"))
            } */
        }
        create("mcfood") {
            dimension = "client"
            applicationIdSuffix = ".mcfood"
            versionNameSuffix = "-mcfood"
            applicationId = "com.monacosimone.yesplus"
            versionName = "1.0.0"
            resValue("string", "app_name", "Yes+ McFood")
            /* ndk {
                abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a", "x86", "x86_64"))
            } */
        }
    }

    defaultConfig {
        applicationId = "com.monacosimone.yesplus.yesplus"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    splits {
        abi {
            isEnable = false // Disabilita la suddivisione per ABI
        }
    }
    
    signingConfigs {
       /*  release {
            keyAlias 'key0'
            keyPassword '20YesPlus24!'
            storeFile file('/Users/simonemonaco/Sviluppo/flutter/yesplus/yesplus')
            storePassword '20YesPlus24!'
        } */
         create("release") {
            keyAlias = "key0"
            keyPassword = "20YesPlus24!"
            storeFile = file("yesplus.jks")
            storePassword = "20YesPlus24!"
        }
    }

    buildTypes {
        getByName("release") {
            isDebuggable = true // Use isDebuggable instead of debuggable
            signingConfig = signingConfigs.getByName("release")
        }
    }


}

flutter {
    source = "../.."
}