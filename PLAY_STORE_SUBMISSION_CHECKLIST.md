# Google Play Store Submission Checklist

## Pre-Submission Checklist

### 🔧 Technical Requirements

- [x] **App Bundle Built**: Use `./build_playstore_release.sh` to create signed AAB
- [x] **Target SDK 35**: Set in `android/app/build.gradle`
- [x] **Permissions Declared**: INTERNET permission added to AndroidManifest.xml
- [x] **ProGuard Rules**: Configured in `android/app/proguard-rules.pro`
- [x] **Signing Configured**: Using `android/key.properties` with upload keystore
- [ ] **Version Updated**: Current version 1.0.2+15 in pubspec.yaml
- [ ] **App Tested**: All features work in release build

### 📱 App Testing (Release Build)

- [ ] **Install Release Build**: Test the actual AAB on a real device
- [ ] **Vocabulary Sets**: All 5 sets load and display correctly
- [ ] **In-App Purchases**: Test purchasing vocabulary bundles (use test account)
- [ ] **Audio/TTS**: Text-to-speech works for all words
- [ ] **Statistics**: Progress tracking accurate
- [ ] **Daily Streaks**: Streak counter works correctly
- [ ] **Offline Mode**: App works without internet after initial setup
- [ ] **No Crashes**: App doesn't crash during normal usage
- [ ] **Performance**: App loads quickly and runs smoothly

### 🎨 Store Listing Assets

#### Required Assets

- [ ] **App Icon (512x512)**: High-res version of launcher icon
- [ ] **Feature Graphic (1024x500)**: Required for store listing
- [ ] **Screenshots - Phone (1080x1920)**: Minimum 2, recommended 4-8
    - [ ] Main vocabulary list view
    - [ ] Practice/flashcard mode
    - [ ] Statistics/progress screen
    - [ ] Settings screen with audio options
- [ ] **Screenshots - 7" Tablet (1200x1920)**: Recommended 2-4
- [ ] **Screenshots - 10" Tablet (2560x1600)**: Optional

#### Asset Creation

Use the existing screenshot generation script:

```bash
python create_play_store_screenshots.py
```

Or manually capture screenshots from:

- Pixel 6 emulator (1080x1920) for phone
- Pixel Tablet emulator (1920x1200) for tablet

### 📝 Store Listing Content

- [ ] **App Title**: "11+ Vocabulary Master" (50 chars max)
- [ ] **Short Description**: See `GOOGLE_PLAY_STORE_LISTING.md` (80 chars)
- [ ] **Full Description**: See `GOOGLE_PLAY_STORE_LISTING.md` (4000 chars)
- [ ] **What's New**: Release notes for version 1.0.2
- [ ] **Category**: Education > Learning & Study Tools
- [ ] **Content Rating**: Complete questionnaire (Everyone/Educational)
- [ ] **Tags**: Add relevant search keywords

### 🔒 Privacy & Compliance

- [ ] **Privacy Policy URL**: Host `PRIVACY_POLICY.md` and add URL to listing
    - Recommended: Use GitHub Pages, your website, or a privacy policy hosting service
- [ ] **Data Safety Form**: Complete in Play Console
    - ✓ Analytics data (Firebase Analytics) - NOT for advertising
    - ✓ Purchase history (processed by Google Play)
    - ✓ Usage data stored locally
    - ✓ No personal information collected
- [ ] **Target Age Group**: Set appropriate age rating (8+)
- [ ] **Ads Declaration**: Confirm "No" (app has no ads)
- [ ] **In-App Purchases**: List vocabulary bundle purchases

### 📧 Contact Information

- [ ] **Developer Email**: Valid support email address
- [ ] **Developer Website**: Optional but recommended
- [ ] **Phone Number**: Optional

### 🧪 Testing Tracks (Recommended)

#### Internal Testing (Recommended First Step)

- [ ] Create internal testing track
- [ ] Add test user emails (up to 100)
- [ ] Upload AAB to internal track
- [ ] Test IAP with test accounts
- [ ] Verify no crashes in Play Console

#### Closed Testing (Optional)

- [ ] Create closed testing track
- [ ] Add testers (friends, family, beta users)
- [ ] Gather feedback
- [ ] Fix any issues

#### Production Release

- [ ] Set countries/regions for distribution
- [ ] Set pricing (Free with IAP)
- [ ] Review all information one final time
- [ ] Submit for review

---

## Store Listing Information Quick Reference

### App Title

```
11+ Vocabulary Master
```

### Short Description (80 chars)

```
Master 11+ exam vocabulary with interactive practice and progress tracking.
```

