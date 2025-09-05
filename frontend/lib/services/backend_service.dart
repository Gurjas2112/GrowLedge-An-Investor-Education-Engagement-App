import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../models/lesson.dart';
import '../models/quiz.dart';
import '../models/trade.dart';

/// Service class that provides all backend functionality
/// This replaces Firebase with REST API calls to the MongoDB backend
class BackendService {
  static final ApiService _apiService = ApiService();

  // Authentication Methods
  static Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _apiService.login(email: email, password: password);
  }

  static Future<Map<String, dynamic>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String preferredLanguage,
  }) async {
    return await _apiService.register(
      email: email,
      password: password,
      name: name,
      preferredLanguage: preferredLanguage,
    );
  }

  static Future<void> signOut() async {
    await _apiService.logout();
  }

  static Future<AppUser?> getCurrentUser() async {
    return await _apiService.getCurrentUser();
  }

  static Future<bool> isAuthenticated() async {
    final token = await _apiService.getToken();
    if (token == null) return false;

    try {
      return await _apiService.verifyToken();
    } catch (e) {
      debugPrint('Authentication check failed: $e');
      return false;
    }
  }

  // User Document Methods
  static Future<AppUser> updateUserDocument(Map<String, dynamic> data) async {
    return await _apiService.updateUser(data);
  }

  // Lessons Methods
  static Future<List<Lesson>> getLessons({
    String? difficulty,
    String? lang,
  }) async {
    return await _apiService.getLessons(difficulty: difficulty, lang: lang);
  }

  static Future<Lesson> getLesson(String lessonId) async {
    return await _apiService.getLesson(lessonId);
  }

  static Future<void> markLessonComplete(
    String lessonId, {
    int score = 100,
  }) async {
    await _apiService.markLessonComplete(lessonId, score);
  }

  // Quiz Methods
  static Future<List<Quiz>> getLessonQuizzes(String lessonId) async {
    return await _apiService.getLessonQuizzes(lessonId);
  }

  static Future<Map<String, dynamic>> submitQuiz(
    String quizId,
    List<String> answers,
  ) async {
    return await _apiService.submitQuiz(quizId, answers);
  }

  // Trading Methods
  static Future<Portfolio> getPortfolio() async {
    final portfolioData = await _apiService.getPortfolio();
    return Portfolio.fromJson(portfolioData);
  }

  static Future<Map<String, dynamic>> placeTrade({
    required String symbol,
    required String side, // BUY or SELL
    required double qty,
    required double price,
  }) async {
    return await _apiService.placeTrade(
      symbol: symbol,
      side: side,
      qty: qty,
      price: price,
    );
  }

  static Future<Map<String, dynamic>> getStockQuote(String symbol) async {
    return await _apiService.getStockQuote(symbol);
  }

  static Future<List<Map<String, dynamic>>> searchStocks(String query) async {
    return await _apiService.searchStocks(query);
  }

  // AI Services Methods
  static Future<String> summarizeText(String text) async {
    return await _apiService.summarizeText(text);
  }

  static Future<String> translateText(
    String text,
    String targetLanguage,
  ) async {
    // Translation is now handled by Flutter translator library
    // Use TranslationService.translateText() instead
    return text; // Return original text as fallback
  }

  static Future<String> generateAudio(String text, String language) async {
    return await _apiService.generateAudio(text, language);
  }

  // Utility Methods
  static Future<String?> getAuthToken() async {
    return await _apiService.getToken();
  }

  static Future<void> clearAuthToken() async {
    await _apiService.removeToken();
  }
}
