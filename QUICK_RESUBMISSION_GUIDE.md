# Quick Upload Guide - Build 13

## 🚀 Upload Build to App Store Connect

### Step 1: Upload via Transporter

1. Open **Transporter** app
2. Click the **+** button or drag and drop:
   ```
   /Volumes/Data/Projects/eleven_plus_vocabulary/build/ios/ipa/eleven_plus_vocabulary.ipa
   ```
3. Click **Deliver**
4. Wait for upload to complete (~5-10 minutes)

### Step 2: Respond to Apple Review

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **My Apps** → **11+ Vocabulary Master**
3. Find the review feedback in **Resolution Center**
4. Click **Reply to App Review**

**Copy/paste this response:**

---

**Subject: Re: Guideline 2.1 and 2.5.4**

Hello Apple Review Team,

Thank you for your detailed feedback. We have addressed both issues in build 13:

**Regarding Guideline 2.1 (In-App Purchases):**

We are using the Flutter in_app_purchase plugin (v3.1.13) which properly handles receipt validation
for both production and sandbox environments. The implementation follows Apple's recommended
approach:

1. Validates against production App Store first
2. If validation fails with "Sandbox receipt used in production," validates against test environment

The Paid Apps Agreement has been accepted, and all IAP products are properly configured in App Store
Connect. We have extensively tested the IAP functionality using StoreKit testing.

**Regarding Guideline 2.5.4 (Background Audio):**

We have removed the UIBackgroundModes audio declaration from our Info.plist in build 13. Our app
only uses text-to-speech to pronounce vocabulary words while the app is in the foreground, which
does not require persistent background audio capability.

Build 13 has been uploaded and is ready for re-review.

Thank you,
[Your Name]

---

### Step 3: Submit for Review

1. In App Store Connect, go to **11+ Vocabulary Master**
2. Select version **1.0.1**
3. Verify build **13** is selected
4. Click **Submit for Review**

---

## ✅ Verification Checklist

Before submitting:

- [ ] Build 13 uploaded successfully to App Store Connect
- [ ] Build 13 shows as "Processing" then "Ready to Submit"
- [ ] Response sent to Apple Review team
- [ ] All metadata and screenshots are current
- [ ] Privacy policy URL is working
- [ ] Support URL is working

---

## ⏱️ Timeline

- **Upload**: ~5-10 minutes
- **Processing**: ~15-30 minutes
- **Review Wait**: 1-3 days (typically)
- **Review Process**: Few hours to 1 day

---

## 🔍 What Apple Will Test

1. **IAP on iPad**: Purchase flow should work without errors
2. **Background Audio**: Verify no background audio modes
3. **Audio Pronunciation**: Should work in foreground only
4. **General Functionality**: App should work normally

---

## 📱 Test on TestFlight First (Optional but Recommended)

1. Wait for build to process (~30 minutes)
2. Add build to TestFlight
3. Install on iPad Air (if available)
4. Test purchase flow
5. Verify audio works
6. Confirm no issues before submitting to review

---

## 🆘 If Issues Arise

### IAP Still Shows Error

- Check Paid Apps Agreement is accepted
- Verify all products are "Ready to Submit" status
- Check product IDs match in app and App Store Connect

### Build Rejected Again

- Review detailed feedback
- Test on physical iPad if possible
- Consider requesting more details from Apple

### Processing Takes Too Long

- Normal processing: 15-30 minutes
- If > 2 hours, contact Apple Support

---

## 📞 Support Contacts

- **App Store Connect**: appstoreconnect.apple.com
- **Developer Support**: developer.apple.com/contact
- **Phone**: Through developer account

---

## 🎯 Success Indicators

✅ Build shows "Ready to Submit" status  
✅ No warnings in App Store Connect  
✅ All capabilities properly configured  
✅ Screenshots and metadata complete  
✅ Response sent to review team

---

## After Approval

1. Monitor analytics
2. Check for crash reports
3. Watch for user feedback
4. Plan next update if needed

---

**Good luck with the resubmission! 🎉**

