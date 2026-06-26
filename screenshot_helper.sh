#!/bin/bash

# App Store Screenshot Helper Script
# Automates the process of creating professional screenshots

set -e

PROJECT_DIR="/Volumes/Data/Projects/eleven_plus_vocabulary"
DESKTOP="$HOME/Desktop"
OUTPUT_DIR="$DESKTOP/AppStore_Screenshots"

echo "📸 App Store Screenshot Generator"
echo "=================================="
echo ""

# Function to check if simulator is running
check_simulator() {
    if xcrun simctl list devices | grep -q "Booted"; then
        return 0
    else
        return 1
    fi
}

# Function to count screenshots
count_screenshots() {
    ls "$DESKTOP"/Simulator*.png 2>/dev/null | wc -l | tr -d ' '
}

# Main menu
echo "Choose an option:"
echo ""
echo "1) Launch app on simulator (iPhone 16 Pro Max)"
echo "2) Generate marketing screenshots from captured images"
echo "3) Full workflow (launch app + wait for screenshots)"
echo "4) Test with existing screenshot"
echo "5) Open output folder"
echo "6) Clean up screenshots"
echo ""
read -p "Enter choice (1-6): " choice

case $choice in
    1)
        echo ""
        echo "🚀 Launching app on iPhone 16 Pro Max simulator..."
        echo ""
        cd "$PROJECT_DIR"
        flutter run -d "iPhone 16 Pro Max"
        ;;

    2)
        echo ""
        COUNT=$(count_screenshots)
        echo "📸 Found $COUNT screenshot(s) on Desktop"

        if [ "$COUNT" -eq 0 ]; then
            echo ""
            echo "❌ No screenshots found!"
            echo ""
            echo "To capture screenshots:"
            echo "  1. Make sure the app is running on simulator"
            echo "  2. Navigate to each key screen"
            echo "  3. Press ⌘+S to capture"
            echo "  4. Run this script again and choose option 2"
            echo ""
            exit 1
        fi

        echo ""
        echo "🎨 Generating professional marketing screenshots..."
        echo ""
        cd "$PROJECT_DIR"
        python3 create_appstore_screenshots.py "$DESKTOP" "$OUTPUT_DIR"

        echo ""
        echo "✅ Done! Opening output folder..."
        open "$OUTPUT_DIR"
        ;;

    3)
        echo ""
        echo "🚀 Starting full workflow..."
        echo ""
        echo "Step 1: Launching app..."
        cd "$PROJECT_DIR"

        # Launch in background
        echo "Starting simulator (this takes 2-3 minutes)..."
        flutter run -d "iPhone 16 Pro Max" &
        FLUTTER_PID=$!

        echo ""
        echo "⏳ Waiting for app to launch..."
        echo ""
        echo "📸 CAPTURE SCREENSHOTS NOW:"
        echo "   1. Library screen (⌘+S)"
        echo "   2. Practice session (⌘+S)"
        echo "   3. Test results (⌘+S)"
        echo "   4. Review screen (⌘+S)"
        echo "   5. Stats dashboard (⌘+S)"
        echo ""
        echo "When done, press Ctrl+C in this terminal, then:"
        echo "  ./screenshot_helper.sh"
        echo "  Choose option 2 to generate marketing screenshots"
        echo ""

        wait $FLUTTER_PID
        ;;

    4)
        echo ""
        echo "🧪 Testing with existing screenshot..."
        echo ""
        cd "$PROJECT_DIR"
        python3 create_appstore_screenshots.py "$DESKTOP" "$OUTPUT_DIR"

        if [ -d "$OUTPUT_DIR" ]; then
            echo ""
            echo "✅ Test complete! Opening output folder..."
            open "$OUTPUT_DIR"
        fi
        ;;

    5)
        echo ""
        if [ -d "$OUTPUT_DIR" ]; then
            echo "📁 Opening $OUTPUT_DIR"
            open "$OUTPUT_DIR"
        else
            echo "❌ Output folder doesn't exist yet"
            echo "Run option 2 or 4 to generate screenshots first"
        fi
        ;;

    6)
        echo ""
        echo "🧹 Cleaning up screenshots..."

        COUNT=$(count_screenshots)
        if [ "$COUNT" -gt 0 ]; then
            echo "Found $COUNT simulator screenshot(s)"
            read -p "Delete simulator screenshots from Desktop? (y/n): " confirm
            if [ "$confirm" = "y" ]; then
                rm "$DESKTOP"/Simulator*.png
                echo "✅ Deleted simulator screenshots"
            fi
        else
            echo "No simulator screenshots to clean"
        fi

        if [ -d "$OUTPUT_DIR" ]; then
            read -p "Delete generated marketing screenshots? (y/n): " confirm
            if [ "$confirm" = "y" ]; then
                rm -rf "$OUTPUT_DIR"
                echo "✅ Deleted marketing screenshots folder"
            fi
        fi

        echo "Done!"
        ;;

    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "=================================="
echo "✨ Process complete!"

