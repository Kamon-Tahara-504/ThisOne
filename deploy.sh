#!/bin/bash

# Android実機にアプリをビルド&デプロイするスクリプト

echo "Building APK..."
cd android
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" ./gradlew assembleDebug --quiet

if [ $? -eq 0 ]; then
    echo " Build successful!"
    cd ..
    
    echo " Installing to device..."
    export PATH="$PATH:/Users/kt/Library/Android/sdk/platform-tools"
    adb install -r android/app/build/outputs/apk/debug/app-debug.apk
    
    if [ $? -eq 0 ]; then
        echo "Installation successful!"
        echo "Launching app..."
        adb shell am force-stop com.example.thisone
        sleep 1
        adb shell am start -n com.example.thisone/.MainActivity
        
        echo ""
        echo "Viewing logs (Ctrl+C to stop)..."
        sleep 2
        adb logcat -s flutter:I | grep -v "SEC_SF_EFFECTS\|GameManager"
    else
        echo " Installation failed"
        exit 1
    fi
else
    echo "Build failed"
    cd ..
    exit 1
fi

