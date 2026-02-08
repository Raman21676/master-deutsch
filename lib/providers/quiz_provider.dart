import 'package:flutter/material.dart';
import '../models/question.dart';
import '../data/quiz_data.dart';

class QuizProvider with ChangeNotifier {
  String? _currentSetId;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _hasAnswered = false;
  bool _isCorrect = false;
  bool _isCorrect = false;
  List<Map<String, dynamic>> _answers = [];
  bool _isQuizActive = false;

  // Shuffled options for the current question: List of pairs [OptionText, IsCorrect]
  List<MapEntry<String, bool>> _currentShuffledOptions = [];

  // Getters
  String? get currentSetId => _currentSetId;
  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  String? get selectedAnswer => _selectedAnswer;
  bool get hasAnswered => _hasAnswered;
  bool get isCorrect => _isCorrect;
  bool get isQuizActive => _isQuizActive;
  bool get isQuizActive => _isQuizActive;
  List<Map<String, dynamic>> get answers => _answers;
  List<MapEntry<String, bool>> get currentShuffledOptions =>
      _currentShuffledOptions;

  Question? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      return null;
    }
    return _questions[_currentQuestionIndex];
  }

  int get totalQuestions => _questions.length;
  int get currentQuestionNumber => _currentQuestionIndex + 1;
  bool get isLastQuestion => _currentQuestionIndex >= _questions.length - 1;
  bool get isFirstQuestion => _currentQuestionIndex == 0;

  double get progressPercentage {
    if (_questions.isEmpty) return 0.0;
    return (_currentQuestionIndex + 1) / _questions.length;
  }

  // Quiz control methods
  void startQuiz(String setId) {
    _currentSetId = setId;
    _currentSetId = setId;
    _questions = QuizData.getQuestionsForSet(setId);
    _currentQuestionIndex = 0;
    _prepareCurrentQuestion();
    _score = 0;
    _selectedAnswer = null;
    _hasAnswered = false;
    _isCorrect = false;
    _answers = [];
    _isQuizActive = true;
    notifyListeners();
  }

  void selectAnswer(String answer) {
    if (_hasAnswered || currentQuestion == null) return;

    _selectedAnswer = answer; // 'A', 'B', 'C', or 'D' (index in shuffled list)
    _hasAnswered = true;

    // In the new system, 'answer' is the INDEX of the selected option in _currentShuffledOptions
    // We need to map 'A', 'B', 'C', 'D' to 0, 1, 2, 3
    final index = _optionLabelToIndex(answer);
    if (index >= 0 && index < _currentShuffledOptions.length) {
      _isCorrect = _currentShuffledOptions[index].value;
    } else {
      _isCorrect = false;
    }

    // For backward mapping in analytics, we need to find which ORIGINAL option this was
    // But for now, we just store the text
    final selectedText = _currentShuffledOptions[index].key;

    if (_isCorrect) {
      _score++;
    }

    // Record the answer
    _answers.add({
      'questionIndex': _currentQuestionIndex,
      'question': currentQuestion!.questionText,
      'selectedAnswer': answer, // Keeps A/B/C/D format for UI consistency
      'selectedText': selectedText,
      'correctAnswer': currentQuestion!.correctAnswer,
      'isCorrect': _isCorrect,
      'options': {
        'A': _currentShuffledOptions.isNotEmpty
            ? _currentShuffledOptions[0].key
            : '',
        'B': _currentShuffledOptions.length > 1
            ? _currentShuffledOptions[1].key
            : '',
        'C': _currentShuffledOptions.length > 2
            ? _currentShuffledOptions[2].key
            : '',
        'D': _currentShuffledOptions.length > 3
            ? _currentShuffledOptions[3].key
            : '',
      },
    });

    notifyListeners();
  }

  void nextQuestion() {
    if (!isLastQuestion) {
      _currentQuestionIndex++;
      _prepareCurrentQuestion();
      _selectedAnswer = null;
      _hasAnswered = false;
      _isCorrect = false;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (!isFirstQuestion) {
      _currentQuestionIndex--;
      // Restore state from previous answer if exists
      final previousAnswer = _answers.firstWhere(
        (a) => a['questionIndex'] == _currentQuestionIndex,
        orElse: () => {},
      );
      if (previousAnswer.isNotEmpty) {
        _selectedAnswer = previousAnswer['selectedAnswer'];
        _hasAnswered = true;
        _isCorrect = previousAnswer['isCorrect'];
      } else {
        _selectedAnswer = null;
        _hasAnswered = false;
        _isCorrect = false;
      }
      notifyListeners();
    }
  }

  void endQuiz() {
    _isQuizActive = false;
    notifyListeners();
  }

  void resetQuiz() {
    if (_currentSetId != null) {
      startQuiz(_currentSetId!);
    }
  }

  void quitQuiz() {
    _isQuizActive = false;
    _currentSetId = null;
    _questions = [];
    _currentQuestionIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _hasAnswered = false;
    _isCorrect = false;
    _answers = [];
    notifyListeners();
  }

  // Get results summary
  Map<String, dynamic> getResults() {
    return {
      'score': _score,
      'totalQuestions': _questions.length,
      'percentage': (_score / _questions.length) * 100,
      'correctAnswers': _score,
      'wrongAnswers': _questions.length - _score,
      'answers': _answers,
    };
  }

  String getPerformanceMessage() {
    final percentage = (_score / _questions.length) * 100;
    if (percentage >= 90) {
      return 'Outstanding! You have mastered this level!';
    } else if (percentage >= 80) {
      return 'Excellent work! You have a strong understanding.';
    } else if (percentage >= 70) {
      return 'Great job! You are making good progress.';
    } else if (percentage >= 60) {
      return 'Good effort! Keep practicing to improve.';
    } else if (percentage >= 50) {
      return 'Not bad! Consider reviewing some material.';
    } else {
      return 'Keep trying! Practice makes perfect.';
    }
  }

  Color getPerformanceColor() {
    final percentage = (_score / _questions.length) * 100;
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
