# App Store Copy — v2.0.4 (build 23)

## Promotional Text (max 170 chars)

Learn words in 9 languages by playing! Match 850+ picture words, hear each one said out loud, and build your streak. Vocab packs are now just $0.99 each.

## What's New (max 4000 chars)

• Added a "Restore Purchases" button so you can get your vocabulary packs back on a new device or after reinstalling — find it at the top of the Library tab and under Settings › Purchases
• Restoring now confirms exactly what was recovered instead of finishing silently

Enjoying MemoLingo? A quick review really helps us. Thank you!

## Notes for App Review

This build addresses the previous rejection (Guideline 3.1.1 — missing restore
mechanism for non-consumable In-App Purchases).

A distinct "Restore Purchases" control is now available in two places, and it
only ever starts a restore when the user taps it:

1. **Library tab** — a full-width "Restore Purchases" button directly below the
   "Vocabulary Library" header, visible without scrolling.
2. **Settings tab** — Settings › Purchases › "Restore Purchases".

Tapping either one calls `SKPaymentQueue.restoreCompletedTransactions` (via the
`in_app_purchase` plugin), waits for the restored transactions, re-unlocks every
recovered vocabulary pack, and confirms the result to the user (for example
"Restored 3 previous purchases." or "No previous purchases were found for this
Apple ID.").
