# 📱 iPad Screenshots Guide - Landscape with Marketing Overlays

## Overview

This guide helps you create professional iPad screenshots in **landscape orientation** with
marketing text overlays positioned on the **right side** of the screen.

---

## 🚀 Quick Start

### Option 1: Automated Helper Script (Easiest)

```bash
cd /Volumes/Data/Projects/eleven_plus_vocabulary
./ipad_screenshot_helper.sh
```

Choose your option:

- **Option 4**: Launch app on iPad simulator
- **Option 1-3**: Generate marketing screenshots for specific iPad size

### Option 2: Manual Process

```bash
# 1. Launch on iPad Pro 12.9" (recommended for largest screenshots)
flutter run -d "iPad Pro (12.9-inch)"

# 2. After capturing screenshots (see below)
python3 create_appstore_screenshots.py ~/Desktop ~/Desktop/AppStore_Screenshots_iPad ipad_129_landscape
```

---

## 📸 Step-by-Step: Capture iPad Screenshots

### Step 1: Launch App on iPad Simulator

```bash
cd /Volumes/Data/Projects/eleven_plus_vocabulary
flutter run -d "iPad Pro (12.9-inch)"
```

**Wait for app to load** (2-3 minutes)

### Step 2: Rotate to Landscape Mode

⚠️ **CRITICAL**: iPad screenshots must be in landscape!

**Rotate simulator:**

- Press **⌘+→** (Command + Right Arrow)
- OR Press **⌘+←** (Command + Left Arrow)

The simulator will rotate to landscape orientation.

### Step 3: Capture 5 Screenshots

Navigate to each screen and press **⌘+S** to capture:

#### Screenshot 1: 📚 Library Screen

- Library tab active
- Multiple packs visible
- Prices showing
- Stats overview
- **Press ⌘+S**

#### Screenshot 2: 🎯 Practice Session

- Start practice on any pack
- Question with 4 options visible
- Progress bar showing
- Audio icon visible
- **Press ⌘+S**

#### Screenshot 3: 🎉 Test Results

- Complete practice session
- Results screen showing:
    - Score percentage
    - Mastery badge
    - "Review" button
- **Press ⌘+S**

#### Screenshot 4: 📝 Review Screen

- From results, tap "Review Test Results"
- Mix of correct/incorrect answers
- 3-4 questions visible
- Clear color coding
- **Press ⌘+S**

#### Screenshot 5: 📊 Stats Dashboard

- Stats tab active
- Overall progress visible
- Mastery chart
- Recent activity
- Multiple stat cards
- **Press ⌘+S**

### Step 4: Generate Marketing Screenshots

Run the script with iPad landscape mode:

```bash
# For iPad Pro 12.9" (2732x2048)
python3 create_appstore_screenshots.py ~/Desktop ~/Desktop/AppStore_Screenshots_iPad ipad_129_landscape

# For iPad Pro 11" (2388x1668)
python3 create_appstore_screenshots.py ~/Desktop ~/Desktop/AppStore_Screenshots_iPad ipad_11_landscape

# For iPad Pro 10.5" (2224x1668)
python3 create_appstore_screenshots.py ~/Desktop ~/Desktop/AppStore_Screenshots_iPad ipad_105_landscape
```

**The script will:**
✅ Find your landscape iPad screenshots  
✅ Resize to correct App Store dimensions  
✅ Add professional text overlays at BOTTOM  
✅ Add feature badges  
✅ Save to `~/Desktop/AppStore_Screenshots_iPad/`

---

## 🎨 What Makes iPad Screenshots Different?

### Layout Differences

| Aspect            | iPhone         | iPad Landscape   |
|-------------------|----------------|------------------|
| **Orientation**   | Portrait       | Landscape        |
| **Text Position** | Bottom overlay | Bottom overlay   |
| **Overlay Size**  | 35% of height  | 30% of height    |
| **Text Length**   | Standard       | More descriptive |

### Marketing Messages

iPad screenshots use more descriptive text:

