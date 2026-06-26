# Google Play Store Assets Guide

This guide explains how to create and prepare all required assets for Google Play Store submission.

## Required Assets Checklist

### ✅ Mandatory Assets

1. **App Icon (512x512)** - High resolution app icon
2. **Feature Graphic (1024x500)** - Main promotional banner
3. **Screenshots (Phone)** - Minimum 2, maximum 8 (1080x1920 portrait or 1920x1080 landscape)

### 📱 Recommended Assets

4. **Screenshots (7" Tablet)** - Minimum 2 (1200x1920 portrait or 1920x1200 landscape)
5. **Screenshots (10" Tablet)** - Optional (2560x1600 landscape or 1600x2560 portrait)

### 🎨 Optional Promotional Assets

6. **Promo Graphic (180x120)** - Small promotional banner (optional)
7. **TV Banner (1280x720)** - For Android TV (not applicable for this app)

---

## Quick Start: Generate Graphics

### Step 1: Generate Feature Graphic and High-Res Icon

Run the automated script:

```bash
python3 generate_play_store_assets.py
```

This creates:

- `play_store_assets/feature_graphic_1024x500.png`
- `play_store_assets/high_res_icon_512x512.png`

### Step 2: Capture Screenshots

#### Option A: Use Emulator (Recommended)

1. **Start Android Emulator**:
   ```bash
   # Pixel 6 for phone screenshots
   flutter emulators --launch <emulator-id>
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

3. **Capture key screens**:
    - Navigate to each main screen
    - Click camera icon in emulator OR press Cmd+S (Mac) / Ctrl+S (Windows)
    - Take screenshots of:
        - Main vocabulary list view
        - Practice/flashcard screen
        - Statistics/progress screen
        - Settings screen with audio options

4. **Screenshots will be saved to**:
    - Mac: `~/Desktop`
    - Windows: `C:\Users\<username>\Desktop`

#### Option B: Use Real Device

1. **Enable Developer Options** on your Android device
2. **Connect device** via USB
3. **Run app**: `flutter run`
4. **Take screenshots**: Use device screenshot button (usually Power + Volume Down)
5. **Transfer to computer** via USB or cloud storage

#### Option C: Use Existing Script

If you have a screenshot automation script:

```bash
python3 create_play_store_screenshots.py
```

### Step 3: Optimize Screenshots

Ensure screenshots:

- Show the app in its best light
- Display actual content (not placeholder text)
- Have good contrast and readability
- Follow a consistent style
- Don't include device frames (Play Console adds them automatically)

---

## Asset Specifications

### 1. High-Res App Icon (512x512)

**Specifications**:

- Dimensions: 512 x 512 pixels
- Format: 32-bit PNG (with alpha)
- Max file size: 1 MB
- Should match your app's launcher icon but in higher resolution

**Current Icon**: `assets/chicken-icon-natural.png`

**Generated File**: `play_store_assets/high_res_icon_512x512.png`

**Tips**:

- Keep it simple and recognizable
- Ensure it looks good at small sizes
- Match your app's branding
- No text (icons are more universal)

---

### 2. Feature Graphic (1024x500)

**Specifications**:

- Dimensions: 1024 x 500 pixels
- Format: PNG or JPG
- Max file size: 1 MB
- No transparency (use solid background)

**Generated File**: `play_store_assets/feature_graphic_1024x500.png`

**What it shows**:

- App logo/icon
- App name: "11+ Vocabulary Master"
- Tagline: "Master 500+ Words for Success"
- Blue gradient background matching app theme

**Tips**:

- This is the first thing users see
- Keep text minimal and readable
- Use your brand colors
- Make it eye-catching but professional

---

### 3. Phone Screenshots (1080x1920)

**Specifications**:

- Dimensions: 1080 x 1920 pixels (portrait) OR 1920 x 1080 (landscape)
- Format: PNG or JPG
- Minimum: 2 screenshots
- Maximum: 8 screenshots
- Max file size per screenshot: 8 MB

**Recommended Screenshots**:

1. **Vocabulary List View** - Shows all words in a set with progress indicators
2. **Practice Mode** - Flashcard or quiz interface in action
3. **Statistics Screen** - Progress tracking, streaks, achievements
4. **Word Detail View** - Shows definition, example, synonyms, audio button
5. **Settings Screen** - Audio settings, theme options
6. **Unlock Premium** - Shows the bundles available for purchase
7. **Daily Streak** - Highlights the streak feature
8. **All Sets View** - Overview of all 5 vocabulary sets

**Screenshot Tips**:

- Show real content, not dummy data
- Include some progress (not 0%, not 100%)
- Show the app in a realistic use case
- Use actual vocabulary words from the sets
- Ensure text is readable
- Consider adding captions (optional)

**Ordering**: Put your best, most compelling screenshot first!

---

### 4. Tablet Screenshots (7-inch: 1200x1920)

**Specifications**:

- Dimensions: 1200 x 1920 pixels (portrait) OR 1920 x 1200 (landscape)
- Format: PNG or JPG
- Minimum: 2 screenshots
- Maximum: 8 screenshots
- Max file size per screenshot: 8 MB

**Recommended**: Use similar screens as phone but show tablet layout

**Note**: If your app looks the same on tablet, you can skip these, but including them improves
visibility for tablet users.

---

### 5. Tablet Screenshots (10-inch: 1600x2560)

**Specifications**:

- Dimensions: 1600 x 2560 pixels (portrait) OR 2560 x 1600 (landscape)
- Optional but nice to have

---

## Screenshot Capture Guide

### Best Practices

1. **Use Clean Data**:
    - Show realistic vocabulary words
    - Display moderate progress (30-70%)
    - Include a reasonable daily streak (7-30 days)
    - Show actual statistics

2. **Consistent Styling**:
    - Use the same device/emulator for all screenshots
    - Keep navigation bar consistent
    - Use same time/battery indicators

3. **Highlight Features**:
    - Show the most impressive features first
    - Demonstrate the app's value proposition
    - Include visual interest (not just lists)

4. **Professional Look**:
    - No typos or errors visible
    - Clean interface (no debug overlays)
    - Good color contrast
    - Proper alignment

### What NOT to Include

- ❌ Debug mode indicators
- ❌ Personal information
- ❌ Fake/misleading content
- ❌ Competitor mentions
- ❌ Copyrighted material
- ❌ Stretched or distorted images
- ❌ Low quality/blurry images

---

## Emulator Setup for Screenshots

### Create Pixel 6 Emulator (Phone)

1. Open Android Studio
2. Tools > Device Manager
3. Create Device
4. Select: Pixel 6 (1080 x 2400)
5. System Image: Android 13 (API 33) or higher
6. Finish

### Create Pixel Tablet Emulator (Tablet)

1. Open Android Studio
2. Tools > Device Manager
3. Create Device
4. Select: Pixel Tablet (2560 x 1600)
5. System Image: Android 13 (API 33) or higher
6. Finish

### Take Screenshots from Emulator

**Method 1: Emulator Button**

- Click camera icon in emulator control panel

**Method 2: Keyboard Shortcut**

- Mac: `Cmd + S`
- Windows/Linux: `Ctrl + S`

**Method 3: adb Command**

```bash
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png ./screenshot.png
```

---

## Upload to Play Console

### Where to Upload

1. Go to: https://play.google.com/console
2. Select your app
3. Navigate to: **Store presence > Main store listing**

### Upload Locations

**High-Res Icon**:

- Section: "App icon"
- Upload `high_res_icon_512x512.png`

**Feature Graphic**:

- Section: "Feature graphic"
- Upload `feature_graphic_1024x500.png`

**Screenshots**:

- Section: "Phone screenshots"
- Upload 2-8 phone screenshots
- Section: "7-inch tablet screenshots" (optional)
- Upload 2-8 tablet screenshots
- Section: "10-inch tablet screenshots" (optional)

### After Upload

- Preview how it looks in Play Store
- Rearrange screenshots (drag to reorder)
- Save as draft
- Submit for review when ready

---

## Asset Storage Organization

Recommended folder structure:

```
play_store_assets/
├── feature_graphic_1024x500.png
├── high_res_icon_512x512.png
├── phone_screenshots/
│   ├── 01_vocabulary_list.png
│   ├── 02_practice_mode.png
│   ├── 03_statistics.png
│   ├── 04_word_detail.png
│   ├── 05_settings.png
│   ├── 06_unlock_premium.png
│   ├── 07_daily_streak.png
│   └── 08_all_sets.png
├── tablet_7inch_screenshots/
│   ├── 01_vocabulary_list.png
│   ├── 02_practice_mode.png
│   ├── 03_statistics.png
│   └── 04_settings.png
└── original_assets/
    └── (keep source files here)
```

---

## Tools & Resources

### Graphic Design Tools

**Free**:

- **GIMP**: https://www.gimp.org/
- **Canva**: https://www.canva.com/
- **Figma**: https://www.figma.com/

**Paid**:

- **Adobe Photoshop**
- **Sketch** (Mac only)
- **Affinity Photo**

### Screenshot Tools

**Android Studio Emulator** (Recommended)

- Built-in screenshot functionality
- Multiple device profiles
- Free

**Device Screenshots**

- Real device experience
- Most accurate representation

### Image Optimization

**TinyPNG**: https://tinypng.com/

- Compress PNG files
- Reduce file size without quality loss

**ImageOptim** (Mac): https://imageoptim.com/

- Batch optimization
- Lossless compression

---

## Common Issues & Solutions

### Issue: Screenshots too large (> 8 MB)

**Solution**: Compress using TinyPNG or ImageOptim

### Issue: Wrong dimensions

**Solution**: Use image editor to resize to exact specifications

- Don't stretch or crop incorrectly
- Maintain aspect ratio

### Issue: Feature graphic text not readable

**Solution**:

- Increase font size
- Use better contrast
- Simplify design
- Remove unnecessary elements

### Issue: Screenshots look different on Play Store

**Solution**:

- Preview in Play Console before publishing
- Test on multiple devices
- Check color profiles (use sRGB)

---

## Checklist Before Upload

- [ ] All images are correct dimensions
- [ ] File formats are PNG or JPG
- [ ] File sizes under limits (1 MB for graphics, 8 MB for screenshots)
- [ ] Images are crisp and clear
- [ ] No placeholder or test content visible
- [ ] Text is readable at all sizes
- [ ] Brand colors are consistent
- [ ] No copyrighted material
- [ ] Screenshots show actual app content
- [ ] Feature graphic is eye-catching
- [ ] Minimum 2 phone screenshots captured

---

## Next Steps

After creating assets:

1. Review all assets for quality
2. Upload to Play Console
3. Complete store listing text (see `GOOGLE_PLAY_STORE_LISTING.md`)
4. Fill in Data Safety form
5. Complete Content Rating questionnaire
6. Build release AAB (see `PLAY_STORE_SUBMISSION_CHECKLIST.md`)
7. Submit for review

---

**Last Updated**: December 1, 2025
**For App**: 11+ Vocabulary Master v1.0.2+15

---

## Questions?

See also:

- `GOOGLE_PLAY_STORE_LISTING.md` - Store listing content
- `PLAY_STORE_SUBMISSION_CHECKLIST.md` - Complete submission guide
- `PRIVACY_POLICY.md` - Privacy policy content

Google's Official Guide:
https://support.google.com/googleplay/android-developer/answer/9866151

