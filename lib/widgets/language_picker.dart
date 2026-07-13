import 'package:flutter/material.dart';

import '../helpers/tts_helper.dart';

const Map<String, String> languageNames = {
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

const Map<String, String> targetLanguageGreetings = {
  'es': 'Hola',
  'fr': 'Bonjour',
  'de': 'Hallo',
  'it': 'Ciao',
  'ru': 'Привет',
  'ko': '안녕',
  'zh-CN': '你好',
  'ja': 'こんにちは',
  'nl': 'Hallo',
};

String languageNameFor(String code) => languageNames[code] ?? code;

String targetLanguageGreetingFor(String code) =>
    targetLanguageGreetings[code] ?? languageNameFor(code);

Future<String?> showTargetLanguagePicker({
  required BuildContext context,
  required String selectedLanguage,
  Set<String>? availableLanguages,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return _TargetLanguagePickerSheet(
        selectedLanguage: selectedLanguage,
        availableLanguages: availableLanguages,
      );
    },
  );
}

class _TargetLanguagePickerSheet extends StatefulWidget {
  const _TargetLanguagePickerSheet({
    required this.selectedLanguage,
    required this.availableLanguages,
  });

  final String selectedLanguage;
  final Set<String>? availableLanguages;

  @override
  State<_TargetLanguagePickerSheet> createState() =>
      _TargetLanguagePickerSheetState();
}

class _TargetLanguagePickerSheetState
    extends State<_TargetLanguagePickerSheet> {
  Set<String>? _availableLanguages;
  bool _isLoadingLanguages = false;

  @override
  void initState() {
    super.initState();
    _availableLanguages = widget.availableLanguages;
    if (_availableLanguages == null) {
      _loadAvailableLanguages();
    }
  }

  Future<void> _loadAvailableLanguages() async {
    setState(() => _isLoadingLanguages = true);
    final available = await getAvailableTtsLanguages();
    if (!mounted) return;
    setState(() {
      _availableLanguages = available;
      _isLoadingLanguages = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final languages = languageNames.entries
        .where((e) => e.key != 'en')
        .where((e) =>
            _availableLanguages == null || _availableLanguages!.contains(e.key))
        .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      minChildSize: 0.52,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change learning language',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pick the language you want to practise.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            if (_isLoadingLanguages)
              const LinearProgressIndicator(minHeight: 2)
            else
              const SizedBox(height: 2),
            Expanded(
              child: languages.isEmpty && !_isLoadingLanguages
                  ? ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                      children: const [
                        SizedBox(height: 40),
                        Icon(Icons.record_voice_over_outlined,
                            size: 40, color: Colors.black26),
                        SizedBox(height: 16),
                        Text(
                          'No extra voices found on this device.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Install a language voice pack in your system '
                          'speech settings to practise it here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                      itemCount: languages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final entry = languages[index];
                        final isSelected = entry.key == widget.selectedLanguage;

                        return Material(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFF3F6FB),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => Navigator.of(context).pop(entry.key),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.value,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black87,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          targetLanguageGreetingFor(entry.key),
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                    .withValues(alpha: 0.78)
                                                : Colors.black54,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade500,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
