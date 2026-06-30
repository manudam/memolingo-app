import 'package:flutter_tts/flutter_tts.dart';

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

Future<void> configureTts(FlutterTts tts, String languageCode) async {
  final locale = ttsLocaleFor(languageCode);
  final langPrefix = locale.split('-').first;

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

  await tts.setSpeechRate(0.42);
  await tts.setVolume(1.0);
}

/// Returns the set of app language codes that have a TTS voice on this device.
Future<Set<String>> getAvailableTtsLanguages() async {
  final tts = FlutterTts();
  final voices = await tts.getVoices;
  if (voices is! List) return {};

  final deviceLocales = <String>{};
  for (final v in voices) {
    if (v is! Map) continue;
    final locale = (v['locale'] ?? '') as String;
    if (locale.isNotEmpty) deviceLocales.add(locale);
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
