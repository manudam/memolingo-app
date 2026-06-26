# TestFlight Upload Guide - Version 1.0.1 (Build 6)

## What's New in This Build

This build includes:

- ✅ Complete "All Vocabulary Packs" bundle feature
- ✅ Bundle purchase unlocks all 5 vocabulary sets at once
- ✅ Fixed overflow issues on smaller iOS devices
- ✅ Improved vocabulary test UX - word is now tappable to hear pronunciation
- ✅ Removed separate speaker button for cleaner interface
- ✅ Fixed all deprecation warnings
- ✅ IAP integration with StoreKit for testing

## Pre-Upload Checklist

### 1. App Store Connect Setup

- [ ] Ensure your app exists in App Store Connect
- [ ] Bundle ID: `com.yourdomain.elevenPlusVocabulary` (verify this matches)
- [ ] App version 1.0.1 is created in App Store Connect
- [ ] All required screenshots and metadata are uploaded
- [ ] Test users are configured for TestFlight

### 2. In-App Purchases

Ensure these products are configured in App Store Connect:

- `vocabulary_pack_1` - $0.99 (or your price)
- `vocabulary_pack_2` - $0.99
- `vocabulary_pack_3` - $0.99
- `vocabulary_pack_4` - $0.99
- `vocabulary_pack_5` - $0.99
- `all_vocabulary_packs` - $2.99 (bundle - best value!)

### 3. Certificates & Provisioning

- [ ] Distribution certificate is valid
- [ ] App Store provisioning profile is up to date
- [ ] Signing is configured in Xcode

## Build Instructions

### Option 1: Using Xcode (Recommended)

1. **Open the workspace:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Select target device:**
    - Select "Any iOS Device (arm64)" from the device dropdown

3. **Archive the build:**
    - Go to: **Product → Archive**
    - Wait for the archive to complete (may take 5-10 minutes)

4. **Distribute to TestFlight:**
    - When archive completes, Organizer window opens automatically
    - Click **Distribute App**
    - Choose **App Store Connect**
    - Choose **Upload**
    - Select appropriate options:
        - ✅ Include bitcode (if available)
        - ✅ Upload your app's symbols
        - ✅ Manage Version and Build Number (automatic)
    - Click **Upload**
    - Wait for upload to complete

### Option 2: Using Flutter Command Line

1. **Clean previous builds:**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Build the IPA:**
   ```bash
   flutter build ipa --release
   ```

3. **Upload using Transporter or Xcode:**
    - The IPA will be at: `build/ios/ipa/eleven_plus_vocabulary.ipa`
    - Use Apple's Transporter app or Xcode Organizer to upload

## Post-Upload Steps

### 1. In App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to: **My Apps → 11+ Vocabulary Master → TestFlight**
3. Wait for build processing (10-30 minutes typically)
4. You'll receive an email when build is ready

### 2. Configure TestFlight Build

1. **Add Test Information:**
    - What to Test: "Bundle purchase feature unlocks all vocabulary packs. Test the Complete Bundle
      purchase at the bottom of the Library screen."
    - Feedback Email: Your email
    - Marketing URL: (optional)
    - Privacy Policy URL: (if you have one)

2. **Add Internal Testers:**
    - Select the build
    - Click "Add Testers to Build"
    - Select internal testers
    - Click "Add"

3. **Export Compliance:**
    - Answer encryption questions:
        - Does your app use encryption? → **Yes**
        - Does it use encryption exempt from regulations? → **Yes** (if using standard HTTPS only)
        - Or provide export compliance documentation if needed

### 3. Invite External Testers (Optional)

1. Go to **TestFlight → External Testing**
2. Create a new group or use existing
3. Select build version 1.0.1 (6)
4. Add testers by email
5. Submit for Beta App Review (first time only)

## Testing the Build

### Key Features to Test:

1. **Bundle Purchase Flow:**
    - Go to Library screen
    - Scroll to bottom
    - Tap "Buy Complete Bundle"
    - Complete purchase (sandbox)
    - Verify all 5 vocabulary packs unlock

2. **Individual Pack Purchase:**
    - Try purchasing individual packs
    - Verify they unlock properly

3. **Vocabulary Practice:**
    - Tap on vocabulary pack to view words
    - Start practice test
    - Tap the word (blue box) to hear pronunciation
    - Verify speaker icon shows and audio plays

4. **Restore Purchases:**
    - Delete and reinstall app
    - Tap "Restore Purchases"
    - Verify all packs restore correctly

## Troubleshooting

### Build Fails with Signing Error

- Open project in Xcode
- Select Runner target
- Go to Signing & Capabilities
- Ensure "Automatically manage signing" is checked
- Select your team

### Upload Fails

- Verify bundle ID matches App Store Connect
- Check that version number is higher than previous
- Ensure all required entitlements are configured

### Processing Stuck

- Processing can take up to 30 minutes
- Check for email from Apple about processing issues
- Verify build appears in Activity tab of App Store Connect

### IAP Products Not Working

- Products must be in "Ready to Submit" status
- Create sandbox test account in App Store Connect
- Sign in with sandbox account on test device
- Verify product IDs match exactly in code and App Store Connect

## Version History

- **1.0.1 (6)** - Current build
    - Bundle purchase feature
    - UI improvements
    - Bug fixes

- **1.0.1 (5)** - Previous build

## Support

For issues with TestFlight:

- Apple Developer Forums: https://developer.apple.com/forums/
- App Store Connect Help: https://developer.apple.com/support/app-store-connect/

For build issues:

- Check console logs in Xcode
- Review signing and provisioning profiles
- Verify all dependencies are up to date