**iPhone:**

- "Master 450+ Words"
- "Essential 11+ Exam Vocabulary"

**iPad Landscape:**

- "Complete Vocabulary Library"
- "450+ Essential 11+ Exam Words Across 5 Sets"

The extra screen real estate allows for more detail!

---

## 📏 iPad Screenshot Requirements

Apple requires different sizes for different iPads:

| Device                    | Resolution (Landscape) | Required |
|---------------------------|------------------------|----------|
| iPad Pro 12.9" (3rd gen+) | 2732 x 2048            | ✅ Yes    |
| iPad Pro 11"              | 2388 x 1668            | Optional |
| iPad Pro 10.5"            | 2224 x 1668            | Optional |

**Minimum:** 1 set of screenshots (usually 12.9")  
**Recommended:** 3-5 screenshots  
**Maximum:** 10 screenshots

---

## 🎯 Visual Guide: Text Overlay Position

### Portrait (iPhone/iPad Portrait)

```
┌──────────────────┐
│                  │
│                  │
│   APP CONTENT    │
│                  │
│                  │
├──────────────────┤
│ ████████████████ │ ← Text overlay at BOTTOM
│ Title Text       │
│ Subtitle Text    │
└──────────────────┘
```

### Landscape (iPad)

```
┌────────────────────────────────────────┐
│                                        │
│                                        │
│          APP CONTENT                   │
│          (Landscape)                   │
│                                        │
├────────────────────────────────────────┤
│ ████████████████████████████████████   │ ← Text overlay at BOTTOM
│ 📚 Badge  Title Text  Subtitle         │
└────────────────────────────────────────┘
```

---

## 🛠 Available iPad Simulators

Check what's installed:

```bash
xcrun simctl list devices | grep iPad
```

Common options:

- iPad Pro (12.9-inch) (6th generation)
- iPad Pro (11-inch) (4th generation)
- iPad Air (5th generation)
- iPad (10th generation)

---

## ✅ Quality Checklist for iPad Screenshots

Before uploading:

- [ ] All screenshots are in **LANDSCAPE** orientation
- [ ] Resolution matches target device
- [ ] Text overlays are on the RIGHT side
- [ ] Text doesn't obscure important UI elements
- [ ] App content is clearly visible on left 60%
- [ ] No personal/test data visible
- [ ] Images are sharp (not stretched/blurry)
- [ ] File size under 2MB each
- [ ] All 5 screenshots captured

---

## 🎨 Customizing iPad Text

Edit `create_appstore_screenshots.py` around line 55:

```python
IPAD_SCREENSHOTS = [
    {
        "title": "Your Custom Title",
        "subtitle": "Your longer subtitle for iPad",
        "position": "right",  # Keep as "right" for landscape
        "badge": "🎯 Your Badge",
        "description": "library_screen"
    },
    # ... more configs
]
```

---

## 🚀 Complete Workflow Example

```bash
# Terminal 1: Navigate to project
cd /Volumes/Data/Projects/eleven_plus_vocabulary

# Terminal 1: Launch iPad simulator
flutter run -d "iPad Pro (12.9-inch)"

# Wait for app to load...

# In Simulator: Press ⌘+→ to rotate to landscape

# In Simulator: Navigate and capture screenshots (⌘+S) for:
# - Library
# - Practice
# - Results
# - Review
# - Stats

# Terminal 2: Generate marketing screenshots
cd /Volumes/Data/Projects/eleven_plus_vocabulary
python3 create_appstore_screenshots.py \
  ~/Desktop \
  ~/Desktop/AppStore_Screenshots_iPad \
  ipad_129_landscape

# Open results
open ~/Desktop/AppStore_Screenshots_iPad
```

---

## 📤 Uploading to App Store Connect

1. **Login:** [App Store Connect](https://appstoreconnect.apple.com)
2. **Navigate:** My Apps → 11+ Vocabulary Master
3. **Select:** App Store tab
4. **Scroll to:** App Previews and Screenshots
5. **Choose:** iPad Pro (3rd Gen) 12.9" Display
6. **Upload:** Your 5 generated screenshots
7. **Arrange:** In order (Library → Practice → Results → Review → Stats)
8. **Save**

---

## 🐛 Troubleshooting

### "Screenshots are portrait, not landscape"

- Make sure you rotated simulator with ⌘+→ or ⌘+←
- Check simulator window - it should be wider than tall
- Re-capture screenshots in landscape

### "Text overlay is at bottom instead of right"

- Check you're using `ipad_XXX_landscape` device type
- Not `ipad_XXX` (portrait)
- Example: `ipad_129_landscape` ✅ not `ipad_129` ❌

### "Text is too small/large"

The script uses responsive sizing. To adjust:

- Edit line ~175 in `create_appstore_screenshots.py`
- For landscape iPad: `get_font(int(height * 0.055))`
- Increase multiplier for larger text
- Decrease for smaller text

### "Simulator won't rotate"

Some iPad models don't support rotation in simulator:

- Use iPad Pro models (they rotate)
- Try different iPad from the list
- Make sure simulator is not locked

### "Wrong resolution"

Each iPad has specific requirements:

- **12.9" iPad Pro**: Must be 2732x2048 (landscape)
- **11" iPad Pro**: Must be 2388x1668 (landscape)
- Script will auto-resize, but native is best

---

## 💡 Pro Tips

1. **Use largest iPad** - iPad Pro 12.9" gives best quality
2. **Show more content** - Landscape allows more UI visible
3. **Test rotation first** - Make sure simulator rotates before capturing
4. **Consistent orientation** - All 5 screenshots must be landscape
5. **Clean data** - Show progress, not "0 words learned"
6. **Bright colors** - Stats look better with data
7. **Preview first** - Check one screenshot before doing all 5

---

## 📋 Quick Reference

### Launch iPad App

```bash
flutter run -d "iPad Pro (12.9-inch)"
```

### Rotate Simulator

```
⌘+→  (rotate right)
⌘+←  (rotate left)
```

### Capture Screenshot

```
⌘+S  (saves to Desktop)
```

### Generate Marketing Screenshots

```bash
# iPad Pro 12.9"
python3 create_appstore_screenshots.py ~/Desktop ~/Desktop/AppStore_Screenshots_iPad ipad_129_landscape

# iPad Pro 11"
python3 create_appstore_screenshots.py ~/Desktop ~/Desktop/AppStore_Screenshots_iPad ipad_11_landscape
```

### Check Screenshots

```bash
ls -la ~/Desktop/Simulator*.png
open ~/Desktop/AppStore_Screenshots_iPad
```

---

## 🎬 Complete Example Run

```bash
# 1. Navigate
cd /Volumes/Data/Projects/eleven_plus_vocabulary

# 2. Launch (using helper script)
./ipad_screenshot_helper.sh
# Choose: 4 (Launch app)
# Select: iPad Pro (12.9-inch)

# 3. In simulator:
#    - Wait for load
#    - Press ⌘+→ to rotate
#    - Navigate to Library, press ⌘+S
#    - Navigate to Practice, press ⌘+S
#    - Navigate to Results, press ⌘+S
#    - Navigate to Review, press ⌘+S
#    - Navigate to Stats, press ⌘+S

# 4. Generate marketing screenshots
./ipad_screenshot_helper.sh
# Choose: 1 (iPad Pro 12.9")

# 5. Review
open ~/Desktop/AppStore_Screenshots_iPad

# 6. Upload to App Store Connect
```

---

## 📞 Need Help?

Related files:

- `PROFESSIONAL_SCREENSHOTS_GUIDE.md` - iPhone screenshots
- `create_appstore_screenshots.py` - Main script
- `ipad_screenshot_helper.sh` - iPad automation
- `APP_STORE_SUBMISSION_CHECKLIST.md` - Full submission guide

---

**Ready to create stunning iPad screenshots? Let's go! 🚀**

