import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/case_study.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class CaseStudiesState {
  final List<CaseStudy> caseStudies;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? categories;
  final int currentPage;
  final int totalCount;
  final bool hasMore;

  CaseStudiesState({
    this.caseStudies = const [],
    this.isLoading = false,
    this.error,
    this.categories,
    this.currentPage = 1,
    this.totalCount = 0,
    this.hasMore = true,
  });

  CaseStudiesState copyWith({
    List<CaseStudy>? caseStudies,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? categories,
    int? currentPage,
    int? totalCount,
    bool? hasMore,
  }) {
    return CaseStudiesState(
      caseStudies: caseStudies ?? this.caseStudies,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      categories: categories ?? this.categories,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class CaseStudiesNotifier extends StateNotifier<CaseStudiesState> {
  final ApiService _apiService;

  CaseStudiesNotifier(this._apiService) : super(CaseStudiesState());

  Future<void> loadCaseStudies({
    int page = 1,
    int pageSize = 20,
    String? category,
    String? difficulty,
    String? source,
    bool append = false,
  }) async {
    if (!append) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _apiService.getCaseStudies(
        page: page,
        pageSize: pageSize,
        category: category,
        difficulty: difficulty,
        source: source,
      );

      final caseStudyResponse = CaseStudyResponse.fromJson(response);
      
      List<CaseStudy> newCaseStudies;
      if (append && page > 1) {
        newCaseStudies = [...state.caseStudies, ...caseStudyResponse.caseStudies];
      } else {
        newCaseStudies = caseStudyResponse.caseStudies;
      }

      state = state.copyWith(
        caseStudies: newCaseStudies,
        isLoading: false,
        currentPage: page,
        totalCount: caseStudyResponse.total,
        hasMore: caseStudyResponse.hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMoreCaseStudies({
    String? category,
    String? difficulty,
    String? source,
  }) async {
    if (!state.hasMore || state.isLoading) return;

    await loadCaseStudies(
      page: state.currentPage + 1,
      category: category,
      difficulty: difficulty,
      source: source,
      append: true,
    );
  }

  Future<void> loadCategories() async {
    try {
      final response = await _apiService.getCaseStudyCategories();
      state = state.copyWith(categories: response);
    } catch (e) {
      // Categories are optional, don't update error state
      print('Error loading categories: $e');
    }
  }

  Future<CaseStudy?> getCaseStudy(String id) async {
    try {
      final response = await _apiService.getCaseStudy(id);
      return CaseStudy.fromJson(response);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void refreshCaseStudies({
    String? category,
    String? difficulty,
    String? source,
  }) {
    loadCaseStudies(
      page: 1,
      category: category,
      difficulty: difficulty,
      source: source,
    );
  }

  void filterByCategory(String? category) {
    refreshCaseStudies(category: category);
  }

  void filterByDifficulty(String? difficulty) {
    refreshCaseStudies(difficulty: difficulty);
  }

  void filterBySource(String? source) {
    refreshCaseStudies(source: source);
  }
}

final caseStudiesProvider =
    StateNotifierProvider<CaseStudiesNotifier, CaseStudiesState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return CaseStudiesNotifier(apiService);
});
