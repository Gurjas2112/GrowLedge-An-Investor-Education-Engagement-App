import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

// Quiz State
class QuizState {
  final Quiz? currentQuiz;
  final int currentQuestionIndex;
  final List<String> userAnswers;
  final bool isCompleted;
  final int score;
  final Map<String, dynamic>? result;

  QuizState({
    this.currentQuiz,
    this.currentQuestionIndex = 0,
    this.userAnswers = const [],
    this.isCompleted = false,
    this.score = 0,
    this.result,
  });

  QuizState copyWith({
    Quiz? currentQuiz,
    int? currentQuestionIndex,
    List<String>? userAnswers,
    bool? isCompleted,
    int? score,
    Map<String, dynamic>? result,
  }) {
    return QuizState(
      currentQuiz: currentQuiz ?? this.currentQuiz,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      isCompleted: isCompleted ?? this.isCompleted,
      score: score ?? this.score,
      result: result ?? this.result,
    );
  }
}

// Quiz Notifier
class QuizNotifier extends StateNotifier<QuizState> {
  final ApiService _apiService;

  QuizNotifier(this._apiService) : super(QuizState());

  void startQuiz(Quiz quiz) {
    state = QuizState(
      currentQuiz: quiz,
      currentQuestionIndex: 0,
      userAnswers: List.filled(quiz.questions.length, ''),
      isCompleted: false,
      score: 0,
      result: null,
    );
  }

  void answerQuestion(int questionIndex, String answer) {
    if (state.currentQuiz == null || state.isCompleted) return;

    final newAnswers = [...state.userAnswers];
    newAnswers[questionIndex] = answer;

    state = state.copyWith(userAnswers: newAnswers);
  }

  void nextQuestion() {
    if (state.currentQuiz == null ||
        state.currentQuestionIndex >= state.currentQuiz!.questions.length - 1) {
      return;
    }

    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void previousQuestion() {
    if (state.currentQuestionIndex <= 0) return;

    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex - 1,
    );
  }

  Future<void> submitQuiz() async {
    if (state.currentQuiz == null) return;

    try {
      final result = await _apiService.submitQuiz(
        state.currentQuiz!.id,
        state.userAnswers,
      );

      state = state.copyWith(
        isCompleted: true,
        score: result['score'] ?? 0,
        result: result,
      );
    } catch (e) {
      throw Exception('Failed to submit quiz: $e');
    }
  }

  void resetQuiz() {
    state = QuizState();
  }
}

// Quiz Providers
final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return QuizNotifier(apiService);
});

// Quizzes List Provider for a lesson
final quizzesProvider = FutureProvider.family<List<Quiz>, String>((
  ref,
  lessonId,
) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getLessonQuizzes(lessonId);
});

// Quiz Service Provider
final quizServiceProvider = Provider<QuizService>(
  (ref) => QuizService(ref.read(apiServiceProvider)),
);

class QuizService {
  final ApiService _apiService;

  QuizService(this._apiService);

  Future<List<Quiz>> getLessonQuizzes(String lessonId) async {
    return await _apiService.getLessonQuizzes(lessonId);
  }

  Future<Map<String, dynamic>> submitQuiz(
    String quizId,
    List<String> answers,
  ) async {
    return await _apiService.submitQuiz(quizId, answers);
  }

  // Helper method to calculate percentage score
  static double calculatePercentage(int score, int totalQuestions) {
    if (totalQuestions == 0) return 0.0;
    return (score / totalQuestions) * 100;
  }

  // Helper method to determine if quiz passed
  static bool hasPassed(int score, int totalQuestions, int passScore) {
    final percentage = calculatePercentage(score, totalQuestions);
    return percentage >= passScore;
  }
}
