#!/bin/bash
echo "Building Master Deutsch APK..."
flutter clean
flutter pub get
if flutter build apk --debug --no-sound-null-safety; then
    cp build/app/outputs/apk/debug/app-debug.apk ~/Desktop/MasterDeutsch.apk
    echo "APK created: ~/Desktop/MasterDeutsch.apk"
else
    echo "Flutter build failed, trying Gradle..."
    cd android
    chmod +x gradlew
    if ./gradlew assembleDebug; then
        cp app/build/outputs/apk/debug/app-debug.apk ~/Desktop/MasterDeutsch.apk
        echo "APK created: ~/Desktop/MasterDeutsch.apk"
    else
        echo "Build failed. Check errors above."
    fi
fi
