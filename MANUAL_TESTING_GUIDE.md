# Quick Manual Testing Guide for App Store Submission

## 🚀 Critical Tests (Must Complete Before Submission)

### Test 1: Fresh Install & First Launch (5 min)

1. Delete app from device
2. Install from TestFlight
3. Launch app
4. ✅ Check: App opens without crash
5. ✅ Check: No white flash on launch
6. ✅ Check: Bottom navigation shows

**Expected:** App opens smoothly to Practice screen

---

### Test 2: In-App Purchases - CRITICAL (10 min)

**This is the #1 reason for App Store rejection!**

#### A. Test Purchase Flow

1. Go to Library screen
2. Scroll to any unpurchased pack
3. Tap "Purchase" button
4. Complete purchase (use TestFlight sandbox account)
5. ✅ Check: Purchase completes successfully
6. ✅ Check: Pack shows as "Owned"
7. ✅ Check: Can now practice that pack

#### B. Test Restore Purchases

1. Delete and reinstall app
2. Go to Library screen
3. Scroll to bottom, tap "Restore Purchases"
4. ✅ Check: Loading dialog appears
5. ✅ Check: Success message shows
6. ✅ Check: All previously purchased packs are owned again

**Expected:** Purchases work perfectly, restore works perfectly

---

### Test 3: Practice Session (5 min)

1. Go to Practice screen
2. Select any owned vocabulary pack
3. Start practice session
4. ✅ Check: Audio plays when word appears
5. Answer 3-4 questions (mix correct/incorrect)
6. ✅ Check: Progress bar updates
7. Complete the test
8. ✅ Check: Results show correct score
9. Tap "Review Test Results"
10. ✅ Check: Both correct AND incorrect answers shown
11. ✅ Check: Your wrong answer + correct answer displayed

**Expected:** Full practice flow works smoothly

---

### Test 4: TTS in Release Mode (2 min)

**This was broken before - must verify it's fixed!**

1. Make sure you're testing the release build
2. Start any practice session
3. ✅ Check: Word pronunciation plays automatically
4. Tap speaker icon
5. ✅ Check: Word plays again
6. Adjust device volume
7. ✅ Check: Audio volume changes accordingly

**Expected:** TTS works perfectly in release mode

---

### Test 5: Stats Screen (3 min)

1. Go to Stats screen
2. ✅ Check: All stat cards same width (especially Accuracy)
3. ✅ Check: Overall Progress displays
4. ✅ Check: Mastery Levels chart shows
5. ✅ Check: Recent Activity populates
6. ✅ Check: Daily Streak shows correctly
7. Pull to refresh
8. ✅ Check: Data updates

**Expected:** Stats look good, cards aligned properly

---

### Test 6: Library & Preview (3 min)

1. Go to Library screen
2. ✅ Check: Stats overview shows (Total/Owned/Available)
3. Tap on unpurchased pack
4. ✅ Check: Can view words even without owning
5. Go back, tap owned pack
6. ✅ Check: Shows "Owned" status
7. Scroll to bottom
8. ✅ Check: "Restore Purchases" button visible

**Expected:** All packs accessible for preview, owned status clear

---

## 🎯 Quick Smoke Test (If Short on Time - 5 min)

Run this minimal test before submission:

1. ✅ App launches
2. ✅ Buy one pack (IAP works)
3. ✅ Restore purchases works
4. ✅ Practice session completes
5. ✅ TTS plays in release mode
6. ✅ Test results show correct + incorrect answers
7. ✅ No crashes

If all 7 pass → **READY TO SUBMIT**

---

## 📱 Test on Multiple Devices (Recommended)

### Minimum:

- iPhone (any model with latest iOS)

### Ideal:

- iPhone SE / 13 Mini (small screen)
- iPhone 14/15/16 (standard)
- iPhone Pro Max (large screen)

---

## 🔴 Red Flags - DO NOT SUBMIT if you see:

- ❌ App crashes on launch
- ❌ Purchase doesn't complete
- ❌ Restore purchases doesn't work
- ❌ TTS doesn't play
- ❌ Can't complete practice session
- ❌ Text overflow / UI broken
- ❌ Test results don't show answers

---

## ✅ Ready to Submit Checklist

Before clicking "Submit for Review":

- [ ] Tested fresh install
- [ ] Tested IAP purchase
- [ ] Tested restore purchases
- [ ] Completed full practice session
- [ ] Verified TTS works
- [ ] Checked all main screens
- [ ] No crashes encountered
- [ ] Screenshots uploaded (App Store Connect)
- [ ] Description written
- [ ] Privacy policy URL added
- [ ] Support email added
- [ ] IAP products activated in App Store Connect

---

## 📊 App Store Connect Setup

### Screenshots Required (per device size):

- 6.9" Display (iPhone 16 Pro Max)
- 6.5" Display (iPhone 15 Plus)
- 5.5" Display (iPhone 8 Plus)

### Required Info:

- **Name:** 11+ Vocabulary Master
- **Subtitle:** 11+ Exam Vocabulary Practice
- **Category:** Education
- **Age Rating:** 4+
- **Privacy Policy:** [Your URL]
- **Support URL:** [Your URL]

### IAP Products to Activate:

1. vocabulary_pack_1
2. vocabulary_pack_2
3. vocabulary_pack_3
4. vocabulary_pack_4
5. vocabulary_pack_5
6. all_vocabulary_packs

---

## 🚨 If You Find Issues

### Minor Issues (Can submit):

- Small text alignment
- Minor color inconsistencies
- Performance could be better

### Major Issues (Fix before submit):

- Crashes
- IAP not working
- Core features broken
- Data loss

---

## ⏱️ Submission Timeline

- **Today:** Upload to TestFlight, start testing
- **Tomorrow:** Complete all testing
- **Day 3:** Submit to App Store if tests pass
- **Day 4-6:** Apple review (usually 1-3 days)
- **Day 7:** Approved & ready for release 🎉

---

## 💡 Pro Tips

1. **Test restore purchases on a different device** - This catches most issues
2. **Test as a brand new user** - Delete and reinstall
3. **Complete at least 2 full practice sessions** - Catches data issues
4. **Check with real money turned off** - Use sandbox testers only
5. **Take screenshots during testing** - You'll need them anyway

---

**Current Build:** 1.0.1+5
**Status:** Build ready, needs manual testing
**Next Step:** Upload to TestFlight and run these tests

Good luck! 🍀

