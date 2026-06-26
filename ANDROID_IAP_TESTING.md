# Android In-App Purchase Testing Guide

## Overview

This guide will help you test in-app purchases on Android using the Flutter in_app_purchase plugin.

## Setup Complete ✅

### 1. Android Manifest Configuration

- Added `BILLING` permission to `android/app/src/main/AndroidManifest.xml`
- This allows your app to communicate with Google Play Billing

### 2. Test Configuration Files

- Created `android/app/src/debug/assets/billing_test_config.json` with your product definitions
- Added Android-specific test helper with comprehensive logging

### 3. Debug Testing Screen

- Created IAP test screen at `/lib/screens/debug/iap_test_screen.dart`
- Added debug floating action button (🐛) to Library screen (only visible in debug mode)
- Integrated comprehensive logging and error handling

## Testing Methods

### Method 1: Local Testing (No Google Play Console needed)

Your app is configured for local testing with mock products. In debug mode:

1. **Build and run your app in debug mode:**
   ```bash
   flutter run --debug
   ```

2. **Access the test screen:**
    - Go to the Library screen
    - Tap the orange debug button (🐛) in the bottom right
    - This opens the IAP Test Screen

3. **Test IAP functionality:**
    - Initialize IAP service
    - Load products (will show mock products in debug mode)
    - Test purchase flows
    - View comprehensive logs

### Method 2: Google Play Console Testing

#### Step 1: Upload to Internal Testing

1. Build a release APK:
   ```bash
   flutter build apk --release
   ```

2. Upload to Google Play Console → Internal Testing

#### Step 2: Configure Products

In Google Play Console, create these products:

- `vocabulary_pack_1` - $2.99 (Non-consumable)
- `vocabulary_pack_2` - $2.99 (Non-consumable)
- `vocabulary_pack_3` - $2.99 (Non-consumable)
- `vocabulary_pack_4` - $2.99 (Non-consumable)
- `vocabulary_pack_5` - $2.99 (Non-consumable)
- `all_vocabulary_packs` - $9.99 (Non-consumable)

#### Step 3: Test with Real Accounts

1. Add test accounts in Google Play Console
2. Download app from Play Store (Internal Testing track)
3. Test purchases with test accounts

### Method 3: Google Play Billing Test Cards

Google provides special test cards that simulate different purchase scenarios:

- **Always succeeds**: Use any valid test credit card
- **Always declines**: Use declined test cards
- **Cancelled**: Cancel the purchase flow

## Debug Features

### IAP Test Screen Features:

- **Real-time logging**: See exactly what's happening during IAP operations
- **Product loading**: Test product discovery from Google Play
- **Purchase simulation**: Test the complete purchase flow
- **Error handling**: See detailed error messages
- **Purchase restoration**: Test purchase restoration

### Logging:

All IAP operations are logged with timestamps and detailed information:

- Initialization status
- Product loading results
- Purchase attempts and results
- Error conditions
- Purchase restoration

## Testing Checklist

### Basic Functionality:

- [ ] IAP service initializes successfully
- [ ] Products load correctly
- [ ] Purchase flow starts without errors
- [ ] Purchase completion is handled
- [ ] Purchase restoration works
- [ ] Error states are handled gracefully

### Error Scenarios:

- [ ] No internet connection
- [ ] Invalid product IDs
- [ ] Cancelled purchases
- [ ] Already owned products
- [ ] Payment method issues

### Integration:

- [ ] Library screen shows purchase status correctly
- [ ] Purchased packs become available for practice
- [ ] Purchase state persists between app restarts

## Common Issues & Solutions

### Products not loading:

- Check internet connection
- Verify product IDs match exactly
- Ensure app is signed and uploaded to Play Console (for real testing)

### Purchases not working:

- Check Google Play Services are updated
- Verify billing permission in manifest
- Test with different Google accounts

### Testing in simulator:

- Use debug mode with mock products
- Real billing only works on physical devices with Google Play

## Next Steps

1. **Test locally** using the debug screen
2. **Build release APK** when ready for Google Play Console testing
3. **Configure products** in Google Play Console
4. **Test with internal testing track**
5. **Release to production** when testing is complete

The debug IAP test screen will help you verify everything works before uploading to Google Play
Console!
