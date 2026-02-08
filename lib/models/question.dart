class Question {
  final int id;
  final String questionText;
  final String englishTranslation;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  Question({
    required this.id,
    required this.questionText,
    required this.englishTranslation,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  /// Get the correct answer text
  String get correctAnswer {
    if (correctIndex >= 0 && correctIndex < options.length) {
      return options[correctIndex];
    }
    return '';
  }

  /// Check if the selected index is correct
  bool checkAnswer(int selectedIndex) {
    return selectedIndex == correctIndex;
  }

  /// Get option text by index (0-3)
  String getOptionText(int index) {
    if (index >= 0 && index < options.length) {
      return options[index];
    }
    return '';
  }

  /// Convert from JSON (from assets/questions/*.json files)
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      questionText: json['question'] as String,
      englishTranslation: json['englishTranslation'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': questionText,
      'englishTranslation': englishTranslation,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
    };
  }
}

class QuizSet {
  final String id;
  final String name;
  final String level;
  final String description;
  final List<Question> questions;

  QuizSet({
    required this.id,
    required this.name,
    required this.level,
    required this.description,
    required this.questions,
  });
}

class QuizProgress {
  final String setId;
  final int score;
  final int totalQuestions;
  final double percentage;
  final DateTime completedAt;
  final bool isCompleted;

  QuizProgress({
    required this.setId,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.completedAt,
    this.isCompleted = false,
  });

  factory QuizProgress.fromJson(Map<String, dynamic> json) {
    return QuizProgress(
      setId: json['setId'],
      score: json['score'],
      totalQuestions: json['totalQuestions'],
      percentage: json['percentage'],
      completedAt: DateTime.parse(json['completedAt']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setId': setId,
      'score': score,
      'totalQuestions': totalQuestions,
      'percentage': percentage,
      'completedAt': completedAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }
}
