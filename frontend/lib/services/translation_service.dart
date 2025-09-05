import 'package:translator/translator.dart';

class TranslationService {
  static final GoogleTranslator _translator = GoogleTranslator();

  // Language code mappings - Focus on Indian native languages
  static const Map<String, String> _languageCodes = {
    'English': 'en',
    'Hindi': 'hi',
    'Bengali': 'bn',
    'Tamil': 'ta',
    'Telugu': 'te',
    'Marathi': 'mr',
    'Gujarati': 'gu',
    'Kannada': 'kn',
    'Malayalam': 'ml',
    'Punjabi': 'pa',
    'Odia': 'or',
    'Assamese': 'as',
    'Urdu': 'ur',
    'Sanskrit': 'sa',
    'Nepali': 'ne',
  };

  /// Translate text to target language
  static Future<String> translateText({
    required String text,
    required String targetLanguage,
    String sourceLanguage = 'auto',
  }) async {
    try {
      // Get language codes
      final targetCode = _languageCodes[targetLanguage] ?? 'en';
      final sourceCode = sourceLanguage == 'auto'
          ? 'auto'
          : _languageCodes[sourceLanguage] ?? 'auto';

      // Perform translation
      final translation = await _translator.translate(
        text,
        from: sourceCode,
        to: targetCode,
      );

      return translation.text;
    } catch (e) {
      // Return original text if translation fails
      return text;
    }
  }

  /// Translate multiple texts at once
  static Future<List<String>> translateTexts({
    required List<String> texts,
    required String targetLanguage,
    String sourceLanguage = 'auto',
  }) async {
    try {
      final futures = texts.map(
        (text) => translateText(
          text: text,
          targetLanguage: targetLanguage,
          sourceLanguage: sourceLanguage,
        ),
      );

      return await Future.wait(futures);
    } catch (e) {
      // Return original texts if translation fails
      return texts;
    }
  }

  /// Get supported languages
  static List<String> getSupportedLanguages() {
    return _languageCodes.keys.toList();
  }

  /// Check if a language is supported
  static bool isLanguageSupported(String language) {
    return _languageCodes.containsKey(language);
  }

  /// Get language code from language name
  static String? getLanguageCode(String language) {
    return _languageCodes[language];
  }

  /// Detect language of text
  static Future<String> detectLanguage(String text) async {
    try {
      final detection = await _translator.translate(text, to: 'en');
      return detection.sourceLanguage.code;
    } catch (e) {
      return 'unknown';
    }
  }
}
