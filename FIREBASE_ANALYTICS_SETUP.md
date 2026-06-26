# Firebase Analytics Setup Guide for iOS

## Prerequisites

✅ Firebase Analytics dependencies installed via `flutter pub get`
✅ Android `google-services.json` file already in place

## iOS Configuration Steps

### Step 1: Add GoogleService-Info.plist for iOS

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click on the iOS app (or add iOS app if not exists)
4. Download the `GoogleService-Info.plist` file
5. Place it in: `/ios/Runner/`

**Using Xcode:**

1. Open `ios/Runner.xcworkspace` in Xcode
2. Right-click on `Runner` folder
3. Select "Add Files to Runner..."
4. Select the `GoogleService-Info.plist` file
5. Make sure "Copy items if needed" is checked
6. Make sure target "Runner" is selected

### Step 2: Verify Podfile Configuration

Your `ios/Podfile` should already be configured, but verify it contains:

```ruby
platform :ios, '12.0'  # or higher
```

### Step 3: Install Pods

```bash
cd ios
pod install --repo-update
cd ..
```

### Step 4: Update Info.plist (if needed)

The file at `ios/Runner/Info.plist` should already be configured correctly for Firebase.

### Step 5: Enable Analytics Debug Mode (for testing)

In Xcode:

1. Select `Runner` scheme > Edit Scheme
2. Go to Arguments tab
3. Add to "Arguments Passed On Launch":
   ```
   -FIRAnalyticsDebugEnabled
   ```

This enables real-time analytics viewing in Firebase Console > DebugView.

## Android Configuration (Already Done ✅)

Your Android configuration is already complete with:

- ✅ `android/app/google-services.json` in place
- ✅ Google Services plugin configured

### Enable Android Debug Mode (for testing)

```bash
adb shell setprop debug.firebase.analytics.app eleven_plus_vocabulary
```

## Verify Integration

### Method 1: Firebase Console DebugView

1. Run app with debug mode enabled
2. Go to Firebase Console > Analytics > DebugView
3. Use the app and watch events appear in real-time
4. Events should show up immediately

### Method 2: Check Logs

**iOS:**
Look for logs in Xcode console:

```
Firebase Analytics v.x.x.x started
```

**Android:**
Look for logs in Android Studio:

```
FA: Successfully uploaded data
```

## Testing Analytics

After setup, test key events:

1. **App Open**: Launch the app
    - Should log `app_open` event

2. **Screen Navigation**: Navigate between screens
    - Should automatically log screen views

3. **Practice Session**: Start practicing words
    - Should log `vocabulary_set_started`
    - Should log `word_practiced`

4. **Purchase Flow**: View a locked vocabulary set
    - Should log `product_viewed`

## Common Issues & Solutions

### Issue: Events not showing in Firebase Console

**Solution:**

- Events appear after 24 hours in main dashboard
- Use DebugView for real-time testing
- Ensure debug mode is enabled

### Issue: "Firebase not configured" error

**Solution:**

- Verify `GoogleService-Info.plist` is in `/ios/Runner/`
- Verify file is added to Xcode project target
- Clean and rebuild: `flutter clean && flutter pub get`

### Issue: iOS build fails with Firebase errors

**Solution:**

```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
flutter clean
flutter build ios
```

### Issue: Analytics not working on iOS Simulator

**Solution:**

- Firebase Analytics works on simulators (unlike some other services)
- Ensure you've initialized Firebase in `main.dart`
- Check Xcode console for Firebase initialization logs

## Privacy & App Store

### Privacy Manifest (Required for iOS)

You may need to add a Privacy Manifest for iOS apps. Create `ios/Runner/PrivacyInfo.xcprivacy`:

```xml
<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>NSPrivacyCollectedDataTypes</key>
        <array>
            <dict>
                <key>NSPrivacyCollectedDataType</key>
                <string>NSPrivacyCollectedDataTypeProductInteraction</string>
                <key>NSPrivacyCollectedDataTypeLinked</key>
                <false />
                <key>NSPrivacyCollectedDataTypeTracking</key>
                <false />
                <key>NSPrivacyCollectedDataTypePurposes</key>
                <array>
                    <string>NSPrivacyCollectedDataTypePurposeAnalytics</string>
                </array>
            </dict>
        </array>
        <key>NSPrivacyTracking</key>
        <false />
    </dict>
</plist>
```

### App Store Privacy Questions

When submitting to App Store, you'll need to declare:

**Data collected:**

- Product Interaction (for analytics)
- Usage Data (for analytics)

**Data use:**

- Analytics only
- Not linked to user identity
- Not used for tracking

## Next Steps

1. ✅ Dependencies installed
2. □ Add `GoogleService-Info.plist` to iOS
3. □ Run `cd ios && pod install`
4. □ Test with DebugView
5. □ Add analytics calls throughout the app (see `analytics_integration_examples.dart`)
6. □ Test on both iOS and Android
7. □ Review data in Firebase Console after 24 hours

## Firebase Console Dashboard

After 24 hours of data collection, you'll see:

- **Engagement:** Daily/Monthly Active Users
- **Events:** Top events and their frequency
- **Retention:** User return rate
- **Revenue:** In-app purchase tracking
- **User Properties:** Segmentation data
- **Funnels:** User journey analysis

## Resources

- [Firebase Analytics Documentation](https://firebase.google.com/docs/analytics)
- [Flutter Firebase Setup](https://firebase.google.com/docs/flutter/setup)
- [Firebase Console](https://console.firebase.google.com/)

