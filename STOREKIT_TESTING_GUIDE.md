# StoreKit Testing Guide for iOS Simulator

## Problem

When running in the iOS simulator, in-app purchases return "0 products loaded" because the StoreKit
configuration file isn't being used automatically.

## Solution: Enable StoreKit Configuration in Xcode

### Method 1: Run from Xcode (Recommended for Testing IAP)

1. **Open the project in Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Select the StoreKit Configuration File:**
    - In Xcode, go to **Product → Scheme → Edit Scheme** (or press Cmd+<)
    - Select **Run** in the left sidebar
    - Go to the **Options** tab
    - Under **StoreKit Configuration**, click the dropdown
    - Select **Products.storekit**
    - Click **Close**

3. **Run the app from Xcode:**
    - Select a simulator from the device dropdown
    - Click the Play button (or press Cmd+R)
    - The app will now use the local StoreKit configuration file

### Method 2: Configure for Flutter Run

Unfortunately, when using `flutter run` directly, the StoreKit configuration isn't automatically
picked up. You have two options:

**Option A: Always launch from Xcode** (for IAP testing)

**Option B: Test on a Real Device**

- Real devices will connect to the actual App Store or Sandbox environment
- This is the most reliable way to test IAP

## Verifying It Works

When the StoreKit configuration is properly loaded, you should see:

- Debug logs showing 6 products loaded (5 individual packs + 1 bundle)
- Product prices displayed correctly in the UI
- No "Product not found" errors when clicking Purchase

## Current StoreKit Products Configured

The `Products.storekit` file has these products configured:

1. **vocabulary_pack_1** - $0.99 - Vocabulary Set 1
2. **vocabulary_pack_2** - $0.99 - Vocabulary Set 2
3. **vocabulary_pack_3** - $0.99 - Vocabulary Set 3
4. **vocabulary_pack_4** - $0.99 - Vocabulary Set 4
5. **vocabulary_pack_5** - $0.99 - Vocabulary Set 5
6. **all_vocabulary_packs** - $2.99 - Complete Vocabulary Bundle

## Testing Purchases in Simulator

Once the StoreKit configuration is active:

1. Click on any "Purchase" button
2. A simulated purchase dialog will appear
3. Click "Subscribe" or "Buy" (it's free in testing)
4. The purchase will complete immediately
5. The pack should unlock and show as "Owned"

## Testing the Bundle

1. Scroll to the bottom of the Library screen
2. Click "Buy Complete Bundle"
3. Complete the simulated purchase
4. All 5 vocabulary packs should immediately unlock

## Troubleshooting

**Still seeing "0 products loaded"?**

- Make sure you're running from Xcode with StoreKit configuration selected
- Clean build: Product → Clean Build Folder (Shift+Cmd+K)
- Restart the simulator
- Try a different simulator device

**Products load but purchase fails?**

- Check that the product IDs match exactly in Products.storekit
- Make sure the StoreKit configuration version is 4.0 or higher
- Try deleting and reinstalling the app

**Testing on Real Device:**

- You'll need to configure Sandbox test users in App Store Connect
- See ANDROID_IAP_TESTING.md for more details on real device testing

