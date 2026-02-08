import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/word_of_day.dart';

class WordService {
  static final WordService _instance = WordService._internal();
  factory WordService() => _instance;
  WordService._internal();

  List<WordOfDay> _words = [];
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/words/daily_words.json',
      );
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _words = jsonList.map((json) => WordOfDay.fromJson(json)).toList();
      _isInitialized = true;
    } catch (e) {
      // If file doesn't exist, use empty list
      _words = [];
      _isInitialized = true;
    }
  }

  WordOfDay? getWordForDay(int dayOfYear) {
    if (!_isInitialized || _words.isEmpty) return null;

    // Wrap around if dayOfYear exceeds available words
    final index = (dayOfYear - 1) % _words.length;
    return _words[index];
  }

  WordOfDay? getTodaysWord() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
    return getWordForDay(dayOfYear);
  }

  int getCurrentDayOfYear() {
    final now = DateTime.now();
    return now.difference(DateTime(now.year, 1, 1)).inDays + 1;
  }

  List<WordOfDay> getAllWords() {
    return List.unmodifiable(_words);
  }
}
