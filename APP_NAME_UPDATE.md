# App Name Update Summary

## Updated App Name

**Old Name:** "Eleven Plus Vocabulary"  
**New Name:** "11+ Vocabulary Master" ✅

---

## Files Updated

### 1. iOS Configuration

- **ios/Runner/Info.plist**
    - `CFBundleDisplayName` → "11+ Vocabulary Master"
    - This controls the name shown under the app icon on iOS devices

### 2. Android Configuration

- **android/app/src/main/AndroidManifest.xml**
    - `android:label` → "11+ Vocabulary Master"
    - This controls the name shown under the app icon on Android devices

### 3. Flutter Application Code

- **lib/main.dart**
    - `title` → "11+ Vocabulary Master"
    - App window title

- **lib/screens/settings/settings_screen.dart**
    - Settings screen title → "11+ Vocabulary Master"
    - About dialog `applicationName` → "11+ Vocabulary Master"

### 4. Documentation Files Updated

- **README.md** - Main project description
- **APP_STORE_SUBMISSION_CHECKLIST.md** - Submission checklist
- **TESTFLIGHT_UPLOAD_GUIDE.md** - TestFlight instructions
- **SCREENSHOT_GUIDE.md** - Screenshot creation guide
- **QUICK_UPLOAD_GUIDE.md** - Quick upload reference
- **PROFESSIONAL_SCREENSHOTS_GUIDE.md** - Professional screenshot guide
- **IPAD_SCREENSHOTS_GUIDE.md** - iPad screenshot guide
- **MANUAL_TESTING_GUIDE.md** - Testing guide
- **ipad_screenshot_helper.sh** - iPad helper script
- **create_appstore_screenshots.py** - Screenshot generator
- **create_marketing_screenshots.py** - Legacy screenshot generator

---

## What This Means

### User-Visible Changes

✅ **iOS Home Screen:** Shows "11+ Vocabulary Master" under the icon  
✅ **Android Home Screen:** Shows "11+ Vocabulary Master" under the icon  
✅ **Settings Screen:** Shows "11+ Vocabulary Master" as app name  
✅ **About Dialog:** Shows "11+ Vocabulary Master"  
✅ **App Switcher:** Shows "11+ Vocabulary Master"

### App Store Presence

✅ **App Store Connect:** All references updated to "11+ Vocabulary Master"  
✅ **TestFlight:** Consistent app name in beta testing  
✅ **Documentation:** All guides reference correct app name

---

## Technical Notes

### Bundle Identifier (Unchanged)

- iOS: `com.yourcompany.elevenPlusVocabulary` (or your actual bundle ID)
- Android: Package name remains the same
- These don't need to change - they're internal identifiers

### Project Folder Name (Unchanged)

- Folder: `/Volumes/Data/Projects/eleven_plus_vocabulary`
- This is fine to keep as-is - it's just the development folder name

### Package Name (Unchanged)

- pubspec.yaml: `name: eleven_plus_vocabulary`
- This is the Dart package name and shouldn't change

---

## Next Steps

### For Next Build

When you build the app next time, the updated name will appear:

**iOS:**

```bash
flutter build ios --release
```

**Android:**

```bash
flutter build appk --release
```

### For Testing

To see the new name immediately:

```bash
flutter run
```

The app will now show "11+ Vocabulary Master" under the icon and in all user-facing places.

---

## App Store Screenshots

If you want to update the marketing text in screenshots to reference the new name, you can edit:

**File:** `create_appstore_screenshots.py`

Current marketing messages already use descriptive text like:

- "Master 450+ Words" ✅
- "Essential 11+ Exam Vocabulary" ✅

These work well with the new app name "11+ Vocabulary Master".

---

## Verification Checklist

- [x] iOS Info.plist updated
- [x] Android Manifest updated
- [x] Main app code updated
- [x] Settings screen updated
- [x] All documentation updated
- [x] Helper scripts updated
- [x] Screenshot generators updated
- [x] README updated

---

**Status:** ✅ Complete - App name is now "11+ Vocabulary Master" everywhere!

**Date Updated:** November 18, 2025

