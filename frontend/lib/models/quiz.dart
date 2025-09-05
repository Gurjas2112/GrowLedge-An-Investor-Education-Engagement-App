class QuizQuestion {
  final String q; // question text
  final List<String> options; // answer options
  final String answer; // correct answer

  QuizQuestion({required this.q, required this.options, required this.answer});

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      q: json['q'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      answer: json['answer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'q': q, 'options': options, 'answer': answer};
  }

  // Helper method to get correct answer index
  int get correctAnswerIndex {
    return options.indexOf(answer);
  }
}

class Quiz {
  final String id;
  final String lessonId;
  final List<QuizQuestion> questions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Quiz({
    required this.id,
    required this.lessonId,
    required this.questions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['_id'] ?? json['id'] ?? '',
      lessonId: json['lesson_id'] ?? '',
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromJson(q))
              .toList() ??
          [],
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
      'lesson_id': lessonId,
      'questions': questions.map((q) => q.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
