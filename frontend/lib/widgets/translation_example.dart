import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/translation_provider.dart';

/// Example widget showing how to use the Flutter translator library
/// This can be integrated into any screen that needs translation functionality
class TranslationExample extends ConsumerStatefulWidget {
  const TranslationExample({super.key});

  @override
  ConsumerState<TranslationExample> createState() => _TranslationExampleState();
}

class _TranslationExampleState extends ConsumerState<TranslationExample> {
  final TextEditingController _textController = TextEditingController();
  String _selectedLanguage = 'Hindi';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supportedLanguages = ref.watch(supportedLanguagesProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Translation Service Example',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Input text
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter text to translate',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Language selector
            DropdownButton<String>(
              value: _selectedLanguage,
              isExpanded: true,
              hint: const Text('Select target language'),
              items: supportedLanguages.map((String language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Translate button and result
            ElevatedButton(
              onPressed: _textController.text.isNotEmpty
                  ? () => _performTranslation()
                  : null,
              child: const Text('Translate'),
            ),
            const SizedBox(height: 16),

            // Translation result
            _buildTranslationResult(),
          ],
        ),
      ),
    );
  }

  void _performTranslation() {
    if (_textController.text.isNotEmpty) {
      // Trigger translation by reading the provider
      ref.read(
        textTranslationProvider(
          TranslationRequest(
            text: _textController.text,
            targetLanguage: _selectedLanguage,
          ),
        ),
      );
    }
  }

  Widget _buildTranslationResult() {
    if (_textController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    final translationAsync = ref.watch(
      textTranslationProvider(
        TranslationRequest(
          text: _textController.text,
          targetLanguage: _selectedLanguage,
        ),
      ),
    );

    return translationAsync.when(
      loading: () => const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 8),
          Text('Translating...'),
        ],
      ),
      error: (error, stackTrace) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Translation Error:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            Text(error.toString(), style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
      data: (translatedText) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Translated to $_selectedLanguage:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(translatedText, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(translatedText),
                  tooltip: 'Copy translation',
                ),
                const Spacer(),
                Text(
                  'Powered by Google Translate',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    // Implementation would use Clipboard.setData
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Translation copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Helper widget for translating a single piece of text inline
class TranslatedText extends ConsumerWidget {
  final String text;
  final String targetLanguage;
  final TextStyle? style;
  final String fallbackText;

  const TranslatedText({
    super.key,
    required this.text,
    required this.targetLanguage,
    this.style,
    this.fallbackText = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Don't translate if target language is English (assuming original is English)
    if (targetLanguage == 'English') {
      return Text(text, style: style);
    }

    final translationAsync = ref.watch(
      textTranslationProvider(
        TranslationRequest(text: text, targetLanguage: targetLanguage),
      ),
    );

    return translationAsync.when(
      loading: () => Text(
        text, // Show original text while loading
        style:
            style?.copyWith(color: Colors.grey) ??
            const TextStyle(color: Colors.grey),
      ),
      error: (error, stackTrace) =>
          Text(fallbackText.isNotEmpty ? fallbackText : text, style: style),
      data: (translatedText) => Text(translatedText, style: style),
    );
  }
}
