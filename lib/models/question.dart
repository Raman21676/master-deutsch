class Question {
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;

  Question({
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
  });

  bool checkAnswer(String userChoice) {
    final options = {'A': optionA, 'B': optionB, 'C': optionC, 'D': optionD};
    final selectedOption = options[userChoice.toUpperCase().trim()];
    return selectedOption == correctAnswer;
  }

  String getOptionText(String choice) {
    final options = {'A': optionA, 'B': optionB, 'C': optionC, 'D': optionD};
    return options[choice.toUpperCase()] ?? '';
  }

  /// Get shuffled options for this question
  /// Returns a list of [option text, is correct] pairs
  List<MapEntry<String, bool>> getShuffledOptions() {
    final options = [
      MapEntry(optionA, optionA == correctAnswer),
      MapEntry(optionB, optionB == correctAnswer),
      MapEntry(optionC, optionC == correctAnswer),
      MapEntry(optionD, optionD == correctAnswer),
    ];
    options.shuffle();
    return options;
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['question'],
      optionA: json['A'],
      optionB: json['B'],
      optionC: json['C'],
      optionD: json['D'],
      correctAnswer: json['R'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': questionText,
      'A': optionA,
      'B': optionB,
      'C': optionC,
      'D': optionD,
      'R': correctAnswer,
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
