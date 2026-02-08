#!/bin/bash
echo "Building Master Deutsch APK..."
flutter clean
flutter pub get
if flutter build apk --debug; then
    cp build/app/outputs/apk/debug/app-debug.apk ~/Desktop/MasterDeutsch.apk
    echo "APK created: ~/Desktop/MasterDeutsch.apk"
else
    echo "Flutter build failed, checking Gradle..."
    cd android
    chmod +x gradlew
    ./gradlew --version
    ./gradlew clean
    ./gradlew assembleDebug
    if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
        cp app/build/outputs/apk/debug/app-debug.apk ~/Desktop/MasterDeutsch.apk
        echo "APK created: ~/Desktop/MasterDeutsch.apk"
    else
        echo "Build failed. Let's check the error."
        ./gradlew assembleDebug --stacktrace
    fi
fi
