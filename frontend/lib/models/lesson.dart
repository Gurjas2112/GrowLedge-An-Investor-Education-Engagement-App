class Lesson {
  final String id;
  final String title;
  final String content;
  final String lang;
  final String difficulty;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    this.lang = 'English',
    this.difficulty = 'Beginner',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      lang: json['lang'] ?? 'English',
      difficulty: json['difficulty'] ?? 'Beginner',
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
      'content': content,
      'lang': lang,
      'difficulty': difficulty,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper method to check if lesson is in specific language
  bool isInLanguage(String language) {
    return lang.toLowerCase() == language.toLowerCase();
  }
}
