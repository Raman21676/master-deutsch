import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

/// QuizEngine - Loads and manages quiz questions from JSON assets
/// Handles question shuffling and answer randomization for all 12 levels
class QuizEngine {
  // Singleton pattern
  static final QuizEngine _instance = QuizEngine._internal();
  factory QuizEngine() => _instance;
  QuizEngine._internal();

  // Cache loaded questions by level
  final Map<String, List<Question>> _questionCache = {};

  // Level definitions (A1.1 to C2.2)
  static const List<String> levels = [
    'a1_1',
    'a1_2',
    'a2_1',
    'a2_2',
    'b1_1',
    'b1_2',
    'b2_1',
    'b2_2',
    'c1_1',
    'c1_2',
    'c2_1',
    'c2_2',
  ];

  /// Load questions for a specific level from JSON asset
  Future<List<Question>> loadQuestions(String level) async {
    // Return cached if already loaded
    if (_questionCache.containsKey(level)) {
      return _questionCache[level]!;
    }

    try {
      // Load JSON from assets
      final String jsonString = await rootBundle.loadString(
        'assets/questions/$level.json',
      );

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> questionsJson = jsonData['questions'] as List;

      // Parse questions with safety checks
      final List<Question> questions = [];
      for (var q in questionsJson) {
        final options = q['options'] as List;
        final correctIndex = q['correctIndex'] as int;
        
        // Validate options count
        if (options.length != 4) {
          throw Exception('Question ${q['id']} must have exactly 4 options');
        }
        
        // Validate correctIndex bounds
        if (correctIndex < 0 || correctIndex > 3) {
          throw Exception('Question ${q['id']} has invalid correctIndex: $correctIndex (must be 0-3)');
        }
        
        questions.add(Question(
          questionText: q['question'] as String,
          optionA: options[0] as String,
          optionB: options[1] as String,
          optionC: options[2] as String,
          optionD: options[3] as String,
          correctAnswer: options[correctIndex] as String,
        ));
      }

      // Cache for future use
      _questionCache[level] = questions;
      return questions;
    } catch (e) {
      throw Exception('Failed to load questions for level $level: $e');
    }
  }

  /// Get shuffled questions for a quiz session
  /// This randomizes the order of questions
  Future<List<Question>> getShuffledQuestions(String level) async {
    final questions = await loadQuestions(level);
    final shuffled = List<Question>.from(questions);
    shuffled.shuffle();
    return shuffled;
  }

  /// Get a specific number of random questions from a level
  Future<List<Question>> getRandomQuestions(String level, int count) async {
    final questions = await loadQuestions(level);
    final shuffled = List<Question>.from(questions)..shuffle();
    return shuffled.take(count).toList();
  }

  /// Check if questions exist for a level
  Future<bool> hasQuestionsForLevel(String level) async {
    try {
      final questions = await loadQuestions(level);
      return questions.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get total question count for a level
  Future<int> getQuestionCount(String level) async {
    final questions = await loadQuestions(level);
    return questions.length;
  }

  /// Clear question cache (useful for testing or updates)
  void clearCache([String? level]) {
    if (level != null) {
      _questionCache.remove(level);
    } else {
      _questionCache.clear();
    }
  }

  /// Validate question quality (no "Both/All" answers)
  bool validateQuestion(Question question) {
    final options = [
      question.optionA.toLowerCase(),
      question.optionB.toLowerCase(),
      question.optionC.toLowerCase(),
      question.optionD.toLowerCase(),
    ];

    // Check for prohibited patterns
    for (final option in options) {
      if (option.contains('both') ||
          option.contains('all of the above') ||
          option.contains('none of the above')) {
        return false;
      }
    }

    // Check all options are unique
    final uniqueOptions = options.toSet();
    return uniqueOptions.length == 4;
  }

  /// Get statistics across all levels
  Future<Map<String, int>> getAllLevelStats() async {
    final Map<String, int> stats = {};

    for (final level in levels) {
      try {
        final count = await getQuestionCount(level);
        stats[level] = count;
      } catch (e) {
        stats[level] = 0;
      }
    }

    return stats;
  }
}
