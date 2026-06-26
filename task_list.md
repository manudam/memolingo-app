# Memolingo Modernization Task List

## Phase 0: Project Rebranding & Cleanup
- `[x]` Update Android package name to `com.trianglecarrot.memolingo`
- `[x]` Update iOS bundle ID to `com.trianglecarrot.memolingo`
- `[x]` Update app names (AndroidManifest.xml, Info.plist, pubspec.yaml)
- `[x]` Update README.md
- `[x]` Clean up UI strings referencing "11+ Vocabulary"

## Phase 1: Content Expansion & In-App Purchases
- `[ ]` Expand word count in `words_list_full.csv` for all 17 categories
- `[ ]` Generate missing image assets for all new words
- `[ ]` Add translations in 9 languages for all new words
- `[ ]` Verify In-App Purchase experience matches 11+ Vocabulary Master

## Phase 2: Unlock Multi-Language Capabilities
- `[x]` Add language selection screen (Target & Native language)
- `[x]` Update `AppUser` model with language preferences
- `[x]` Update `GameProvider` to use selected target language
- `[x]` Dynamically configure Text-To-Speech (TTS) based on target language

## Phase 3: Gamification & Engagement (Playful UI)
- `[x]` Implement playful UI theme (vibrant colors, rounded edges)
- `[x]` Add Daily Streaks system
- `[x]` Add XP & Leveling system
- `[x]` Add visual polish (haptic feedback, animations, confetti)

## Phase 4: Enhanced Learning Mechanics
- `[x]` Implement audio-only question type
- `[x]` Implement reverse translation question type
- `[x]` Implement spelling/typing question type
- `[x]` Introduce Spaced Repetition System (SRS) for word reviews

## Phase 5: Duolingo-style Journey UI
- `[x]` Design and build Journey map screen
- `[x]` Add visual nodes for each category/level
- `[x]` Connect nodes with dashed path
- `[x]` Replace linear list in Practice screen
