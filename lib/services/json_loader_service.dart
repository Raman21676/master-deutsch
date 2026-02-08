import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/question.dart';

/// Service to load quiz questions from JSON files in assets/questions/
class JsonLoaderService {
  // Cache to store loaded questions
  static final Map<String, List<Question>> _questionCache = {};

  /// Load questions for a specific level from JSON file
  /// Level IDs: A1.1, A1.2, A2.1, A2.2, B1.1, B1.2, B2.1, B2.2, C1.1, C1.2, C2.1, C2.2
  static Future<List<Question>> loadQuestionsForLevel(String levelId) async {
    // Check cache first
    if (_questionCache.containsKey(levelId)) {
      return List<Question>.from(_questionCache[levelId]!);
    }

    try {
      // Convert level ID to filename (e.g., "A1.1" -> "a1_1.json")
      final filename = levelId.toLowerCase().replaceAll('.', '_');
      final assetPath = 'assets/questions/$filename.json';

      // Load JSON file
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // Parse questions array
      final questionsJson = jsonData['questions'] as List;
      final questions = questionsJson
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList();

      // Cache the questions
      _questionCache[levelId] = questions;

      return questions;
    } catch (e) {
      print('Error loading questions for level $levelId: $e');
      return [];
    }
  }

  /// Load and shuffle questions for a quiz session
  static Future<List<Question>> loadShuffledQuestions(String levelId) async {
    final questions = await loadQuestionsForLevel(levelId);
    final shuffled = List<Question>.from(questions);
    shuffled.shuffle(Random());
    return shuffled;
  }

  /// Get total question count for a level
  static Future<int> getQuestionCount(String levelId) async {
    final questions = await loadQuestionsForLevel(levelId);
    return questions.length;
  }

  /// Preload all questions (useful for first app launch)
  static Future<void> preloadAllQuestions() async {
    final levels = [
      'A1.1',
      'A1.2',
      'A2.1',
      'A2.2',
      'B1.1',
      'B1.2',
      'B2.1',
      'B2.2',
      'C1.1',
      'C1.2',
      'C2.1',
      'C2.2',
    ];

    for (final level in levels) {
      await loadQuestionsForLevel(level);
    }
  }

  /// Clear cache (useful for testing or memory management)
  static void clearCache() {
    _questionCache.clear();
  }

  /// Get level metadata from JSON
  static Future<Map<String, dynamic>> getLevelMetadata(String levelId) async {
    try {
      final filename = levelId.toLowerCase().replaceAll('.', '_');
      final assetPath = 'assets/questions/$filename.json';

      final jsonString = await rootBundle.loadString(assetPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      return {
        'level': jsonData['level'],
        'title': jsonData['title'],
        'totalQuestions': jsonData['totalQuestions'],
      };
    } catch (e) {
      print('Error loading metadata for level $levelId: $e');
      return {};
    }
  }
}
