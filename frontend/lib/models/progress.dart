class Progress {
  final String id;
  final String userId;
  final String lessonId;
  final int score;
  final DateTime completedAt;

  Progress({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.score,
    required this.completedAt,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['user_id'] ?? '',
      lessonId: json['lesson_id'] ?? '',
      score: json['score'] ?? 0,
      completedAt: DateTime.parse(
        json['completed_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'lesson_id': lessonId,
      'score': score,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  bool get isPassed => score >= 70;
}

class Tutorial {
  final String id;
  final String title;
  final String content;
  final String difficulty;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tutorial({
    required this.id,
    required this.title,
    required this.content,
    this.difficulty = 'Beginner',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tutorial.fromJson(Map<String, dynamic> json) {
    return Tutorial(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
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
      'difficulty': difficulty,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
