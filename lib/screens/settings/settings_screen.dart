import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/tts_helper.dart';
import '../../providers/user_provider.dart';
import '../../widgets/bottom_bar.dart';
import '../../widgets/language_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Set<String>? _availableLanguages;
  List<Map<String, String>>? _voicesForTargetLanguage;
  String? _voicesLoadedForLanguage;

  @override
  void initState() {
    super.initState();
    _loadAvailableLanguages();
  }

  Future<void> _loadAvailableLanguages() async {
    final available = await getAvailableTtsLanguages();
    if (!mounted) return;
    setState(() => _availableLanguages = available);
  }

  Future<void> _loadVoicesFor(String languageCode) async {
    final voices = await getVoicesForLanguage(languageCode);
    if (!mounted) return;
    setState(() {
      _voicesForTargetLanguage = voices;
      _voicesLoadedForLanguage = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final audioEnabled = userProvider.user.audioEnabled;
    final showLabels = userProvider.user.showLabels;
    final targetLanguage = userProvider.user.targetLanguage;
    final labelLanguage = userProvider.user.labelLanguage;
    final speechRate = userProvider.user.speechRate;
    final selectedVoiceName =
        userProvider.user.voiceOverrides[targetLanguage]?['name'];

    if (_voicesLoadedForLanguage != targetLanguage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadVoicesFor(targetLanguage);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.settings_rounded, size: 34),
                    SizedBox(width: 12),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: InkWell(
                onTap: () async {
                  final selected = await showTargetLanguagePicker(
                    context: context,
                    selectedLanguage: targetLanguage,
                    availableLanguages: _availableLanguages,
                  );
                  if (selected == null || selected == targetLanguage) return;
                  await userProvider.setTargetLanguage(selected);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Now learning ${languageNameFor(selected)}'),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF2563EB).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.language_rounded,
                          color: Color(0xFF2563EB),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Learning ${languageNameFor(targetLanguage)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap to change the language you practise',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: SwitchListTile(
                title: const Text('Word Pronunciation'),
                subtitle: const Text('Speak target words during gameplay'),
                value: audioEnabled,
                onChanged: (value) async {
                  await userProvider.setAudioEnabled(value);
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Speech Speed',
                            style: TextStyle(fontSize: 16)),
                        Text('${speechRate.toStringAsFixed(2)}x',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    Slider(
                      value: speechRate,
                      min: 0.2,
                      max: 0.8,
                      divisions: 12,
                      label: '${speechRate.toStringAsFixed(2)}x',
                      onChanged: (value) async {
                        await userProvider.setSpeechRate(value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: SwitchListTile(
                title: const Text('Show Image Labels'),
                subtitle: const Text(
                    'Display translated text on images during gameplay'),
                value: showLabels,
                onChanged: (value) async {
                  await userProvider.setShowLabels(value);
                },
              ),
            ),
            const SizedBox(height: 8),
            if (_voicesForTargetLanguage != null &&
                _voicesForTargetLanguage!.isNotEmpty)
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                            'Voice (${languageNameFor(targetLanguage)})',
                            style: const TextStyle(fontSize: 16)),
                      ),
                      DropdownButton<String>(
                        value: selectedVoiceName ?? '__auto__',
                        items: [
                          const DropdownMenuItem(
                            value: '__auto__',
                            child: Text('Automatic'),
                          ),
                          ..._voicesForTargetLanguage!.map((v) {
                            return DropdownMenuItem(
                              value: v['name'],
                              child: Text(v['name']!,
                                  overflow: TextOverflow.ellipsis),
                            );
                          }),
                        ],
                        onChanged: (value) async {
                          if (value == null || value == '__auto__') {
                            await userProvider.setVoiceOverride(
                                targetLanguage, null);
                          } else {
                            final voice = _voicesForTargetLanguage!
                                .firstWhere((v) => v['name'] == value);
                            await userProvider.setVoiceOverride(
                                targetLanguage, voice);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            if (_voicesForTargetLanguage != null &&
                _voicesForTargetLanguage!.isNotEmpty)
              const SizedBox(height: 8),
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text('Label Language',
                          style: TextStyle(fontSize: 16)),
                    ),
                    DropdownButton<String>(
                      value: labelLanguage,
                      items: languageNames.entries.map((e) {
                        return DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        if (value != null) {
                          await userProvider.setLabelLanguage(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('About this app'),
                subtitle: const Text('MemoLingo Language Learning App'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'MemoLingo',
                    applicationVersion: '1.0.3',
                    applicationIcon: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/memolingo/nostalgia/loading_cat.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    children: const [
                      Text(
                        'This app helps you master vocabulary across multiple languages '
                        'using an interactive spaced repetition system.',
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomBar(selectedIndex: 3),
    );
  }
}
