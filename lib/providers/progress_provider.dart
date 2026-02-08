import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressProvider with ChangeNotifier {
  static const String _progressKey = 'quiz_progress';
  static const String _statsKey = 'quiz_stats';
  
  Map<String, Map<String, dynamic>> _progress = {};
  Map<String, int> _stats = {
    'totalQuestionsAnswered': 0,
    'totalCorrectAnswers': 0,
    'totalQuizzesCompleted': 0,
    'currentStreak': 0,
    'bestStreak': 0,
  };
  
  ProgressProvider() {
    _loadProgress();
    _loadStats();
  }
  
  // Getters
  Map<String, Map<String, dynamic>> get progress => Map.unmodifiable(_progress);
  Map<String, int> get stats => Map.unmodifiable(_stats);
  
  int get totalQuestionsAnswered => _stats['totalQuestionsAnswered'] ?? 0;
  int get totalCorrectAnswers => _stats['totalCorrectAnswers'] ?? 0;
  int get totalQuizzesCompleted => _stats['totalQuizzesCompleted'] ?? 0;
  int get currentStreak => _stats['currentStreak'] ?? 0;
  int get bestStreak => _stats['bestStreak'] ?? 0;
  
  double get overallAccuracy {
    if (totalQuestionsAnswered == 0) return 0.0;
    return (totalCorrectAnswers / totalQuestionsAnswered) * 100;
  }
  
  // Progress methods
  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_progressKey);
    if (progressJson != null) {
      final decoded = jsonDecode(progressJson) as Map<String, dynamic>;
      _progress = decoded.map((key, value) => 
        MapEntry(key, Map<String, dynamic>.from(value)));
      notifyListeners();
    }
  }
  
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(_progress));
  }
  
  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);
    if (statsJson != null) {
      _stats = Map<String, int>.from(jsonDecode(statsJson));
      notifyListeners();
    }
  }
  
  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, jsonEncode(_stats));
  }
  
  Future<void> saveQuizProgress(String setId, int score, int totalQuestions, 
      List<Map<String, dynamic>> answers) async {
    final percentage = (score / totalQuestions) * 100;
    final now = DateTime.now().toIso8601String();
    
    // Update progress for this set
    _progress[setId] = {
      'score': score,
      'totalQuestions': totalQuestions,
      'percentage': percentage,
      'completedAt': now,
      'attempts': (_progress[setId]?['attempts'] ?? 0) + 1,
      'bestScore': _getBestScore(setId, score, totalQuestions),
      'answers': answers,
    };
    
    // Update stats
    _stats['totalQuestionsAnswered'] = 
        (_stats['totalQuestionsAnswered'] ?? 0) + totalQuestions;
    _stats['totalCorrectAnswers'] = 
        (_stats['totalCorrectAnswers'] ?? 0) + score;
    _stats['totalQuizzesCompleted'] = 
        (_stats['totalQuizzesCompleted'] ?? 0) + 1;
    
    // Update streak
    if (percentage >= 60) {
      _stats['currentStreak'] = (_stats['currentStreak'] ?? 0) + 1;
      if ((_stats['currentStreak'] ?? 0) > (_stats['bestStreak'] ?? 0)) {
        _stats['bestStreak'] = (_stats['currentStreak'] ?? 0);
      }
    } else {
      _stats['currentStreak'] = 0;
    }
    
    await _saveProgress();
    await _saveStats();
    notifyListeners();
  }
  
  double _getBestScore(String setId, int currentScore, int totalQuestions) {
    final currentPercentage = (currentScore / totalQuestions) * 100;
    final previousBest = _progress[setId]?['bestScore'] ?? 0.0;
    return currentPercentage > previousBest ? currentPercentage : previousBest;
  }
  
  Map<String, dynamic>? getProgressForSet(String setId) {
    return _progress[setId];
  }
  
  bool hasCompletedSet(String setId) {
    return _progress.containsKey(setId);
  }
  
  double getBestScoreForSet(String setId) {
    return (_progress[setId]?['bestScore'] ?? 0.0).toDouble();
  }
  
  int getAttemptsForSet(String setId) {
    return _progress[setId]?['attempts'] ?? 0;
  }
  
  List<String> getCompletedSets() {
    return _progress.keys.toList();
  }
  
  double getLevelProgress(String levelId) {
    final levelSets = _progress.entries.where((entry) => 
      entry.key.startsWith(levelId));
    if (levelSets.isEmpty) return 0.0;
    
    final totalPercentage = levelSets.fold<double>(
      0.0, 
      (sum, entry) => sum + (entry.value['percentage'] ?? 0.0)
    );
    return totalPercentage / levelSets.length;
  }
  
  int getCompletedSetsCountForLevel(String levelId) {
    return _progress.keys.where((key) => key.startsWith(levelId)).length;
  }
  
  Future<void> resetProgress() async {
    _progress = {};
    _stats = {
      'totalQuestionsAnswered': 0,
      'totalCorrectAnswers': 0,
      'totalQuizzesCompleted': 0,
      'currentStreak': 0,
      'bestStreak': 0,
    };
    await _saveProgress();
    await _saveStats();
    notifyListeners();
  }
  
  Future<void> resetProgressForSet(String setId) async {
    _progress.remove(setId);
    await _saveProgress();
    notifyListeners();
  }
  
  // Get detailed statistics
  Map<String, dynamic> getDetailedStats() {
    final completedSets = _progress.length;
    final totalSets = 12; // Total number of quiz sets
    final completionRate = (completedSets / totalSets) * 100;
    
    return {
      'completedSets': completedSets,
      'totalSets': totalSets,
      'completionRate': completionRate,
      'overallAccuracy': overallAccuracy,
      'averageScore': _calculateAverageScore(),
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'totalCorrectAnswers': totalCorrectAnswers,
    };
  }
  
  double _calculateAverageScore() {
    if (_progress.isEmpty) return 0.0;
    final total = _progress.values.fold<double>(
      0.0, 
      (sum, entry) => sum + (entry['percentage'] ?? 0.0)
    );
    return total / _progress.length;
  }
}
