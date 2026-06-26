# 📸 Screenshot Creation Guide - Step by Step

## Current Status

✅ App is launching on iPhone 16 simulator
✅ Marketing screenshot generator script created
✅ Ready to capture screenshots

---

## Step 1: Wait for App to Load (2-3 minutes)

The app is currently building and will launch automatically in the iPhone 16 simulator.

**Look for:**

- Simulator window opens
- App launches and shows the main screen
- No loading or error messages

---

## Step 2: Capture 5 Key Screenshots

Once the app is running, navigate to each screen and capture using **⌘+S** (Command+S).

### Screenshot 1: Library Screen 📚

1. Navigate to Library tab (bottom navigation)
2. Make sure you can see:
    - Multiple vocabulary packs (owned and available)
    - Pack prices visible
    - "Restore Purchases" button at bottom
    - Stats overview at top
3. Press **⌘+S** to capture
4. Screenshot saves to Desktop

### Screenshot 2: Practice Session 🎯

1. Go to Practice tab
2. Select any vocabulary pack
3. Start a practice session
4. When you see a question with 4 answer options:
    - Make sure the word is visible
    - Audio/TTS icon showing
    - Progress bar at top
5. Press **⌘+S** to capture

### Screenshot 3: Test Results 🎉

1. Complete the practice session (answer a few questions)
2. When you reach the completion screen showing:
    - Your score percentage
    - Mastery level badge
    - "Review Test Results" button
3. Press **⌘+S** to capture

### Screenshot 4: Review Screen 📝

1. From the completion screen, tap "Review Test Results"
2. Make sure you can see:
    - Mix of correct (green) and incorrect (red) answers
    - Your wrong answer + correct answer displayed
    - At least 3-4 questions visible
3. Press **⌘+S** to capture

### Screenshot 5: Stats Screen 📊

1. Navigate to Stats tab (bottom navigation)
2. Make sure you can see:
    - Overall Progress card
    - Mastery Levels chart
    - Recent Activity section
    - All stat cards aligned properly
3. Press **⌘+S** to capture

---

## Step 3: Generate Marketing Screenshots

After capturing all 5 screenshots, run the Python script:

```bash
cd /Volumes/Data/Projects/eleven_plus_vocabulary
python3 create_marketing_screenshots.py
```

**What this does:**

- Finds your 5 screenshots on Desktop
- Adds professional text overlays:
    - Screenshot 1: "Master 450+ Essential 11+ Exam Vocabulary Words"
    - Screenshot 2: "Interactive Practice with Audio Pronunciation"
    - Screenshot 3: "Track Your Progress & Master Every Word"
    - Screenshot 4: "Learn from Mistakes - Review Every Answer"
    - Screenshot 5: "Monitor Your Journey - Stats & Achievements"
- Saves marketing screenshots to: `~/Desktop/AppStore_Screenshots/`

---

## Step 4: Verify Marketing Screenshots

1. Open Finder
2. Navigate to Desktop → AppStore_Screenshots folder
3. Open each PNG file
4. Check that:
    - ✅ Text overlays are visible and readable
    - ✅ Text doesn't cover important UI elements
    - ✅ Image quality is good
    - ✅ All 5 screenshots generated correctly

---

## Step 5: Upload to App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select "11+ Vocabulary Master"
3. Go to "App Store" tab
4. Scroll to "App Previews and Screenshots"
5. Select device size: **6.7" Display** (iPhone 16 Pro)
6. Click "+" to add screenshots
7. Upload all 5 marketing screenshots in order
8. Drag to reorder if needed
9. Click "Save"

---

## 🎨 Screenshot Order Matters!

Upload in this specific order:

1. Library (shows content)
2. Practice (shows core feature)
3. Results (shows progress)
4. Review (shows learning)
5. Stats (shows gamification)

This tells a story: Browse → Practice → Progress → Learn → Track

---

## ⚠️ Troubleshooting

### "Screenshots save as .tiff not .png"

- Simulator saves as PNG by default
- Check Desktop for PNG files
- If TIFF, convert: `sips -s format png *.tiff --out .`

### "Python script not working"

Install Pillow (image library):

```bash
pip3 install Pillow
```

### "Text overlays too dark/light"

Edit `create_marketing_screenshots.py`:

- Line 14-17: Adjust colors
- Line 34: Change alpha (transparency) value

### "Can't find screenshots"

Check these locations:

- Desktop (default location)
- Documents folder
- Run: `find ~/Desktop -name "*.png" -mtime -1`

---

## 📏 Different Device Sizes (If Needed)

For complete App Store submission, you may need additional sizes:

### iPhone 14/15 Plus (6.5" Display)

```bash
# Set simulator
xcrun simctl boot "iPhone 14 Plus"
flutter run -d "iPhone 14 Plus"
# Capture same 5 screenshots
# Run script again
```

### iPhone 8 Plus (5.5" Display)

```bash
xcrun simctl boot "iPhone 8 Plus"
flutter run -d "iPhone 8 Plus"
# Capture same 5 screenshots
# Run script again
```

---

## ✅ Quick Checklist

Before moving on:

- [ ] App running in simulator
- [ ] 5 screenshots captured (check Desktop)
- [ ] Python script executed successfully
- [ ] Marketing screenshots in AppStore_Screenshots folder
- [ ] Verified all 5 look good
- [ ] Ready to upload to App Store Connect

---

## 💡 Pro Tips

1. **Hide debug UI:** The orange debug button won't show in release screenshots, but in debug mode
   it will. Just avoid capturing it in frame.

2. **Perfect timing:** Wait for animations to complete before capturing.

3. **Clean data:** If stats look empty, do a few practice sessions first to populate data.

4. **Bright colors:** Make sure simulator display brightness is at 100%.

5. **Consistent state:** All screenshots should show the app in a consistent, polished state.

---

## Next Steps After Screenshots

1. ✅ Capture and generate marketing screenshots (this guide)
2. Upload screenshots to App Store Connect
3. Write app description
4. Set keywords
5. Add privacy policy URL
6. Submit for review

---

**Estimated Time:** 20-30 minutes total

- Capture: 10 minutes
- Generate: 2 minutes
- Verify: 5 minutes
- Upload: 10 minutes

Good luck! 🚀

