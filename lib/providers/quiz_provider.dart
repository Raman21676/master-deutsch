import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/json_loader_service.dart';

class QuizProvider with ChangeNotifier {
  String? _currentSetId;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _correctAttemptsCount = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;
  bool _isCorrect = false;
  bool _showFeedback = false;
  List<Map<String, dynamic>> _answers = [];
  bool _isQuizActive = false;

  // Getters
  String? get currentSetId => _currentSetId;
  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  int get correctAttemptsCount => _correctAttemptsCount;
  int? get selectedAnswerIndex => _selectedAnswerIndex;
  bool get hasAnswered => _hasAnswered;
  bool get isCorrect => _isCorrect;
  bool get showFeedback => _showFeedback;
  bool get isQuizActive => _isQuizActive;
  List<Map<String, dynamic>> get answers => _answers;

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
  Future<void> startQuiz(String setId) async {
    _currentSetId = setId;
    _questions = await JsonLoaderService.loadShuffledQuestions(setId);
    _currentQuestionIndex = 0;
    _score = 0;
    _correctAttemptsCount = 0;
    _selectedAnswerIndex = null;
    _hasAnswered = false;
    _isCorrect = false;
    _showFeedback = false;
    _answers = [];
    _isQuizActive = true;
    notifyListeners();
  }

  void selectAnswer(int answerIndex) {
    if (_hasAnswered || currentQuestion == null) return;

    _selectedAnswerIndex = answerIndex;
    _hasAnswered = true;
    _isCorrect = currentQuestion!.checkAnswer(answerIndex);
    _showFeedback = true;

    if (_isCorrect) {
      _score++;
      _correctAttemptsCount++;
    }

    // Record the answer
    _answers.add({
      'questionIndex': _currentQuestionIndex,
      'questionId': currentQuestion!.id,
      'question': currentQuestion!.questionText,
      'selectedIndex': answerIndex,
      'selectedAnswer': currentQuestion!.getOptionText(answerIndex),
      'correctIndex': currentQuestion!.correctIndex,
      'correctAnswer': currentQuestion!.correctAnswer,
      'isCorrect': _isCorrect,
      'englishTranslation': currentQuestion!.englishTranslation,
      'explanation': currentQuestion!.explanation,
    });

    notifyListeners();
  }

  void nextQuestion() {
    if (!isLastQuestion) {
      _currentQuestionIndex++;
      _selectedAnswerIndex = null;
      _hasAnswered = false;
      _isCorrect = false;
      _showFeedback = false;
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
        _selectedAnswerIndex = previousAnswer['selectedIndex'];
        _hasAnswered = true;
        _isCorrect = previousAnswer['isCorrect'];
        _showFeedback = true;
      } else {
        _selectedAnswerIndex = null;
        _hasAnswered = false;
        _isCorrect = false;
        _showFeedback = false;
      }
      notifyListeners();
    }
  }

  void hideFeedback() {
    _showFeedback = false;
    notifyListeners();
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
    _correctAttemptsCount = 0;
    _selectedAnswerIndex = null;
    _hasAnswered = false;
    _isCorrect = false;
    _showFeedback = false;
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
      return 'Hervorragend! Outstanding! You have mastered this level!';
    } else if (percentage >= 80) {
      return 'Ausgezeichnet! Excellent work! You have a strong understanding.';
    } else if (percentage >= 70) {
      return 'Sehr gut! Great job! You are making good progress.';
    } else if (percentage >= 60) {
      return 'Gut! Good effort! Keep practicing to improve.';
    } else if (percentage >= 50) {
      return 'Es geht! Not bad! Consider reviewing some material.';
    } else {
      return 'Weiter üben! Keep trying! Practice makes perfect.';
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