### Package Name

```
com.elevenplusvocabularywords.eleven_plus_vocabulary
```

### Current Version

```
1.0.2 (Build 15)
```

---

## Building the Release

### Step 1: Build App Bundle

```bash
./build_playstore_release.sh
```

Or manually:

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

### Step 2: Locate App Bundle

```
build/app/outputs/bundle/release/app-release.aab
```

### Step 3: Test Release Build

```bash
# Install on connected device
bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab \
  --output=build/app.apks \
  --ks=android/upload-keystore.jks \
  --ks-key-alias=upload

bundletool install-apks --apks=build/app.apks
```

---

## Upload to Play Console

### Step-by-Step Upload Process

1. **Go to Play Console**: https://play.google.com/console
2. **Select/Create App**:
    - If new: Click "Create app"
    - If existing: Select your app
3. **Complete App Setup** (First time only):
    - App access
    - Ads
    - Content ratings
    - Target audience
    - News app
    - COVID-19 contact tracing
    - Data safety
    - Government apps
    - Financial features
4. **Upload AAB**:
    - Navigate to: Production > Create new release
    - Or: Testing > Internal testing > Create new release (recommended first)
    - Upload: `build/app/outputs/bundle/release/app-release.aab`
5. **Add Release Notes**:
   ```
   Version 1.0.2:
   • Enhanced audio settings with customizable speech rate
   • Improved progress tracking and statistics
   • Better daily streak visualization
   • Performance optimizations
   • Bug fixes and stability improvements
   ```
6. **Review Release**: Check all information
7. **Submit for Review** or **Roll Out** (internal testing)

---

## Common Issues & Solutions

### Issue: "Upload failed - Duplicate version"

**Solution**: Increment version in `pubspec.yaml`:

```yaml
version: 1.0.3+16  # Increment both version name and code
```

### Issue: "Privacy Policy URL required"

**Solution**:

1. Host `PRIVACY_POLICY.md` as a web page
2. Add URL to Play Console listing
3. Recommended services: GitHub Pages, Google Sites, your website

### Issue: "Data Safety incomplete"

**Solution**: Declare in Play Console:

- Analytics: Yes (not for advertising)
- Device/App data: Yes
- Purchase history: Yes (managed by Google Play)
- Personal info: No
- Location: No
- Photos/Videos: No

### Issue: "Content rating required"

**Solution**: Complete questionnaire:

- Violence: None
- Sexual content: None
- Profanity: None
- Controlled substances: None
- Educational content: Yes

### Issue: "IAP not working"

**Solution**:

1. Set up app in Play Console first
2. Create IAP products matching app code
3. Test with licensed test accounts
4. Ensure app is published (at least in internal testing)

---

## Post-Submission

### Monitor After Release

- [ ] **Check Play Console**: Watch for crashes and ANRs
- [ ] **Monitor Reviews**: Respond to user feedback promptly
- [ ] **Track Statistics**: Monitor installs, uninstalls, ratings
- [ ] **Update Regularly**: Fix bugs and add features based on feedback

### Marketing (Optional)

- [ ] Share on social media
- [ ] Create landing page
- [ ] Request reviews from satisfied users
- [ ] Consider promotional campaigns
- [ ] Cross-promote if you have other apps

---

## Quick Commands Reference

### Build Release

```bash
./build_playstore_release.sh
```

### Check Bundle Size

```bash
ls -lh build/app/outputs/bundle/release/app-release.aab
```

### Analyze Bundle

```bash
bundletool dump badging build/app/outputs/bundle/release/app-release.aab
```

### Version Info

```bash
grep "^version:" pubspec.yaml
```

---

## Important Links

- **Play Console**: https://play.google.com/console
- **Firebase Console**: https://console.firebase.google.com
- **Android Developer Docs**: https://developer.android.com/distribute/play-console
- **Play Store Policies**: https://play.google.com/about/developer-content-policy/

---

## Support Resources

- **Flutter Deployment Guide**: https://docs.flutter.dev/deployment/android
- **Play Console Help**: https://support.google.com/googleplay/android-developer
- **In-App Purchase Setup**: https://developer.android.com/google/play/billing

---

**Last Updated**: December 1, 2025
**Current Version**: 1.0.2+15
**Status**: Ready for submission ✓

---

## Notes

- Always test in Internal Testing track first before production
- Keep your signing key secure (backup `upload-keystore.jks`)
- Update privacy policy when adding new features that collect data
- Respond to user reviews within 7 days for best engagement
- Monitor crash reports and fix critical issues quickly

