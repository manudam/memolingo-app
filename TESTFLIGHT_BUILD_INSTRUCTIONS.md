# TestFlight Build Instructions - Version 1.0.1+9

## ⚠️ IMPORTANT: Use Xcode Method

The Flutter command line build requires an iOS Distribution certificate. The easiest method is to
use Xcode, which will handle signing automatically.

## Steps to Create and Upload to TestFlight

### 1. Version Information

- **Version**: 1.0.1
- **Build Number**: 9
- **Status**: Ready to build

### 2. Build the Archive Using Xcode (RECOMMENDED)

1. Open Xcode:
   ```bash
   open /Volumes/Data/Projects/eleven_plus_vocabulary/ios/Runner.xcworkspace
   ```

2. In Xcode:
    - Select **Product** → **Destination** → **Any iOS Device (arm64)**
    - Select **Product** → **Archive**
    - Wait for the build to complete (this may take 5-10 minutes)

3. When the archive completes, the **Organizer** window will open automatically

### 3. Upload to App Store Connect

1. In the Organizer window:
    - Select your archive (it should be the newest one at the top)
    - Click **Distribute App**

2. Select distribution method:
    - Choose **App Store Connect**
    - Click **Next**

3. Choose destination:
    - Select **Upload**
    - Click **Next**

4. App Store Connect options:
    - Keep all defaults checked:
        - ✓ Upload your app's symbols
        - ✓ Manage Version and Build Number
    - Click **Next**

5. Re-sign options:
    - Choose **Automatically manage signing**
    - Click **Next**

6. Review and Upload:
    - Review the summary
    - Click **Upload**
    - Wait for upload to complete

### 4. Process in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **TestFlight** tab
4. Wait for the build to process (usually 5-15 minutes)
5. Once processing completes, you'll need to:
    - Add "What to Test" notes
    - Add testers (internal or external)
    - Enable the build for testing

### 5. Changes in This Build

This build includes:

- Updated version number to 1.0.1+9
- All recent UI improvements (mastery colors, bottom bar, etc.)
- Bug fixes for test results calculations
- Profile customization features
- Token system implementation
- Recent activity tracking improvements

### Alternative: Command Line Upload (if Xcode GUI fails)

If you prefer command line or Xcode GUI has issues, you can use:

```bash
# First, create the archive
cd /Volumes/Data/Projects/eleven_plus_vocabulary
flutter build ipa --release

# The IPA will be at:
# build/ios/ipa/eleven_plus_vocabulary.ipa

# Then upload using Transporter app or:
xcrun altool --upload-app --type ios --file build/ios/ipa/eleven_plus_vocabulary.ipa --username your-apple-id@example.com --password your-app-specific-password
```

### Troubleshooting

**If build fails:**

1. Clean build folder: **Product** → **Clean Build Folder** (Cmd+Shift+K)
2. Delete derived data: **File** → **Workspace Settings** → **Derived Data** → **Delete**
3. Quit and restart Xcode
4. Try building again

**If signing fails:**

1. Open **Signing & Capabilities** in the Runner target
2. Ensure your Apple ID is signed in
3. Ensure "Automatically manage signing" is checked
4. Ensure correct Team is selected

**If upload fails:**

1. Check your internet connection
2. Try using the Transporter app instead
3. Verify your Apple Developer account status

## Next Steps After Upload

1. Monitor processing status in App Store Connect
2. Add testing notes when prompted
3. Add external testers if needed
4. Submit for review if ready for public release

---

**Note**: The build number has been incremented from 8 to 9. The version remains 1.0.1. If you want
to change the version number (e.g., to 1.0.2 or 1.1.0), update the `pubspec.yaml` file before
building.

