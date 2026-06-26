import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../widgets/bottom_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final audioEnabled = userProvider.user.audioEnabled;
    final showLabels = userProvider.user.showLabels;
    final targetLanguage = userProvider.user.targetLanguage;
    final labelLanguage = userProvider.user.labelLanguage;

    final languageNames = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'ru': 'Russian',
      'ko': 'Korean',
      'zh-CN': 'Chinese (Simplified)',
      'ja': 'Japanese',
      'nl': 'Dutch',
    };

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
              child: SwitchListTile(
                title: const Text('Show Image Labels'),
                subtitle: const Text('Display translated text on images during gameplay'),
                value: showLabels,
                onChanged: (value) async {
                  await userProvider.setShowLabels(value);
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text('Learning Language', style: TextStyle(fontSize: 16)),
                    ),
                    DropdownButton<String>(
                      value: targetLanguage,
                      items: languageNames.entries.map((e) {
                        return DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        if (value != null) {
                          await userProvider.setTargetLanguage(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text('Label Language', style: TextStyle(fontSize: 16)),
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
