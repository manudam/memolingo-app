#!/bin/bash

# iPad Screenshot Generator - Landscape Marketing Screenshots
# Creates professional App Store screenshots for iPad with text overlays at the bottom

set -e

PROJECT_DIR="/Volumes/Data/Projects/eleven_plus_vocabulary"
DESKTOP="$HOME/Desktop"
OUTPUT_DIR="$DESKTOP/AppStore_Screenshots_iPad"

echo "📱 iPad Screenshot Generator for App Store"
echo "==========================================="
echo ""

# Function to count screenshots
count_screenshots() {
    ls "$DESKTOP"/Simulator*.png 2>/dev/null | wc -l | tr -d ' '
}

echo "Choose iPad size:"
echo ""
echo "1) iPad Pro 12.9\" (Landscape) - 2732x2048 [Recommended]"
echo "2) iPad Pro 11\" (Landscape) - 2388x1668"
echo "3) iPad Pro 10.5\" (Landscape) - 2224x1668"
echo "4) Launch app on iPad simulator first"
echo "5) Generate from existing screenshots"
echo ""
read -p "Enter choice (1-5): " choice

case $choice in
    1)
        DEVICE_TYPE="ipad_129_landscape"
        SIMULATOR_NAME="iPad Pro (12.9-inch)"
        ;;
    2)
        DEVICE_TYPE="ipad_11_landscape"
        SIMULATOR_NAME="iPad Pro (11-inch)"
        ;;
    3)
        DEVICE_TYPE="ipad_105_landscape"
        SIMULATOR_NAME="iPad Pro (10.5-inch)"
        ;;
    4)
        echo ""
        echo "Available iPad simulators:"
        echo ""
        xcrun simctl list devices | grep "iPad" | grep -v "unavailable"
        echo ""
        read -p "Enter iPad name (e.g., 'iPad Pro (12.9-inch)'): " SIMULATOR_NAME
        echo ""
        echo "🚀 Launching app on $SIMULATOR_NAME..."
        echo ""
        echo "⚠️  IMPORTANT: Rotate to LANDSCAPE mode!"
        echo "   • Press ⌘+→ or ⌘+← to rotate simulator"
        echo ""
        cd "$PROJECT_DIR"
        flutter run -d "$SIMULATOR_NAME"
        exit 0
        ;;
    5)
        echo ""
        read -p "Which iPad size? (1=12.9\", 2=11\", 3=10.5\"): " size_choice
        case $size_choice in
            1) DEVICE_TYPE="ipad_129_landscape" ;;
            2) DEVICE_TYPE="ipad_11_landscape" ;;
            3) DEVICE_TYPE="ipad_105_landscape" ;;
            *) echo "Invalid choice"; exit 1 ;;
        esac
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

if [ "$choice" != "4" ]; then
    echo ""
    COUNT=$(count_screenshots)
    echo "📸 Found $COUNT screenshot(s) on Desktop"

    if [ "$COUNT" -eq 0 ]; then
        echo ""
        echo "❌ No screenshots found!"
        echo ""
        echo "📸 To capture iPad landscape screenshots:"
        echo "   1. Run this script and choose option 4"
        echo "   2. Rotate simulator to LANDSCAPE (⌘+→ or ⌘+←)"
        echo "   3. Navigate to each screen and press ⌘+S:"
        echo "      • Library screen"
        echo "      • Practice session"
        echo "      • Test results"
        echo "      • Review screen"
        echo "      • Stats dashboard"
        echo "   4. Run this script again and choose your iPad size"
        echo ""
        exit 1
    fi

    echo ""
    echo "🎨 Generating professional iPad marketing screenshots..."
    echo "   Device: $DEVICE_TYPE"
    echo "   Layout: Landscape with bottom text overlay"
    echo ""
    cd "$PROJECT_DIR"
    python3 create_appstore_screenshots.py "$DESKTOP" "$OUTPUT_DIR" "$DEVICE_TYPE"

    echo ""
    echo "✅ Done! Opening output folder..."
    open "$OUTPUT_DIR"

    echo ""
    echo "📤 Upload these to App Store Connect:"
    echo "   1. Go to App Store Connect"
    echo "   2. Select 11+ Vocabulary Master > App Store"
    echo "   3. Find iPad screenshots section"
    echo "   4. Upload the generated screenshots"
    echo ""
fi

