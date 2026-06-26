# App Store Submission Checklist - Eleven Plus Vocabulary

**Version:** 1.0.1 (Build 5)
**Date:** October 13, 2025

## ✅ Pre-Submission Testing Checklist

### 1. Core Functionality Tests

- [ ] **App Launch**
    - App launches without crashes
    - Splash screen displays correctly
    - No white screen flash on iOS

- [ ] **Library Screen**
    - View all vocabulary packs
    - See owned vs available packs
    - "Restore Purchases" button at bottom works
    - Can preview words in unpurchased packs
    - Stats overview displays correctly

- [ ] **Practice Screen**
    - Start practice session
    - TTS (Text-to-Speech) works in release mode
    - Questions display properly
    - Answer selection works
    - Progress bar updates correctly
    - Navigation between questions smooth

- [ ] **Test Results**
    - Completion screen shows correct score
    - Review results shows all questions
    - Both correct AND incorrect answers displayed
    - Correct/incorrect indicators work
    - Mastery level updates

- [ ] **Stats Screen**
    - Overall progress displays
    - Mastery levels chart works
    - Recent activity shows
    - Achievements display
    - Daily streak tracking works
    - All stat cards same width

- [ ] **Vocabulary Words Screen**
    - Word list displays
    - Search functionality works
    - Filter by mastery works
    - Word details show correctly

### 2. In-App Purchases (Critical for App Store)

- [ ] **IAP Setup**
    - Products load correctly
    - Prices display in correct currency
    - Purchase flow works
    - Receipt validation works
    - Restore purchases works
    - Purchase completion unlocks content

- [ ] **StoreKit Testing (iOS)**
    - Test all product IDs:
        - vocabulary_pack_1
        - vocabulary_pack_2
        - vocabulary_pack_3
        - vocabulary_pack_4
        - vocabulary_pack_5
        - all_vocabulary_packs
    - Test purchase success
    - Test purchase cancellation
    - Test restore purchases
    - Test "Ask to Buy" scenario

### 3. UI/UX Tests

- [ ] **Responsive Design**
    - iPhone SE (small screen)
    - iPhone 16 Pro (standard)
    - iPhone 16 Pro Max (large)
    - iPad (if supported)

- [ ] **Navigation**
    - Bottom navigation bar works
    - Back buttons work
    - Screen transitions smooth
    - No navigation dead ends

- [ ] **Visual Design**
    - App icon displays correctly
    - Colors consistent throughout
    - Text readable on all screens
    - No UI overflow errors
    - Cards/buttons aligned properly

### 4. Performance Tests

- [ ] **Memory Usage**
    - No memory leaks
    - App doesn't crash after extended use
    - Smooth scrolling in long lists

- [ ] **Storage**
    - User data saves correctly
    - Progress persists after app restart
    - Purchases persist

- [ ] **Network (IAP)**
    - Handles no internet gracefully
    - Retry mechanism works
    - Error messages clear

### 5. App Store Requirements

- [ ] **Metadata Ready**
    - App name: "11+ Vocabulary Master"
    - Description prepared
    - Keywords optimized
    - Screenshots prepared (required sizes)
    - App preview video (optional but recommended)
    - Privacy policy URL
    - Support URL

- [ ] **Privacy & Permissions**
    - Privacy policy updated
    - NSMicrophoneUsageDescription (if needed)
    - NSSpeechRecognitionUsageDescription included
    - Data collection disclosed

- [ ] **App Store Connect**
    - Bundle ID matches: com.elevenplusvocabularywords.elevenPlusVocabulary
    - Version 1.0.1 ready
    - Build 5 uploaded
    - IAP products created and approved
    - Tax forms completed
    - Banking info set up

### 6. Release Mode Specific Tests

- [ ] **TTS in Release Mode**
    - Text-to-speech works (not just debug)
    - Audio plays on all devices
    - Volume controls work

- [ ] **No Debug Code**
    - Debug FAB not visible in release
    - No debug prints
    - No test data visible

### 7. Edge Cases

- [ ] **First Time User**
    - Onboarding clear
    - No errors on fresh install
    - Can start practicing immediately with owned packs

- [ ] **Returning User**
    - Data restored
    - Progress maintained
    - Streak continues correctly

- [ ] **Error Handling**
    - Graceful error messages
    - No cryptic errors shown
    - User can recover from errors

## 📝 Known Issues to Fix Before Submission

1. **Launch Screen** - Warning about placeholder launch image (cosmetic, not blocking)

## 🚀 Submission Steps

### 1. Upload to TestFlight

- [x] Build created (1.0.1+5)
- [ ] Upload via Transporter
- [ ] Wait for processing (10-30 min)
- [ ] Add "What to Test" notes
- [ ] Submit for internal testing

### 2. TestFlight Testing (Recommended)

- [ ] Install from TestFlight
- [ ] Test all functionality above
- [ ] Test IAP with real products
- [ ] Get feedback from 2-3 testers
- [ ] Fix any critical bugs

### 3. App Store Submission

- [ ] Submit for review
- [ ] Select age rating
- [ ] Add app description
- [ ] Upload screenshots
- [ ] Set pricing
- [ ] Enable IAP products
- [ ] Submit for review

### 4. Post-Submission

- [ ] Monitor status
- [ ] Respond to review feedback quickly
- [ ] Prepare for release

## ⚠️ Common Rejection Reasons to Avoid

1. ❌ **IAP Issues**
    - Products not working
    - Restore not implemented ✅ (We have this!)
    - Wrong price display

2. ❌ **Crashes**
    - App crashes on launch
    - Crashes during core functionality

3. ❌ **Incomplete Information**
    - Missing privacy policy
    - Incomplete metadata

4. ❌ **Design Issues**
    - UI looks unfinished
    - Buttons don't work
    - Text overflow

## 📧 Support Information Needed

Prepare these for App Store Connect:

- **Support Email:** [Your email]
- **Privacy Policy URL:** [Your URL]
- **Marketing URL:** [Your website]

## 🎯 Testing Priority

**HIGH PRIORITY (Must work perfectly):**

1. ✅ App launches
2. ✅ IAP & Restore purchases
3. ✅ Practice sessions
4. ✅ TTS in release mode
5. ✅ Data persistence

**MEDIUM PRIORITY (Should work well):**

1. ✅ Stats tracking
2. ✅ UI consistency
3. ✅ Navigation
4. ✅ Error handling

**LOW PRIORITY (Nice to have):**

1. ⚠️ Launch screen customization
2. Performance optimizations
3. Advanced features

## 📱 Test Devices Recommended

- iPhone SE (iOS 15+) - Minimum supported
- iPhone 14/15/16 - Current generation
- iPad (if supporting)

## ⏱️ Timeline Estimate

- **TestFlight Upload:** 10 minutes
- **TestFlight Processing:** 10-30 minutes
- **Internal Testing:** 1-2 days
- **App Store Submission:** 30 minutes
- **Apple Review:** 1-3 days
- **Total:** ~5-7 days to approval

---

**Last Updated:** October 13, 2025
**Build Version:** 1.0.1+5
**Status:** Ready for TestFlight testing

