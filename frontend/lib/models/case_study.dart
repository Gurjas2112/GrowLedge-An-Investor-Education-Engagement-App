class CaseStudy {
  final String id;
  final String title;
  final String url;
  final String content;
  final String summary;
  final String? hindiTranslation;
  final String source;
  final String category;
  final String difficultyLevel;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  CaseStudy({
    required this.id,
    required this.title,
    required this.url,
    required this.content,
    required this.summary,
    this.hindiTranslation,
    required this.source,
    required this.category,
    required this.difficultyLevel,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CaseStudy.fromJson(Map<String, dynamic> json) {
    return CaseStudy(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      content: json['content'] ?? '',
      summary: json['summary'] ?? '',
      hindiTranslation: json['hindi_translation'],
      source: json['source'] ?? '',
      category: json['category'] ?? '',
      difficultyLevel: json['difficulty_level'] ?? 'intermediate',
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'content': content,
      'summary': summary,
      'hindi_translation': hindiTranslation,
      'source': source,
      'category': category,
      'difficulty_level': difficultyLevel,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class CaseStudyResponse {
  final List<CaseStudy> caseStudies;
  final int totalCount;
  final int page;
  final int pageSize;

  CaseStudyResponse({
    required this.caseStudies,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  // Computed property for hasMore
  bool get hasMore => (page * pageSize) < totalCount;
  
  // Alias for totalCount to match provider expectations
  int get total => totalCount;

  factory CaseStudyResponse.fromJson(Map<String, dynamic> json) {
    return CaseStudyResponse(
      caseStudies: (json['case_studies'] as List)
          .map((item) => CaseStudy.fromJson(item))
          .toList(),
      totalCount: json['total_count'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 10,
    );
  }
}
