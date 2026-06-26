# 📸 Professional App Store Screenshots - Complete Guide

## Quick Start

### Option 1: iPhone Screenshots (Portrait)

If you already have screenshots and want to test:

```bash
cd /Volumes/Data/Projects/eleven_plus_vocabulary
python3 create_appstore_screenshots.py ~/Desktop ~/Desktop/AppStore_Screenshots
```

### Option 2: iPad Screenshots (Landscape) ✨ NEW!

For iPad with landscape orientation and right-side text:

```bash
cd /Volumes/Data/Projects/eleven_plus_vocabulary
./ipad_screenshot_helper.sh
```

📖 **See detailed guide:** `IPAD_SCREENSHOTS_GUIDE.md`

### Option 3: Capture Full Set (Recommended)

Follow the step-by-step guide below to capture all 5 screenshots.

---

## 📱 Step 1: Launch App on Simulator

```bash
# Navigate to project
cd /Volumes/Data/Projects/eleven_plus_vocabulary

# Launch on iPhone 16 Pro Max (best for App Store)
flutter run -d "iPhone 16 Pro Max"
```

**Wait for:** App to fully load (2-3 minutes)

---

## 📸 Step 2: Capture 5 Key Screenshots

Use **⌘+S** (Command+S) in the simulator to capture each screen.

### Screenshot 1: 📚 Library Screen

**What to show:**

- Navigate to Library tab
- Multiple vocabulary packs visible (owned + available)
- Pack prices showing
- Nice stats overview at top
- "Restore Purchases" button visible

**Press:** ⌘+S

### Screenshot 2: 🎯 Practice Session

**What to show:**

- Go to Practice tab
- Select any pack and start practice
- Show a question with 4 answer options
- Word clearly visible
- Audio/speaker icon showing
- Progress indicator at top

**Press:** ⌘+S

### Screenshot 3: 🎉 Test Results

**What to show:**

- Complete the practice (answer a few questions)
- Results screen showing:
    - Score percentage
    - Mastery level badge
    - "Review Test Results" button
    - Congratulations message

**Press:** ⌘+S

### Screenshot 4: 📝 Review Screen

**What to show:**

- From results, tap "Review Test Results"
- Show mix of correct (green) and incorrect (red) answers
- Your answer vs correct answer visible
- At least 3-4 questions on screen
- Clear visual feedback

**Press:** ⌘+S

### Screenshot 5: 📊 Stats Dashboard

**What to show:**

- Navigate to Stats tab
- Overall Progress card visible
- Mastery Levels chart
- Recent Activity section
- Multiple stat cards showing data
- Nice clean layout

**Press:** ⌘+S

---

## 🎨 Step 3: Generate Marketing Screenshots

After capturing all screenshots, run the generator:

```bash
cd /Volumes/Data/Projects/eleven_plus_vocabulary
python3 create_appstore_screenshots.py
```

**This will:**
✅ Find your simulator screenshots on Desktop  
✅ Add professional text overlays with your app's colors  
✅ Add feature badges (📚 5 Complete Sets, 🔊 TTS Enabled, etc.)  
✅ Save marketing-ready PNGs to `~/Desktop/AppStore_Screenshots/`

---

## 📤 Step 4: Upload to App Store Connect

