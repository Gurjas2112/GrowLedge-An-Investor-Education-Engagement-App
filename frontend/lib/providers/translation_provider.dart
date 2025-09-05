import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/translation_service.dart';

// Translation Service Provider
final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService();
});

// Translation Provider for specific text
final textTranslationProvider =
    FutureProvider.family<String, TranslationRequest>((ref, request) async {
      return await TranslationService.translateText(
        text: request.text,
        targetLanguage: request.targetLanguage,
        sourceLanguage: request.sourceLanguage,
      );
    });

// Translation Provider for multiple texts
final multipleTextsTranslationProvider =
    FutureProvider.family<List<String>, MultipleTranslationRequest>((
      ref,
      request,
    ) async {
      return await TranslationService.translateTexts(
        texts: request.texts,
        targetLanguage: request.targetLanguage,
        sourceLanguage: request.sourceLanguage,
      );
    });

// Language Detection Provider
final languageDetectionProvider = FutureProvider.family<String, String>((
  ref,
  text,
) async {
  return await TranslationService.detectLanguage(text);
});

// Supported Languages Provider
final supportedLanguagesProvider = Provider<List<String>>((ref) {
  return TranslationService.getSupportedLanguages();
});

// Request models
class TranslationRequest {
  final String text;
  final String targetLanguage;
  final String sourceLanguage;

  const TranslationRequest({
    required this.text,
    required this.targetLanguage,
    this.sourceLanguage = 'auto',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationRequest &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          targetLanguage == other.targetLanguage &&
          sourceLanguage == other.sourceLanguage;

  @override
  int get hashCode =>
      text.hashCode ^ targetLanguage.hashCode ^ sourceLanguage.hashCode;
}

class MultipleTranslationRequest {
  final List<String> texts;
  final String targetLanguage;
  final String sourceLanguage;

  const MultipleTranslationRequest({
    required this.texts,
    required this.targetLanguage,
    this.sourceLanguage = 'auto',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultipleTranslationRequest &&
          runtimeType == other.runtimeType &&
          texts == other.texts &&
          targetLanguage == other.targetLanguage &&
          sourceLanguage == other.sourceLanguage;

  @override
  int get hashCode =>
      texts.hashCode ^ targetLanguage.hashCode ^ sourceLanguage.hashCode;
}

// Utility functions for translation
class TranslationUtils {
  /// Check if translation is needed
  static bool isTranslationNeeded(
    String currentLanguage,
    String targetLanguage,
  ) {
    return currentLanguage != targetLanguage &&
        TranslationService.isLanguageSupported(targetLanguage);
  }

  /// Get language display name from code
  static String getLanguageDisplayName(String code) {
    const codeToName = {
      'en': 'English',
      'hi': 'Hindi',
      'bn': 'Bengali',
      'ta': 'Tamil',
      'te': 'Telugu',
      'mr': 'Marathi',
      'gu': 'Gujarati',
      'kn': 'Kannada',
      'ml': 'Malayalam',
      'pa': 'Punjabi',
      'or': 'Odia',
      'as': 'Assamese',
      'ur': 'Urdu',
      'sa': 'Sanskrit',
      'ne': 'Nepali',
    };
    return codeToName[code] ?? 'Unknown';
  }
}
