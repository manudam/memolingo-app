#!/bin/bash

# Final Production Build Script for 11+ Vocabulary Master
# Version 1.0.1 (Build 10)
# This script creates a production-ready build for App Store submission

set -e  # Exit on error

PROJECT_DIR="/Volumes/Data/Projects/eleven_plus_vocabulary"
APP_NAME="11+ Vocabulary Master"
VERSION="1.0.1"
BUILD_NUMBER="14"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║        Final Production Build - $APP_NAME        ║"
echo "║                    Version $VERSION (Build $BUILD_NUMBER)                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

cd "$PROJECT_DIR"

echo "📋 Pre-Build Checklist:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Not in Flutter project directory"
    exit 1
fi

echo "✅ Project directory verified"

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter not found in PATH"
    exit 1
fi

echo "✅ Flutter installation verified"

# Check for iOS certificates
if [ ! -d "ios/Runner.xcworkspace" ]; then
    echo "⚠️  Warning: iOS workspace not found"
fi

echo ""
echo "🧹 Step 1: Clean Previous Builds"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
flutter clean
echo "✅ Clean complete"

echo ""
echo "📦 Step 2: Get Dependencies"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
flutter pub get
echo "✅ Dependencies updated"

echo ""
echo "🔍 Step 3: Run Code Analysis"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
flutter analyze || echo "⚠️  Analysis warnings found (review but continuing)"

echo ""
echo "🏗️  Step 4: Build iOS Archive"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Building for App Store distribution..."
echo ""

flutter build ipa \
  --release \
  --no-codesign \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ iOS Build Complete!"
    echo ""

    # Check if archive was created
    if [ -d "build/ios/archive/Runner.xcarchive" ]; then
        ARCHIVE_SIZE=$(du -sh build/ios/archive/Runner.xcarchive | cut -f1)
        echo "📦 Archive Location: build/ios/archive/Runner.xcarchive"
        echo "📊 Archive Size: $ARCHIVE_SIZE"
    fi

    # Check if IPA was created (might not exist with --no-codesign)
    if [ -f "build/ios/ipa/eleven_plus_vocabulary.ipa" ]; then
        IPA_SIZE=$(du -sh build/ios/ipa/eleven_plus_vocabulary.ipa | cut -f1)
        echo "📦 IPA Location: build/ios/ipa/eleven_plus_vocabulary.ipa"
        echo "📊 IPA Size: $IPA_SIZE"
    fi
else
    echo ""
    echo "❌ iOS Build Failed!"
    echo "Please check the errors above and try again."
    exit 1
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                  ✅ BUILD COMPLETE!                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "📁 Build Artifacts:"
echo "   • Archive: build/ios/archive/Runner.xcarchive"
echo "   • Symbols: build/app/outputs/symbols/"
echo ""
echo "🚀 Next Steps for App Store Submission:"
echo ""
echo "   Option 1: Upload via Xcode (Recommended)"
echo "   ----------------------------------------"
echo "   1. Open Xcode: open ios/Runner.xcworkspace"
echo "   2. Product > Archive"
echo "   3. Window > Organizer"
echo "   4. Select archive > Distribute App"
echo "   5. Choose 'App Store Connect'"
echo "   6. Follow the wizard"
echo ""
echo "   Option 2: Upload via Transporter"
echo "   ----------------------------------------"
echo "   1. Open 'Transporter' app (from App Store)"
echo "   2. Drag build/ios/archive/Runner.xcarchive"
echo "   3. Click 'Deliver'"
echo ""
   Option 3: Upload Screenshots
   ----------------------------------------
   1. Go to: https://appstoreconnect.apple.com
   2. My Apps > $APP_NAME
   3. Upload screenshots from:
echo "      • ~/Desktop/AppStore_Screenshots/ (iPhone)"
echo "      • ~/Desktop/AppStore_Screenshots_iPad/ (iPad)"
echo ""
echo "📖 Detailed guides available:"
echo "   • TESTFLIGHT_UPLOAD_GUIDE.md"
echo "   • APP_STORE_SUBMISSION_CHECKLIST.md"
echo "   • QUICK_UPLOAD_GUIDE.md"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""

