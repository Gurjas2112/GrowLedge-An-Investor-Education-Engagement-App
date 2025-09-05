import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/translation_provider.dart';

/// Demo screen showcasing Indian language translations for financial education
class IndianLanguageDemo extends ConsumerStatefulWidget {
  const IndianLanguageDemo({super.key});

  @override
  ConsumerState<IndianLanguageDemo> createState() => _IndianLanguageDemoState();
}

class _IndianLanguageDemoState extends ConsumerState<IndianLanguageDemo> {
  String _selectedLanguage = 'Hindi';

  // Sample financial education content in English
  final List<Map<String, String>> _sampleContent = [
    {
      'title': 'What is Investment?',
      'content':
          'Investment is the act of allocating money or capital to an asset or endeavor with the expectation of generating income or profit.',
    },
    {
      'title': 'Stock Market Basics',
      'content':
          'The stock market is a platform where shares of public companies are traded between investors.',
    },
    {
      'title': 'Mutual Funds',
      'content':
          'A mutual fund is an investment vehicle that pools money from many investors to purchase securities.',
    },
    {
      'title': 'Risk Management',
      'content':
          'Risk management in investing involves identifying, analyzing, and mitigating potential losses.',
    },
    {
      'title': 'Diversification',
      'content':
          'Diversification is an investment strategy that spreads investments across various assets to reduce risk.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final supportedLanguages = ref.watch(supportedLanguagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Indian Language Translation Demo'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Language Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                const Icon(Icons.language, color: Color(0xFF2E7D32)),
                const SizedBox(width: 8),
                const Text(
                  'Select Language:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    isExpanded: true,
                    items: supportedLanguages.map((String language) {
                      return DropdownMenuItem<String>(
                        value: language,
                        child: Row(
                          children: [
                            _getLanguageFlag(language),
                            const SizedBox(width: 8),
                            Text(language),
                          ],
                        ),
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
                ),
              ],
            ),
          ),

          // Content List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _sampleContent.length,
              itemBuilder: (context, index) {
                final content = _sampleContent[index];
                return _buildTranslatedCard(
                  title: content['title']!,
                  content: content['content']!,
                );
              },
            ),
          ),

          // Information Footer
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(height: 8),
                Text(
                  'This demo shows how financial education content can be translated into various Indian languages using Google Translate.',
                  style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslatedCard({
    required String title,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original Title (English)
            if (_selectedLanguage != 'English') ...[
              Text(
                'Original: $title',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Translated Title
            _buildTranslatedText(
              text: title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 12),

            // Original Content (English)
            if (_selectedLanguage != 'English') ...[
              Text(
                'Original: $content',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Translated Content
            _buildTranslatedText(
              text: content,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),

            // Translation Info
            if (_selectedLanguage != 'English') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.translate, size: 16, color: Colors.green.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Translated to $_selectedLanguage',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTranslatedText({
    required String text,
    required TextStyle style,
  }) {
    if (_selectedLanguage == 'English') {
      return Text(text, style: style);
    }

    final translationAsync = ref.watch(
      textTranslationProvider(
        TranslationRequest(text: text, targetLanguage: _selectedLanguage),
      ),
    );

    return translationAsync.when(
      loading: () => Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text('Translating...', style: style.copyWith(color: Colors.grey)),
        ],
      ),
      error: (error, stackTrace) => Text(
        text, // Fallback to original text
        style: style.copyWith(color: Colors.red.shade300),
      ),
      data: (translatedText) => Text(translatedText, style: style),
    );
  }

  Widget _getLanguageFlag(String language) {
    // Simple emoji flags for Indian languages
    const flags = {
      'English': '🇬🇧',
      'Hindi': '🇮🇳',
      'Bengali': '🇧🇩',
      'Tamil': '🇮🇳',
      'Telugu': '🇮🇳',
      'Marathi': '🇮🇳',
      'Gujarati': '🇮🇳',
      'Kannada': '🇮🇳',
      'Malayalam': '🇮🇳',
      'Punjabi': '🇮🇳',
      'Odia': '🇮🇳',
      'Assamese': '🇮🇳',
      'Urdu': '🇵🇰',
    };

    return Text(flags[language] ?? '🌐', style: const TextStyle(fontSize: 16));
  }
}

/// Helper widget for quick language switching
class LanguageQuickSwitch extends ConsumerWidget {
  final String currentLanguage;
  final Function(String) onLanguageChanged;

  const LanguageQuickSwitch({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularLanguages = [
      'English',
      'Hindi',
      'Bengali',
      'Tamil',
      'Telugu',
      'Marathi',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: popularLanguages.map((language) {
        final isSelected = language == currentLanguage;
        return GestureDetector(
          onTap: () => onLanguageChanged(language),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2E7D32)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade300,
              ),
            ),
            child: Text(
              language,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
