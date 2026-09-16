# iOS Listing Screenshots

Generates App Store screenshots directly from the live app UI, fed with fixture
data, composited onto a marketing "poster" (gradient background + headline +
device frame) and captured to PNG. No manual simulator screenshots needed.
Same approach as Planner Pig's `tool/generate_ios_listing_screenshots.dart`.

## Generate The Set

From `/Volumes/Data/Projects/memolingo-app` run:

```bash
dart run tool/generate_ios_listing_screenshots.dart
```

This launches `flutter run -d macos -t lib/marketing_capture.dart` once per
screen/device combination, so it needs the macOS desktop target set up
(already the case — `macos/` is checked in).

Images are written to:

```text
build/marketing/ios_listing/
```

## Output Folders

- `iphone_67/`: `1284x2778` portrait screenshots for the App Store `6.7"` iPhone slot
  (App Store Connect also accepts these dimensions under the `6.5"` bucket).
- `ipad_13/`: `2732x2048` landscape screenshots for the App Store `13"` iPad slot.

## Current Sequence

1. `01-practice.png` — the Practice "journey" home screen.
2. `02-game.png` — a game round in progress (combo + partial progress).
3. `03-result.png` — the win/celebration screen.
4. `04-library.png` — vocabulary packs, some owned, some purchasable.
5. `05-category-words.png` — word list with images and mastery dots.
6. `06-stats.png` — the stats dashboard.

## Notes

- Fixture data (mastery, streaks, XP, purchased categories) lives in
  `lib/marketing_capture.dart`. Word ids are derived from the real bundled CSV
  (`assets/memolingo/data/words_list_full.csv`) so mastery seeding always
  lines up with real category/word data.
- To change copy, ordering, or which categories/screens are featured, edit the
  `listing-*` specs in [lib/marketing_capture.dart](/Volumes/Data/Projects/memolingo-app/lib/marketing_capture.dart).
- The macOS window is sized per-target via `MARKETING_WINDOW_WIDTH` /
  `MARKETING_WINDOW_HEIGHT` env vars, read in
  [macos/Runner/MainFlutterWindow.swift](/Volumes/Data/Projects/memolingo-app/macos/Runner/MainFlutterWindow.swift).
  Normal `flutter run -d macos` runs are unaffected — those env vars are only
  set by the generator script.
