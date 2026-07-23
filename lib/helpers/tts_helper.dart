import 'dart:io' show Platform;

import 'package:flutter_tts/flutter_tts.dart';
import 'package:win32_registry/win32_registry.dart';

const Map<String, String> _ttsLocaleMap = {
  'en': 'en-GB',
  'es': 'es-ES',
  'fr': 'fr-FR',
  'de': 'de-DE',
  'it': 'it-IT',
  'ru': 'ru-RU',
  'ko': 'ko-KR',
  'zh-CN': 'zh-CN',
  'ja': 'ja-JP',
  'nl': 'nl-NL',
};

String ttsLocaleFor(String languageCode) =>
    _ttsLocaleMap[languageCode] ?? 'en-GB';

const double defaultTtsSpeechRate = 0.42;

Future<void> configureTts(
  FlutterTts tts,
  String languageCode, {
  double? speechRate,
  Map<String, String>? voice,
}) async {
  final locale = ttsLocaleFor(languageCode);
  final langPrefix = locale.split('-').first;

  if (voice != null) {
    await tts.setVoice(voice);
  } else {
    final voices = await tts.getVoices;
    if (voices is List) {
      Map<String, String>? exactMatch;
      Map<String, String>? langMatch;

      for (final v in voices) {
        if (v is! Map) continue;
        final voiceLocale = (v['locale'] ?? '') as String;
        final voiceName = (v['name'] ?? '') as String;
        if (voiceLocale == locale) {
          exactMatch ??= {'name': voiceName, 'locale': voiceLocale};
        } else if (voiceLocale.startsWith(langPrefix)) {
          langMatch ??= {'name': voiceName, 'locale': voiceLocale};
        }
      }

      final match = exactMatch ?? langMatch;
      if (match != null) {
        await tts.setVoice(match);
      } else {
        await tts.setLanguage(locale);
      }
    } else {
      await tts.setLanguage(locale);
    }
  }

  await tts.setSpeechRate(speechRate ?? defaultTtsSpeechRate);
  await tts.setVolume(1.0);
}

/// Returns the on-device voices available for [languageCode], for use in a
/// voice picker. Each entry has 'name' and 'locale' keys.
Future<List<Map<String, String>>> getVoicesForLanguage(
    String languageCode) async {
  final locale = ttsLocaleFor(languageCode);
  final langPrefix = locale.split('-').first;

  final tts = FlutterTts();
  final voices = await tts.getVoices;
  if (voices is! List) return [];

  final matches = <Map<String, String>>[];
  for (final v in voices) {
    if (v is! Map) continue;
    final voiceLocale = (v['locale'] ?? '') as String;
    final voiceName = (v['name'] ?? '') as String;
    if (voiceName.isEmpty) continue;
    if (voiceLocale == locale || voiceLocale.startsWith(langPrefix)) {
      matches.add({'name': voiceName, 'locale': voiceLocale});
    }
  }
  return matches;
}

/// On Windows, `flutter_tts` only enumerates the classic desktop SAPI5 voice
/// registry, not the newer "OneCore" voices installed via Settings > Time &
/// Language > Speech. Those are registered as subkeys named like
/// `MSTTS_V110_frFR_HortenseM`, so we read the locale straight out of the
/// key name rather than duplicating the LCID lookup `flutter_tts` does.
Set<String> _oneCoreVoiceLocales() {
  final locales = <String>{};
  if (!Platform.isWindows) return locales;

  try {
    final key = Registry.openPath(
      RegistryHive.localMachine,
      path: r'SOFTWARE\Microsoft\Speech_OneCore\Voices\Tokens',
    );
    final localePattern = RegExp(r'^([a-z]{2,3})([A-Z]{2})$');
    for (final subKeyName in key.subkeyNames) {
      final parts = subKeyName.split('_');
      if (parts.length < 3) continue;
      final match = localePattern.firstMatch(parts[2]);
      if (match != null) {
        locales.add('${match.group(1)}-${match.group(2)}');
      }
    }
    key.close();
  } catch (_) {
    // Registry path may not exist on this device; ignore.
  }

  return locales;
}

/// Returns the set of app language codes that have a TTS voice on this device.
Future<Set<String>> getAvailableTtsLanguages() async {
  final tts = FlutterTts();
  final voices = await tts.getVoices;

  final deviceLocales = <String>{..._oneCoreVoiceLocales()};
  if (voices is List) {
    for (final v in voices) {
      if (v is! Map) continue;
      final locale = (v['locale'] ?? '') as String;
      if (locale.isNotEmpty) deviceLocales.add(locale);
    }
  }

  final available = <String>{};
  for (final entry in _ttsLocaleMap.entries) {
    final locale = entry.value;
    final langPrefix = locale.split('-').first;
    if (deviceLocales.contains(locale) ||
        deviceLocales.any((l) => l.startsWith(langPrefix))) {
      available.add(entry.key);
    }
  }

  return available;
}
