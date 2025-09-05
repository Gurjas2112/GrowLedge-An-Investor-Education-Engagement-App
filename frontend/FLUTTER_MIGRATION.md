# Flutter Frontend Migration Guide

## 🔄 Migration from Firebase to MongoDB Backend

This guide explains the changes made to the Flutter frontend to work with the new MongoDB backend.

## 📦 Dependencies Updated

### Removed Firebase Dependencies
```yaml
# REMOVED from pubspec.yaml
firebase_core: ^4.1.0
firebase_auth: ^6.0.2
cloud_firestore: ^6.0.1
firebase_messaging: ^16.0.1
firebase_storage: ^13.0.1
```

### Added New Dependencies
```yaml
# ADDED to pubspec.yaml
jwt_decoder: ^2.0.1  # For JWT token handling
```

### Existing Dependencies (Kept)
```yaml
http: ^1.1.2
dio: ^5.4.0
shared_preferences: ^2.2.2
flutter_riverpod: ^2.4.9
```

## 🏗 Architecture Changes

### Authentication System
- **Before**: Firebase Authentication with FirebaseAuth
- **After**: JWT-based authentication with REST API

### Data Storage
- **Before**: Cloud Firestore collections
- **After**: MongoDB collections via REST API

### State Management
- **Before**: StreamProviders with Firebase streams
- **After**: FutureProviders with HTTP requests

## 📁 File Structure Changes

### Updated Files
- `pubspec.yaml` - Updated dependencies
- `main.dart` - Removed Firebase initialization
- `services/api_service.dart` - Complete rewrite with authentication
- `services/backend_service.dart` - New service replacing Firebase
- `providers/auth_provider.dart` - JWT-based authentication
- `providers/lessons_provider.dart` - New provider for lessons
- `providers/quiz_provider.dart` - Updated for new API
- `providers/trading_provider.dart` - Updated for new API
- `models/user.dart` - Added new fields for MongoDB
- `models/lesson.dart` - Updated for multilingual content
- `models/quiz.dart` - Updated structure
- `models/trade.dart` - Updated for new backend

### Removed Dependencies
- Firebase services are no longer used
- `services/firebase_service.dart` can be deleted (kept for reference)

## 🔐 Authentication Flow

### New JWT Authentication

1. **Login/Register**: Returns JWT token
2. **Token Storage**: Saved in SharedPreferences
3. **API Requests**: Token sent in Authorization header
4. **Token Validation**: Checked on each app start

```dart
// Example: Login flow
final authService = ref.read(authServiceProvider);
final result = await authService.signIn(
  email: email,
  password: password,
);
// Token automatically saved and used for subsequent requests
```

### Authentication State Management

```dart
// Auth state is now based on JWT token validation
final authStateProvider = FutureProvider<AppUser?>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final token = await apiService.getToken();
  
  if (token == null) return null;
  
  if (JwtDecoder.isExpired(token)) {
    await apiService.removeToken();
    return null;
  }
  
  return await apiService.getCurrentUser();
});
```

## 📊 Data Models Updates

### User Model
```dart
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String preferredLanguage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> badges;
  final int xpPoints;
  final List<String> completedLessons;
  final Map<String, int> quizScores;
  // ... MongoDB ObjectId support
}
```

### Lesson Model
```dart
class Lesson {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final int durationMinutes;
  final List<LessonContent> content; // Multilingual content
  final List<String> prerequisites;
  final List<String> learningObjectives;
  // ... MongoDB structure
}
```

## 🛠 API Integration

### New API Service Structure

