import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

// Lessons Provider
final lessonsProvider = FutureProvider.family<List<Lesson>, LessonFilters>((
  ref,
  filters,
) async {
  final apiService = ref.read(apiServiceProvider);

  return await apiService.getLessons(
    difficulty: filters.difficulty,
    lang: filters.language,
  );
});

// Single Lesson Provider
final lessonProvider = FutureProvider.family<Lesson, String>((
  ref,
  lessonId,
) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getLesson(lessonId);
});

// Lessons Service Provider
final lessonsServiceProvider = Provider<LessonsService>(
  (ref) => LessonsService(ref.read(apiServiceProvider)),
);

class LessonFilters {
  final String? difficulty;
  final String? language;

  const LessonFilters({this.difficulty, this.language});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonFilters &&
          runtimeType == other.runtimeType &&
          difficulty == other.difficulty &&
          language == other.language;

  @override
  int get hashCode => difficulty.hashCode ^ language.hashCode;
}

class LessonsService {
  final ApiService _apiService;

  LessonsService(this._apiService);

  Future<List<Lesson>> getLessons({
    String? difficulty,
    String? language,
  }) async {
    return await _apiService.getLessons(difficulty: difficulty, lang: language);
  }

  Future<Lesson> getLesson(String lessonId) async {
    return await _apiService.getLesson(lessonId);
  }

  Future<void> markLessonComplete(String lessonId, {int score = 100}) async {
    await _apiService.markLessonComplete(lessonId, score);
  }

  // Helper methods for filtering
  static List<String> getDifficultyLevels() {
    return ['Beginner', 'Intermediate', 'Advanced'];
  }

  static List<String> getLanguages() {
    return [
      'English',
      'Hindi',
      'Bengali',
      'Tamil',
      'Telugu',
      'Marathi',
      'Gujarati',
      'Kannada',
      'Malayalam',
      'Punjabi',
      'Odia',
      'Assamese',
      'Urdu',
    ];
  }
}
