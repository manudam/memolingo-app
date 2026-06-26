#!/bin/bash

# Google Play Store Release Build Script
# This script builds a signed Android App Bundle ready for Google Play Store upload

set -e  # Exit on error

echo "=========================================="
echo "11+ Vocabulary Master - Play Store Build"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}Error: pubspec.yaml not found. Please run this script from the project root.${NC}"
    exit 1
fi

# Check for key.properties
if [ ! -f "android/key.properties" ]; then
    echo -e "${RED}Error: android/key.properties not found.${NC}"
    echo "Please create it from key.properties.template with your signing keys."
    exit 1
fi

echo -e "${YELLOW}Step 1: Cleaning previous builds...${NC}"
flutter clean
echo -e "${GREEN}✓ Clean complete${NC}"
echo ""

echo -e "${YELLOW}Step 2: Getting dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies updated${NC}"
echo ""

echo -e "${YELLOW}Step 3: Running code analysis...${NC}"
flutter analyze || echo -e "${YELLOW}⚠ Warning: Some analysis issues found (continuing anyway)${NC}"
echo ""

echo -e "${YELLOW}Step 4: Building Android App Bundle (release)...${NC}"
flutter build appbundle --release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Build successful!${NC}"
else
    echo -e "${RED}✗ Build failed!${NC}"
    exit 1
fi

echo ""
echo "=========================================="
echo -e "${GREEN}Build Complete!${NC}"
echo "=========================================="
echo ""
echo "App Bundle location:"
echo "  build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "File size:"
ls -lh build/app/outputs/bundle/release/app-release.aab | awk '{print "  " $5}'
echo ""
echo "Next steps:"
echo "  1. Go to Google Play Console: https://play.google.com/console"
echo "  2. Select your app (or create new app if first release)"
echo "  3. Navigate to Production > Create new release"
echo "  4. Upload: build/app/outputs/bundle/release/app-release.aab"
echo "  5. Fill in release notes from pubspec.yaml version"
echo "  6. Review and roll out to production"
echo ""
echo "Version info from pubspec.yaml:"
grep "^version:" pubspec.yaml
echo ""
echo "Don't forget to:"
echo "  - Update store listing if needed"
echo "  - Add release notes"
echo "  - Test on internal track first (recommended)"
echo "  - Review Data Safety declarations"
echo "  - Ensure privacy policy URL is correct"
echo ""
echo -e "${GREEN}Good luck with your release! 🚀${NC}"
echo ""