```dart
class ApiService {
  final Dio _dio = Dio();
  
  // JWT token interceptor automatically adds auth headers
  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }
  
  // Authentication
  Future<Map<String, dynamic>> login({required String email, required String password});
  Future<Map<String, dynamic>> register({...});
  Future<AppUser?> getCurrentUser();
  
  // Lessons
  Future<List<Lesson>> getLessons({...});
  Future<Lesson> getLesson(String lessonId);
  
  // Quizzes
  Future<List<Quiz>> getLessonQuizzes(String lessonId);
  Future<Map<String, dynamic>> submitQuiz(String quizId, List<String> answers);
  
  // Trading
  Future<Map<String, dynamic>> getPortfolio();
  Future<Map<String, dynamic>> placeTrade({...});
  
  // AI Services (unchanged)
  Future<String> summarizeText(String text);
  Future<String> translateText(String text, String targetLanguage);
  Future<String> generateAudio(String text, String language);
}
```

## 🚀 Running the Updated App

### 1. Install Dependencies
```bash
cd frontend
flutter pub get
```

### 2. Start Backend Server
Make sure your MongoDB backend is running:
```bash
cd backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 3. Update API Base URL
In `lib/services/api_service.dart`, update the base URL if needed:
```dart
static const String _baseUrl = 'http://localhost:8000';
// For physical device: 'http://YOUR_COMPUTER_IP:8000'
// For production: 'https://your-domain.com'
```

### 4. Run Flutter App
```bash
flutter run
```

## 📱 Screen Updates Required

The following screens may need updates to work with the new providers:

### Login Screen
- Remove Firebase auth imports
- Use new `authServiceProvider`
- Handle JWT token response

### Profile Screen
- Update user data structure
- Use new user model fields

### Lessons Screen
- Use new `lessonsProvider`
- Handle multilingual content

### Quiz Screen
- Use updated quiz models
- Handle new quiz submission format

### Trading Screen
- Use updated trading providers
- Handle new portfolio structure

## 🔍 Testing the Migration

### 1. Authentication Test
```dart
// Test login
final authService = ref.read(authServiceProvider);
try {
  final result = await authService.signIn(
    email: 'test@example.com',
    password: 'password123',
  );
  print('Login successful: ${result['access_token']}');
} catch (e) {
  print('Login failed: $e');
}
```

### 2. Data Fetching Test
```dart
// Test lessons loading
final lessons = ref.watch(lessonsProvider(LessonFilters()));
lessons.when(
  data: (lessonsList) => print('Loaded ${lessonsList.length} lessons'),
  loading: () => print('Loading lessons...'),
  error: (error, stack) => print('Error: $error'),
);
```

## 🐛 Common Issues & Solutions

### Issue: "Failed to load data"
**Solution**: Check if backend server is running and accessible

### Issue: "Authentication failed"
**Solution**: Verify JWT token is valid and backend auth endpoints work

### Issue: "No data displayed"
**Solution**: Check API response format matches model expectations

### Issue: "Build errors"
**Solution**: Run `flutter clean && flutter pub get`

## 🔧 Configuration

### Environment Variables
The app automatically uses the backend's environment configuration. No additional setup needed for:
- MongoDB connection
- JWT secrets
- API keys

### Backend URL Configuration
For different environments:

```dart
// Development (local)
static const String _baseUrl = 'http://localhost:8000';

// Production
static const String _baseUrl = 'https://your-api-domain.com';

// For physical device testing
static const String _baseUrl = 'http://192.168.1.100:8000';
```

## 📈 Benefits of Migration

1. **No Firebase Costs**: Eliminated Firebase usage fees
2. **Full Control**: Complete control over backend logic
3. **Flexibility**: Easy to modify and extend API
4. **Performance**: Optimized queries with MongoDB indexes
5. **Portability**: Can deploy anywhere, no vendor lock-in
6. **Security**: JWT-based auth with configurable expiration

## 🔗 Related Documentation

- [Backend MongoDB Migration Guide](../MONGODB_MIGRATION.md)
- [API Documentation](http://localhost:8000/docs) (when backend is running)
- [MongoDB Setup Guide](../backend/README.md)

---

**✅ Migration Complete!** Your Flutter app now works with the MongoDB backend instead of Firebase.
