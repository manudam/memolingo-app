# TestFlight Upload Checklist - Build 10

## ✅ Pre-Build Checklist

- [x] Version number updated in pubspec.yaml (1.0.1+10)
- [x] Release notes created
- [x] Code analyzed for errors
- [x] All new features tested locally
- [x] Audio settings feature implemented
- [x] Settings screen created and accessible
- [x] Project cleaned before build

## 🔨 Build Process

- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Run `flutter build ipa --release`
- [ ] Verify build completes successfully
- [ ] Locate .ipa file in `build/ios/ipa/`

## 📤 Upload to TestFlight

### Option 1: Using Xcode (Recommended)

1. Open Xcode
2. Go to Window > Organizer
3. Select the archive for Build 10
4. Click "Distribute App"
5. Choose "App Store Connect"
6. Choose "Upload"
7. Follow the prompts to complete upload

### Option 2: Using Transporter App

1. Open Transporter app (download from Mac App Store if needed)
2. Sign in with your Apple Developer account
3. Drag and drop the .ipa file from `build/ios/ipa/`
4. Click "Deliver"
5. Wait for upload to complete

### Option 3: Using Command Line

```bash
xcrun altool --upload-app --type ios \
  --file "build/ios/ipa/eleven_plus_vocabulary.ipa" \
  --username "your-apple-id@email.com" \
  --password "your-app-specific-password"
```

## 📝 App Store Connect Configuration

After upload completes:

1. **Go to App Store Connect** (https://appstoreconnect.apple.com)
2. Navigate to your app
3. Go to TestFlight tab
4. Wait for build to process (usually 10-30 minutes)
5. Once processed, add "What to Test" notes:

### Suggested "What to Test" Notes for Testers:

```
🎵 New Audio Settings Feature!

This build introduces a new Settings screen where you can control word pronunciation audio.

KEY FEATURES TO TEST:
• Access Settings via the new Settings icon in bottom navigation bar
• Toggle "Word Pronunciation" on/off
• Test with Spotify or Apple Music playing in background
• When audio is OFF: Your music should play uninterrupted
• When audio is ON: Music should briefly lower during pronunciation then return to normal

SPECIFIC TEST SCENARIOS:
1. Start playing music in Spotify
2. Open the app and go to Settings
3. Try both audio ON and OFF modes during practice tests
4. Close and reopen the app - verify your audio preference is remembered

Please report any issues with:
• Audio mixing behavior
• Settings persistence
• Navigation between screens
• Any unexpected behavior

All existing features (practice tests, stats, library, profile) should continue working normally.
```

6. **Select Testers:**
    - Choose internal testers (your team)
    - OR add external testers
    - Enable automatic distribution if desired

7. **Add Build to Test Groups**
8. Click "Submit for Review" if needed (for external testing)

## 🧪 Testing Checklist for Testers

Send this to your TestFlight testers:

### Critical Testing Areas:

- [ ] Settings screen loads correctly
- [ ] Audio toggle switch works
- [ ] Audio OFF: Music continues playing during app use
- [ ] Audio ON: Music ducks during word pronunciation
- [ ] Setting persists after app restart
- [ ] Bottom navigation works (Practice, Stats, Library, Settings)
- [ ] Practice tests work normally
- [ ] Stats page displays correctly
- [ ] Library shows vocabulary packs
- [ ] Profile customization works
- [ ] In-app purchases function properly

### Specific Audio Tests:

- [ ] Start Spotify/Apple Music
- [ ] Open app with audio enabled - music should duck during pronunciation
- [ ] Disable audio in Settings - music should play uninterrupted
- [ ] Close and reopen app - setting should be remembered
- [ ] Try switching between enabled/disabled multiple times

## 📊 Post-Upload Steps

- [ ] Monitor build processing status in App Store Connect
- [ ] Add "What to Test" notes once build is processed
- [ ] Notify testers that new build is available
- [ ] Monitor for crash reports
- [ ] Check TestFlight feedback
- [ ] Review analytics for any issues

## 🐛 Known Issues to Watch For

Current build has no known issues, but monitor for:

- Audio mixing problems on different iOS versions
- Settings not persisting
- Navigation issues
- Any crashes related to audio initialization

## 📱 Device/iOS Version Coverage

Ensure testing on:

- [ ] iOS 15.x
- [ ] iOS 16.x
- [ ] iOS 17.x
- [ ] iOS 18.x
- [ ] Various iPhone models (SE, standard, Pro, Pro Max)
- [ ] iPad (if supported)

## 📞 Support

If testers encounter issues:

- Direct them to TestFlight feedback option
- Monitor App Store Connect for crash reports
- Check Firebase Analytics for usage patterns
- Review Firebase Crashlytics if enabled

## 🎯 Success Criteria

Build is successful when:

- ✅ Upload completes without errors
- ✅ Build processes in App Store Connect
- ✅ At least 3 testers confirm audio settings work
- ✅ No critical crashes reported in first 24 hours
- ✅ Audio mixing works as expected with Spotify/Apple Music
- ✅ Settings persist across app restarts

## 📅 Timeline

- **Build Upload:** November 5, 2025
- **Processing Time:** ~10-30 minutes
- **Testing Period:** 3-7 days
- **Production Release:** TBD based on feedback

---

**Build Version:** 1.0.1 (10)
**Release Date:** November 5, 2025
**Major Features:** Audio Settings, Music-Friendly Mode, Settings Screen

