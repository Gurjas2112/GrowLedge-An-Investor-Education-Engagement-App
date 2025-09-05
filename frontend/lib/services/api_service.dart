import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/user.dart';
import '../models/lesson.dart';
import '../models/quiz.dart';

class ApiService {
  // Dynamic base URL based on platform
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000'; // Android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:8000'; // iOS simulator
    } else {
      return 'http://localhost:8000'; // Desktop/other platforms
    }
  }

  final Dio _dio = Dio();

  ApiService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.sendTimeout = const Duration(seconds: 15);

    // Add debugging interceptor
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
        ),
      );
    }

    // Add JWT token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print('API Error: ${error.message}');
            print('Request URL: ${error.requestOptions.uri}');
            print('Status Code: ${error.response?.statusCode}');
          }
          handler.next(error);
        },
      ),
    );
  }

  // Token Management
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Authentication Methods
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String preferredLanguage,
  }) async {
    try {
      if (kDebugMode) {
        print('Attempting registration to: $_baseUrl/auth/register');
      }

      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'preferred_language': preferredLanguage,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['access_token'] != null) {
          await saveToken(data['access_token']);
        }
        return data;
      } else {
        throw Exception(
          'Registration failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';

      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout - please check if the server is running';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server response timeout';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage =
            'Cannot connect to server. Is the backend running on $_baseUrl?';
      } else if (e.response != null) {
        errorMessage = 'Server error: ${e.response?.data}';
      }

      if (kDebugMode) {
        print('Registration DioException: $e');
        print('Error type: ${e.type}');
        print('Response: ${e.response?.data}');
      }

      throw Exception(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        print('Registration general error: $e');
      }
      throw Exception('Registration error: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['access_token'] != null) {
          await saveToken(data['access_token']);
        }
        return data;
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<void> logout() async {
    await removeToken();
  }

  Future<AppUser?> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');

      if (response.statusCode == 200) {
        return AppUser.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> verifyToken() async {
    try {
      final response = await _dio.post('/auth/verify-token');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<AppUser> updateUser(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.put('/auth/me', data: userData);

      if (response.statusCode == 200) {
        return AppUser.fromJson(response.data);
      } else {
        throw Exception('Failed to update user');
      }
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  // Lessons Methods
  Future<List<Lesson>> getLessons({String? difficulty, String? lang}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      if (lang != null) queryParams['lang'] = lang;

      final response = await _dio.get(
        '/lessons/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Lesson.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch lessons');
      }
    } catch (e) {
      throw Exception('Error fetching lessons: $e');
    }
  }

  Future<Lesson> getLesson(String lessonId) async {
    try {
      final response = await _dio.get('/lessons/$lessonId');

      if (response.statusCode == 200) {
        return Lesson.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch lesson');
      }
    } catch (e) {
      throw Exception('Error fetching lesson: $e');
    }
  }

  Future<void> markLessonComplete(String lessonId, int score) async {
    try {
      final response = await _dio.put(
        '/lessons/$lessonId/progress',
        queryParameters: {'score': score},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark lesson complete');
      }
    } catch (e) {
      throw Exception('Error marking lesson complete: $e');
    }
  }

  // Quiz Methods
  Future<List<Quiz>> getLessonQuizzes(String lessonId) async {
    try {
      final response = await _dio.get(
        '/quizzes/',
        queryParameters: {'lesson_id': lessonId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Quiz.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch quizzes');
      }
    } catch (e) {
      throw Exception('Error fetching quizzes: $e');
    }
  }

  Future<Map<String, dynamic>> submitQuiz(
    String quizId,
    List<String> answers,
  ) async {
    try {
      final response = await _dio.post(
        '/quizzes/submit',
        data: {'quiz_id': quizId, 'answers': answers},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to submit quiz');
      }
    } catch (e) {
      throw Exception('Error submitting quiz: $e');
    }
  }

  // Trading Methods
  Future<Map<String, dynamic>> getPortfolio() async {
    try {
      final response = await _dio.get('/trading/portfolio');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch portfolio');
      }
    } catch (e) {
      throw Exception('Error fetching portfolio: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTrades() async {
    try {
      final response = await _dio.get('/trading/trades');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to fetch trades');
      }
    } catch (e) {
      throw Exception('Error fetching trades: $e');
    }
  }

  Future<Map<String, dynamic>> placeTrade({
    required String symbol,
    required String side, // BUY or SELL
    required double qty,
    required double price,
  }) async {
    try {
      final response = await _dio.post(
        '/trading/place_trade',
        data: {'symbol': symbol, 'side': side, 'qty': qty, 'price': price},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to place trade');
      }
    } catch (e) {
      throw Exception('Error placing trade: $e');
    }
  }

  Future<Map<String, dynamic>> getStockQuote(String symbol) async {
    try {
      final response = await _dio.get('/trading/stock/$symbol');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch stock quote');
      }
    } catch (e) {
      throw Exception('Error fetching stock data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchStocks(String keywords) async {
    try {
      final response = await _dio.get('/trading/search/$keywords');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to search stocks');
      }
    } catch (e) {
      throw Exception('Error searching stocks: $e');
    }
  }

  // AI Services
  Future<String> summarizeText(String text) async {
    try {
      final response = await _dio.post('/ai/summarize', data: {'text': text});

      if (response.statusCode == 200) {
        return response.data['summary'];
      } else {
        throw Exception('Failed to summarize text');
      }
    } catch (e) {
      throw Exception('Error summarizing text: $e');
    }
  }

  Future<String> translateText(String text, String targetLanguage) async {
    // Translation is now handled by Flutter translator library on the frontend
    // This method is kept for compatibility but should not be used
    try {
      return text; // Return original text as fallback
    } catch (e) {
      throw Exception(
        'Translation functionality moved to frontend translator library',
      );
    }
  }

  Future<String> generateAudio(String text, String language) async {
    try {
      final response = await _dio.post(
        '/ai/tts',
        data: {'text': text, 'language': language},
      );

      if (response.statusCode == 200) {
        return response.data['audio_url'];
      } else {
        throw Exception('Failed to generate audio');
      }
    } catch (e) {
      throw Exception('Error generating audio: $e');
    }
  }

  // Progress Methods
  Future<List<Map<String, dynamic>>> getUserProgress(String userId) async {
    try {
      final response = await _dio.get('/quizzes/progress/$userId');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to fetch user progress');
      }
    } catch (e) {
      throw Exception('Error fetching user progress: $e');
    }
  }
}
