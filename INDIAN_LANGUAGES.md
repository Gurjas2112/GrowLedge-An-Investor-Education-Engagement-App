# Indian Languages Support in GrowLedge

## Overview
GrowLedge now supports multiple Indian native languages to make financial education accessible to users across India. The app uses Google Translate through the Flutter `translator` package to provide real-time translation of content.

## Supported Indian Languages

### Major Indian Languages
- **Hindi** (हिन्दी) - Hindi
- **Bengali** (বাংলা) - Bengali  
- **Tamil** (தமிழ்) - Tamil
- **Telugu** (తెలుగు) - Telugu
- **Marathi** (मराठी) - Marathi
- **Gujarati** (ગુજરાતી) - Gujarati
- **Kannada** (ಕನ್ನಡ) - Kannada
- **Malayalam** (മലയാളം) - Malayalam
- **Punjabi** (ਪੰਜਾਬੀ) - Punjabi
- **Odia** (ଓଡ଼ିଆ) - Odia
- **Assamese** (অসমীয়া) - Assamese
- **Urdu** (اردو) - Urdu

### Additional Languages
- **Sanskrit** (संस्कृत) - Classical language support
- **Nepali** (नेपाली) - For Nepali-speaking users
- **English** - Default language

## Features

### Real-time Translation
- All educational content can be translated instantly
- Financial terms and concepts explained in native languages
- Lesson content, quiz questions, and trading terminology

### Language-specific Features
- **Text-to-Speech**: Audio support for multiple Indian languages
- **Content Localization**: Financial education adapted for Indian context
- **Cultural Adaptation**: Examples and scenarios relevant to Indian markets

### Supported Content Types
- Investment lessons and tutorials
- Stock market education
- Mutual fund explanations
- Trading strategies
- Risk management concepts
- Portfolio management guidance

## Usage Examples

### Basic Translation
```dart
// Translate investment term to Hindi
final hindiTranslation = await TranslationService.translateText(
  text: 'Mutual Fund',
  targetLanguage: 'Hindi',
);
// Result: "म्यूचुअल फंड"
```

### Regional Financial Terms
```dart
// Translate to regional languages
final translations = await TranslationService.translateTexts(
  texts: ['Stock Market', 'Dividend', 'Portfolio'],
  targetLanguage: 'Tamil',
);
// Results in Tamil script
```

### Widget-based Translation
```dart
TranslatedText(
  text: 'Welcome to Stock Market Learning',
  targetLanguage: 'Bengali',
  style: Theme.of(context).textTheme.headlineSmall,
)
```

## Demo Screen
The app includes an `IndianLanguageDemo` screen that showcases:
- Financial education content in multiple Indian languages
- Real-time translation of investment concepts
- Language switching with visual feedback
- Regional flag indicators

## Implementation Details

### Language Codes
Each language is mapped to its ISO 639-1 code:
- Hindi: `hi`
- Bengali: `bn`
- Tamil: `ta`
- Telugu: `te`
- And more...

### Text-to-Speech Support
The backend TTS service supports pronunciation in:
- Hindi, Bengali, Tamil, Telugu
- Marathi, Gujarati, Kannada, Malayalam
- Punjabi, Urdu, Nepali

### Performance Optimization
- **Caching**: Translated content is cached automatically
- **Batch Translation**: Multiple texts translated together
- **Lazy Loading**: Translations only occur when needed

## Benefits for Indian Users

### Accessibility
- Removes language barriers in financial education
- Makes complex investment concepts understandable
- Supports users who prefer their native language

### Cultural Relevance
- Financial examples relevant to Indian markets
- Terminology familiar to Indian investors
- Educational content adapted for Indian context

### Inclusive Design
- Supports linguistic diversity of India
- Accommodates users from different states
- Promotes financial literacy across regions

## Future Enhancements

### Planned Features
1. **Offline Support**: Download translated content for offline use
2. **Regional Examples**: State-specific financial examples
3. **Voice Input**: Speak queries in native languages
4. **Regional Festivals**: Investment plans for regional festivals
5. **Local Market Data**: Regional stock exchange information

### Content Expansion
- State-specific investment schemes
- Regional banking terminology
- Local financial advisor network
- Cultural context for financial planning

## Technical Implementation

### Translation Pipeline
1. **Source Content**: English financial education content
2. **Translation Service**: Google Translate via Flutter package
3. **Caching Layer**: Riverpod state management
4. **UI Rendering**: Translated content display

### Quality Assurance
- Translation accuracy monitoring
- User feedback collection
- Regional expert review
- Continuous improvement based on usage

## Getting Started

### For Developers
```dart
// Import translation provider
import '../providers/translation_provider.dart';

// Use in widgets
final translatedContent = ref.watch(textTranslationProvider(
  TranslationRequest(
    text: 'Investment Strategy',
    targetLanguage: 'Hindi',
  ),
));
```

### For Users
1. Open GrowLedge app
2. Navigate to Settings → Language
3. Select preferred Indian language
4. All content will be translated automatically

This implementation makes GrowLedge truly accessible to users across India, breaking down language barriers in financial education and promoting inclusive financial literacy.
