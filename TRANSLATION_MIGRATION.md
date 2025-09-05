# Translation Service Migration

## Overview
The GrowLedge app has been migrated from using the LibreTranslate API (backend-based translation) to using the Flutter `translator` package for client-side translation. This change provides better reliability, reduced server load, and improved offline capabilities.

## Changes Made

### Backend Changes
1. **Removed LibreTranslate API dependencies** from `config.py`
2. **Updated AI routes** - The `/ai/translate` endpoint now returns the original text with a message indicating frontend translation should be used
3. **Updated environment files** - Removed `LIBRE_TRANSLATE_API_KEY` and `LIBRE_TRANSLATE_BASE_URL` from `.env` and `.env.example`

### Frontend Changes
1. **Added Flutter translator package** - `translator: ^1.0.4+1` in `pubspec.yaml`
2. **Created TranslationService** - `lib/services/translation_service.dart`
3. **Created TranslationProvider** - `lib/providers/translation_provider.dart`
4. **Updated API service** - Translation methods now return original text as fallback
5. **Added example widgets** - `lib/widgets/translation_example.dart`

## How to Use the New Translation System

### Basic Translation
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/translation_service.dart';

// Direct usage
final translatedText = await TranslationService.translateText(
  text: 'Hello, world!',
  targetLanguage: 'Spanish',
);

// Using providers (recommended)
final translationRequest = TranslationRequest(
  text: 'Hello, world!',
  targetLanguage: 'Spanish',
);

// In a ConsumerWidget
final translationAsync = ref.watch(textTranslationProvider(translationRequest));
```

### Using the TranslatedText Widget
```dart
// Automatically translates text based on user's language preference
TranslatedText(
  text: 'Welcome to GrowLedge',
  targetLanguage: userSelectedLanguage,
  style: Theme.of(context).textTheme.headlineLarge,
)
```

### Multiple Text Translation
```dart
final multipleRequest = MultipleTranslationRequest(
  texts: ['Hello', 'Welcome', 'Goodbye'],
  targetLanguage: 'French',
);

final translationsAsync = ref.watch(multipleTextsTranslationProvider(multipleRequest));
```

### Language Detection
```dart
final detectedLanguage = await TranslationService.detectLanguage('Hola mundo');
// Returns language code like 'es' for Spanish
```

## Supported Languages
- English
- Hindi 
- Bengali
- Tamil
- Telugu
- Marathi
- Gujarati
- Kannada
- Malayalam
- Punjabi
- Odia
- Assamese
- Urdu
- Sanskrit
- Nepali

## Implementation in Existing Screens

### Lesson Detail Screen
The lesson detail screen already has multilingual content support through the `LessonContent` model. For dynamic translation of content not stored in multiple languages:

```dart
// Get user's preferred language
final preferredLanguage = ref.watch(userPreferredLanguageProvider);

// Translate lesson content if needed
TranslatedText(
  text: lesson.description,
  targetLanguage: preferredLanguage,
  style: Theme.of(context).textTheme.bodyLarge,
)
```

### Lessons Screen
For translating category names, difficulty levels, and other UI text:

```dart
TranslatedText(
  text: lesson.category,
  targetLanguage: userSelectedLanguage,
)
```

## Error Handling
The translation service includes built-in error handling:
- If translation fails, the original text is returned
- Network errors are handled gracefully
- Unsupported languages fall back to original text

## Performance Considerations
1. **Caching** - Riverpod automatically caches translation results
2. **Batching** - Use `translateTexts()` for multiple texts to improve performance
3. **Lazy Loading** - Translations only occur when widgets are rendered

## Migration Guide for Existing Code

### Replace Backend API Calls
**Before:**
```dart
final translated = await ApiService.translateText(text, language);
```

**After:**
```dart
final translated = await TranslationService.translateText(
  text: text,
  targetLanguage: language,
);
```

### Replace Direct Translation Calls with Providers
**Before:**
```dart
String translatedText = await translateText(originalText);
```

**After:**
```dart
final translationAsync = ref.watch(textTranslationProvider(
  TranslationRequest(text: originalText, targetLanguage: language)
));
```

## Testing
The translation service can be tested with:
```dart
flutter test test/services/translation_service_test.dart
```

## Future Enhancements
1. **Offline Support** - Cache frequently used translations
2. **Custom Dictionaries** - Add domain-specific financial terms
3. **User Preferences** - Remember user's preferred language
4. **Translation Quality** - Add feedback mechanism for translation accuracy

## Troubleshooting

### Common Issues
1. **Package Not Found** - Run `flutter pub get` to install translator package
2. **Network Errors** - Translation requires internet connection
3. **Rate Limiting** - Google Translate has usage limits for free tier

### Debug Mode
Enable debug logging to see translation requests:
```dart
TranslationService.enableDebugMode();
```

This migration improves the app's translation capabilities while reducing dependency on external APIs and improving offline functionality.
