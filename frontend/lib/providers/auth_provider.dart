import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user.dart';
import '../services/api_service.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Auth State Provider (checks if user is authenticated)
final authStateProvider = FutureProvider<AppUser?>((ref) async {
  final apiService = ref.read(apiServiceProvider);

  try {
    final token = await apiService.getToken();
    if (token == null) return null;

    // Quick local check first
    if (JwtDecoder.isExpired(token)) {
      await apiService.removeToken();
      return null;
    }

    // Single network call to get current user (this also verifies the token)
    return await apiService.getCurrentUser();
  } catch (e) {
    // On any error, clear token and return null
    try {
      await apiService.removeToken();
    } catch (_) {}
    return null;
  }
});

// Current User Provider
final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  return ref
      .watch(authStateProvider)
      .when(
        data: (user) => user,
        loading: () => null,
        error: (error, stack) => null,
      );
});

// Auth Service Provider
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.read(apiServiceProvider)),
);

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    return await _apiService.login(email: email, password: password);
  }

  Future<Map<String, dynamic>> signUp({
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

  Future<void> signOut() async {
    await _apiService.logout();
  }

  Future<AppUser?> getCurrentUser() async {
    return await _apiService.getCurrentUser();
  }

  Future<AppUser> updateUser(Map<String, dynamic> userData) async {
    return await _apiService.updateUser(userData);
  }

  Future<bool> isAuthenticated() async {
    final token = await _apiService.getToken();
    if (token == null) return false;

    try {
      return !JwtDecoder.isExpired(token) && await _apiService.verifyToken();
    } catch (e) {
      return false;
    }
  }
}