1. **Open:** [App Store Connect](https://appstoreconnect.apple.com)
2. **Navigate:** My Apps → 11+ Vocabulary Master → App Store tab
3. **Scroll to:** "App Previews and Screenshots" section
4. **Select:** 6.7" Display (iPhone 16 Pro Max)
5. **Upload:** The 5 generated screenshots in this order:
    - `1_library_screen.png`
    - `2_practice_session.png`
    - `3_test_results.png`
    - `4_review_screen.png`
    - `5_stats_dashboard.png`
6. **Save** your changes

---

## 🎯 Why This Order Matters

The screenshot order tells a story:

1. **Library** → "Here's what you get"
2. **Practice** → "Here's how it works"
3. **Results** → "Here's your progress"
4. **Review** → "Here's how you learn"
5. **Stats** → "Here's your journey"

Users see the first 2-3 screenshots most, so make them count!

---

## 🛠 Advanced Options

### Different Device Size

```bash
# iPhone 14 Plus (6.5" display)
python3 create_appstore_screenshots.py ~/Desktop ~/Desktop/AppStore_Screenshots iphone_65

# iPhone 16 (6.1" display)
python3 create_appstore_screenshots.py ~/Desktop ~/Desktop/AppStore_Screenshots iphone_61
```

### Custom Locations

```bash
python3 create_appstore_screenshots.py /path/to/input /path/to/output
```

### Test with Single Screenshot

```bash
# Will process any existing simulator screenshots on Desktop
python3 create_appstore_screenshots.py
```

---

## ✅ Quality Checklist

Before uploading, verify each screenshot:

- [ ] Text overlays are clear and readable
- [ ] Text doesn't cover important UI elements
- [ ] App content is visible and looks professional
- [ ] No personal/test data visible
- [ ] Images are sharp (not blurry)
- [ ] Proper aspect ratio (no stretching)
- [ ] File size under 2MB each
- [ ] Resolution matches device size

---

## 🎨 Customizing Text Overlays

Edit `create_appstore_screenshots.py` to customize:

```python
SCREENSHOTS = [
    {
        "title": "Your Custom Title",  # Line ~30
        "subtitle": "Your Custom Subtitle",
        "badge": "🎯 Your Badge Text",
    },
    # ... more configs
]
```

### Color Customization

```python
PRIMARY_BLUE = (37, 99, 235)  # Line ~18 - Change to your brand color
```

---

## 🐛 Troubleshooting

### "No screenshots found"

- Check Desktop for files named "Simulator Screenshot - ..."
- Screenshots save automatically to Desktop when you press ⌘+S
- Try: `ls ~/Desktop/Simulator*.png`

### "Pillow not installed"

```bash
pip3 install Pillow
```

### "Wrong size screenshots"

- Make sure you're using iPhone 16 Pro Max simulator
- The script will auto-resize, but native size is best

### "Text too big/small"

The script uses responsive sizing based on image width. If needed:

- Edit line ~110: `title_font = get_font(int(width * 0.065))`
- Decrease multiplier (0.065) for smaller text
- Increase for larger text

### "Colors don't match app"

- Check your app's primary color in `lib/main.dart`
- Update `PRIMARY_BLUE` constant in the script (line 18)

---

## 💡 Pro Tips

1. **Test on real device first** - Make sure app looks perfect
2. **Use fresh data** - Don't show "0 words learned"
3. **Show variety** - Mix of owned/unowned packs, some progress
4. **Clean UI** - No error messages or loading states
5. **Good timing** - Capture when UI is fully rendered
6. **Bright screens** - Stats and progress look better with data

---

## 📏 App Store Requirements

Apple's screenshot requirements:

| Device       | Size (px)   | Required |
|--------------|-------------|----------|
| 6.7" Display | 1290 x 2796 | ✅ Yes    |
| 6.5" Display | 1284 x 2778 | Optional |
| 5.5" Display | 1242 x 2208 | Optional |

**Minimum:** 3 screenshots  
**Recommended:** 5 screenshots  
**Maximum:** 10 screenshots

---

## 🚀 Quick Commands Reference

```bash
# 1. Launch app
flutter run -d "iPhone 16 Pro Max"

# 2. After capturing screenshots (⌘+S in simulator)
python3 create_appstore_screenshots.py

# 3. Open output folder
open ~/Desktop/AppStore_Screenshots

# 4. Check what you captured
ls -la ~/Desktop/Simulator*.png

# 5. Get help
python3 create_appstore_screenshots.py --help
```

---

## 📞 Need Help?

Check these files:

- `SCREENSHOT_GUIDE.md` - Original guide
- `create_appstore_screenshots.py` - Enhanced generator
- `APP_STORE_SUBMISSION_CHECKLIST.md` - Complete submission guide

---

**Ready to create amazing screenshots? Let's go! 🚀**

