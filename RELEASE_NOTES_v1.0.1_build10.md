# Version 1.0.1 Build 10 - Release Notes

**Release Date:** November 5, 2025

## 🎵 New Features

### Audio Settings

- **NEW: Settings Screen** - Access app settings via new Settings tab in bottom navigation
- **Configurable Audio** - Toggle word pronunciation on/off to allow background music to continue
- **Music-Friendly Mode** - Listen to Spotify, Apple Music, or any other audio while using the app
- **Smart Audio Ducking** - When audio is enabled, background music briefly lowers during
  pronunciation then returns to normal volume
- **Persistent Preferences** - Audio settings are saved and remembered across app sessions

## 🔧 Technical Improvements

### Audio System

- Updated iOS audio session to use `ambient` category with `mixWithOthers` option
- Implemented audio ducking for better user experience when both app audio and music are playing
- Added `AudioSettingsService` for centralized audio preference management

### UI Enhancements

- Added Settings navigation item to bottom bar with professional gear icon
- Created modern Settings screen with toggle switches and clear feedback
- Improved user feedback with snackbar messages when changing settings

## 📱 User Experience

### For Music Listeners

- You can now use the app while listening to your favorite music without interruption
- Simply turn off "Word Pronunciation" in Settings to silence TTS completely
- Or keep it on and enjoy both pronunciation and music with smart ducking

### Navigation

- Settings accessible from any screen via bottom navigation bar
- Quick access to audio preferences
- Professional and intuitive interface

## 🐛 Bug Fixes

- Fixed audio session configuration to properly mix with other apps
- Improved TTS initialization to handle iOS audio sessions correctly

## 📋 What's Working

All existing features continue to work perfectly:

- Vocabulary practice tests
- Progress tracking and mastery levels
- Achievement system
- Daily streaks
- Profile customization with tokens and cosmetics
- Statistics and analytics
- In-app purchases for vocabulary packs

## 🎯 Focus Areas for Testing

Please test the following scenarios:

1. **Music + Audio Disabled**: Start Spotify, disable audio in Settings, use the app - music should
   play uninterrupted
2. **Music + Audio Enabled**: Start Spotify, enable audio in Settings, start practice - music should
   duck during pronunciation
3. **Settings Persistence**: Change audio setting, close app, reopen - setting should be remembered
4. **Navigation**: Test switching between Practice, Stats, Library, and Settings tabs

## 📝 Known Issues

- None currently identified

## 🔮 Coming Soon

- Additional audio settings (volume control, speech rate)
- More customization options in Settings
- Profile enhancements

---

**Version:** 1.0.1 (Build 10)
**Platform:** iOS
**Distribution:** TestFlight

