#!/bin/bash
set -e

echo "🚀 Building Master Deutsch APK..."
cd "$(dirname "$0")"

# Clean build
echo "📦 Cleaning previous build..."
flutter clean

# Get dependencies
echo "📥 Getting dependencies..."
flutter pub get

# Build release APK
echo "🔨 Building release APK..."
flutter build apk --release

# Install to device
echo "📱 Installing to connected device..."
adb install -r build/app/outputs/apk/release/app-release.apk

echo "✅ Build and installation complete!"
echo ""
echo "🎉 New features installed:"
echo "   • Daily Challenge with streak tracking"
echo "   • Mistake Review with grammar tips"
echo "   • Fixed Start Quiz icon visibility"
echo "   • Level filtering (tap A1 → see only A1.1 & A1.2)"
