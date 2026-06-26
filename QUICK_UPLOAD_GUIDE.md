# Quick TestFlight Upload Guide - Build 10

## 📦 After Build Completes

### 1. Locate Your Build Files

The build will create files in:

```
/Volumes/Data/Projects/eleven_plus_vocabulary/build/ios/archive/Runner.xcarchive
/Volumes/Data/Projects/eleven_plus_vocabulary/build/ios/ipa/eleven_plus_vocabulary.ipa
```

### 2. Upload Methods (Choose One)

#### Method A: Xcode Organizer (Easiest) ⭐️

1. **Open Xcode**
2. Press `Cmd + Shift + 2` or go to **Window > Organizer**
3. Click **Archives** tab in the left sidebar
4. Find your app "eleven_plus_vocabulary" and select Build 10
5. Click **Distribute App** button
6. Select **App Store Connect** and click Next
7. Select **Upload** and click Next
8. Follow the wizard:
    - App Store Connect distribution options: Keep defaults, click Next
    - Re-sign: Use automatic signing, click Next
    - Review summary, click **Upload**
9. Wait for upload to complete (progress bar will show)
10. Success message will appear when done! ✅

#### Method B: Transporter App (Simple)

1. **Download Transporter** from Mac App Store (if not installed)
2. **Open Transporter** app
3. **Sign in** with your Apple Developer account
4. **Drag and drop** the .ipa file:
   ```
   build/ios/ipa/eleven_plus_vocabulary.ipa
   ```
5. Click **Deliver** button
6. Wait for upload (progress shows percentage)
7. Done when you see green checkmark! ✅

#### Method C: Command Line (Advanced)

```bash
# Navigate to project directory
cd /Volumes/Data/Projects/eleven_plus_vocabulary

# Upload using xcrun
xcrun altool --upload-app --type ios \
  --file "build/ios/ipa/eleven_plus_vocabulary.ipa" \
  --username "YOUR_APPLE_ID@email.com" \
  --password "YOUR_APP_SPECIFIC_PASSWORD"

# Note: Create app-specific password at appleid.apple.com if needed
```

### 3. Verify Upload in App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Click on your app **"Eleven Plus Vocabulary"**
3. Click **TestFlight** tab
4. Look under **iOS Builds** section
5. You should see:
    - Version: 1.0.1
    - Build: 10
    - Status: "Processing" (yellow dot)

### 4. Wait for Processing

- **Processing time:** Usually 10-30 minutes
- **Status changes:** Processing → Ready to Submit → Ready to Test
- **You'll receive email** when processing completes
- **Refresh page** occasionally to check status

### 5. Once Build Shows "Ready to Test"

1. Click on **Build 10**
2. Add **What to Test** information:

```
🎵 Audio Settings Feature

NEW: Settings screen with configurable word pronunciation!

Test with your music:
1. Start Spotify/Apple Music
2. Go to Settings (new tab in bottom bar)
3. Toggle "Word Pronunciation" on/off
4. Test practice mode with both settings
5. Verify your music plays uninterrupted when audio is OFF
6. Verify music ducks properly when audio is ON

Report any issues with audio, settings, or navigation.
```

3. **Save** the changes
4. **Add to Test Groups** (select your testers)
5. **Save** again

### 6. Notify Testers

Your testers will receive:

- Push notification (if enabled)
- Email notification
- TestFlight app will show update available

## 🔍 Troubleshooting

### Build Fails

- Check error message in terminal
- Ensure signing certificates are valid
- Try: `flutter clean && flutter pub get && flutter build ipa --release`

### Upload Fails

- Check Apple ID credentials
- Ensure app exists in App Store Connect
- Verify bundle identifier matches
- Check network connection

### Build Doesn't Appear in App Store Connect

- Wait 5-10 minutes and refresh
- Check email for any rejection notices
- Verify you uploaded to correct app

### Build Stuck in Processing

- Normal if < 30 minutes
- Check App Store Connect notifications
- Apple sometimes has delays
- Usually resolves automatically

## ✅ Success Indicators

You'll know it worked when:

- ✅ Upload completes without errors
- ✅ Build appears in App Store Connect TestFlight tab
- ✅ Status changes from "Processing" to "Ready to Test"
- ✅ Testers receive notification
- ✅ Testers can install via TestFlight app

## 📧 What Testers Need to Do

1. Open **TestFlight app** on iPhone/iPad
2. Find **"11+ Vocabulary Master"**
3. See **"Update Available"** badge
4. Tap **Update** or **Install**
5. Wait for download
6. Open app and test!

## 🎯 Quick Command Summary

```bash
# Build for TestFlight
cd /Volumes/Data/Projects/eleven_plus_vocabulary
flutter clean
flutter pub get
flutter build ipa --release

# Upload (using Xcode Organizer recommended)
# Or use Transporter app (drag & drop .ipa file)
```

## 📱 File Locations Reference

- **IPA File:** `build/ios/ipa/eleven_plus_vocabulary.ipa`
- **Archive:** `build/ios/archive/Runner.xcarchive`
- **Version:** 1.0.1
- **Build:** 10

---

**Need Help?** Check the detailed TESTFLIGHT_CHECKLIST_BUILD10.md file for more information.

