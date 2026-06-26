# Analytics Integration Guide

## Overview

This app uses **Firebase Analytics** to track user engagement, learning patterns, and in-app
purchase behavior. Analytics help us understand how students use the app and improve the learning
experience.

## Key Events to Track

### 1. User Engagement

- **app_open**: Track when users open the app
- **session_duration**: How long users spend in the app
- **daily_streak_achieved**: When users maintain learning streaks

### 2. Learning Activity

- **vocabulary_set_started**: When a user begins a vocabulary set
- **vocabulary_set_completed**: When a user completes all words in a set
- **word_practiced**: Each time a word is practiced (with rating)
- **word_rating_changed**: When user changes confidence rating
- **pronunciation_played**: When audio pronunciation is used
- **practice_session_completed**: End of a practice session with duration

### 3. Progress & Achievement

- **progress_milestone**: 25%, 50%, 75%, 100% completion of a set
- **all_sets_completed**: When user masters all vocabulary sets
- **stats_viewed**: When users check their progress

### 4. In-App Purchases

- **product_viewed**: When user views a vocabulary set purchase
- **purchase_initiated**: When purchase flow starts
- **purchase_completed**: Successful purchase (with product ID and price)
- **purchase_failed**: Failed purchase (with error reason)
- **bundle_purchased**: Complete bundle purchase

### 5. User Retention

- **first_app_open**: Track new user onboarding
- **returning_user**: Users who come back after 24+ hours
- **onboarding_completed**: If you add onboarding flow

## Privacy Considerations

✓ Firebase Analytics is GDPR/COPPA compliant when configured correctly
✓ No personally identifiable information (PII) is tracked
✓ All data is anonymized
✓ Users under 13 are handled appropriately for education apps

## Analytics Dashboard Insights

You can use Firebase Console to view:

- Daily/Weekly/Monthly active users
- User retention rates
- Most popular vocabulary sets
- Average practice session duration
- Conversion rates for in-app purchases
- User journey funnels

## Implementation

The `AnalyticsService` class wraps Firebase Analytics and provides type-safe event logging
throughout the app.

## Testing Analytics

### Development

- Use Firebase DebugView to see events in real-time
- Run: `adb shell setprop debug.firebase.analytics.app eleven_plus_vocabulary` (Android)
- iOS: Add `-FIRAnalyticsDebugEnabled` to scheme arguments

### Production

- Events appear in Firebase Console within 24 hours
- Use DebugView for immediate verification

## Best Practices

1. **Don't over-track**: Focus on actionable metrics
2. **Consistent naming**: Use snake_case for event names
3. **Add context**: Include relevant parameters (set_id, word_count, etc.)
4. **Track failures**: Understand where users struggle
5. **Respect privacy**: Never log sensitive data

## Future Enhancements

- A/B testing for UI changes
- Remote Config for feature flags
- Predictive analytics for churn prevention
- Custom audiences for targeted features

