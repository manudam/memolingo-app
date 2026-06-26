# Audio Settings Feature

## Overview

This feature allows users to disable the word pronunciation audio (TTS) so they can continue
listening to their own music (e.g., Spotify) while using the app.

## What Was Changed

### 1. Created AudioSettingsService

- **File**: `lib/Services/audio_settings_service.dart`
- **Purpose**: Manages user audio preferences
- **Features**:
    - Stores audio enabled/disabled state using SharedPreferences
    - Persists preference across app sessions
    - Provides simple API to check and toggle audio state

### 2. Updated VocabularyPractice Provider

- **File**: `lib/providers/vocabulary_practice.dart`
- **Changes**:
    - Integrated AudioSettingsService
    - Updated `speak()` method to check audio settings before speaking
    - Changed iOS audio category from `playback` to `ambient` with `mixWithOthers` option
    - This allows the app's TTS to play alongside music from other apps

### 3. Created Settings Screen

- **File**: `lib/screens/settings/settings_screen.dart`
- **Features**:
    - Toggle switch for Word Pronunciation
    - Clear feedback when audio is enabled/disabled
    - Professional UI matching app design
    - About section with app information

### 4. Updated Bottom Navigation Bar

- **File**: `lib/widgets/bottom_bar.dart`
- **Changes**:
    - Added 4th navigation item for Settings
    - Settings icon and label
    - Navigation routing to SettingsScreen

### 5. Updated Main App Setup

- **File**: `lib/main.dart`
- **Changes**:
    - Registered AudioSettingsService in the service locator
    - Initialize AudioSettingsService on app startup
    - Loads saved audio preferences before app runs

### 6. Updated Screen Exports

- **File**: `lib/screens/screens.dart`
- **Changes**:
    - Added export for SettingsScreen

## iOS Audio Configuration

The app now uses the following iOS audio session configuration:

- **Category**: `ambient` (instead of `playback`)
- **Options**:
    - `mixWithOthers` - Allows music from other apps to continue playing
    - `duckOthers` - Temporarily lowers other audio when TTS speaks
- **Mode**: `spokenAudio` - Optimized for speech

This configuration ensures that:

1. Spotify and other music apps can continue playing in the background
2. The TTS audio briefly lowers the music volume when speaking
3. Music resumes normal volume after TTS finishes
4. When audio is disabled, the app won't interfere with music at all

## User Experience

### When Audio is Enabled (Default):

- Words are pronounced during practice tests
- Background music is temporarily ducked when TTS speaks
- Music returns to normal volume after pronunciation

### When Audio is Disabled:

- No TTS audio is played
- User's music continues uninterrupted
- App functions normally without audio feedback
- Perfect for listening to music while studying

## Usage

Users can access the settings by:

1. Tapping the Settings icon in the bottom navigation bar
2. Toggling the "Word Pronunciation" switch
3. Setting is saved immediately and persists across app restarts

## Testing Recommendations

1. **Test with Spotify/Music Playing**:
    - Start playing music in Spotify
    - Open the app and start a practice test
    - Verify music continues playing
    - Verify TTS ducks music when speaking (if audio enabled)

2. **Test Settings Toggle**:
    - Go to Settings screen
    - Toggle audio on/off
    - Start practice test and verify audio respects the setting
    - Close and reopen app - verify setting persists

3. **Test Navigation**:
    - Navigate between all bottom bar items
    - Verify Settings screen loads correctly
    - Verify back navigation works properly

## Future Enhancements

Possible future additions:

- Volume control for TTS
- Speech rate adjustment
- Voice selection (male/female, different accents)
- Audio preview in settings
- Per-vocabulary-pack audio settings

