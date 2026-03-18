import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../providers/progress_provider.dart';
import '../providers/quiz_provider.dart';
import '../services/json_loader_service.dart';
import '../utils/constants.dart';

class DailyChallengeQuizScreen extends StatefulWidget {
  const DailyChallengeQuizScreen({super.key});

  @override
  State<DailyChallengeQuizScreen> createState() => _DailyChallengeQuizScreenState();
}

class _DailyChallengeQuizScreenState extends State<DailyChallengeQuizScreen> {
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;
  bool _isCorrect = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _answers = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    // Load questions from all levels and pick 5 random ones
    final allLevels = ['A1.1', 'A1.2', 'A2.1', 'A2.2', 'B1.1', 'B1.2', 'B2.1', 'B2.2', 'C1.1', 'C1.2', 'C2.1', 'C2.2'];
    List<Question> allQuestions = [];
    
    for (final level in allLevels) {
      final questions = await JsonLoaderService.loadQuestionsForLevel(level);
      allQuestions.addAll(questions);
    }
    
    // Shuffle and pick 5
    allQuestions.shuffle(Random());
    _questions = allQuestions.take(5).toList();
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading Daily Challenge...'),
            ],
          ),
        ),
      );
    }

    if (_currentIndex >= _questions.length) {
      return _buildResultsScreen();
    }

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Challenge'),
        backgroundColor: const Color(0xFFFF6B6B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
            minHeight: 8,
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question counter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Question ${_currentIndex + 1} of ${_questions.length}',
                      style: const TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Question card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            question.questionText,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question.englishTranslation,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Options
                  ...List.generate(question.options.length, (index) {
                    final labels = ['A', 'B', 'C', 'D'];
                    return _buildOptionButton(
                      label: labels[index],
                      text: question.options[index],
                      index: index,
                      isCorrect: index == question.correctIndex,
                      onTap: () => _selectAnswer(index),
                    );
                  }),
                  
                  const SizedBox(height: 24),
                  
                  // Feedback
                  if (_hasAnswered)
                    _buildFeedback(question),
                ],
              ),
            ),
          ),
          
          // Next button
          if (_hasAnswered)
            Container(
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentIndex < _questions.length - 1 ? 'Next Question' : 'See Results',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required String label,
    required String text,
    required int index,
    required bool isCorrect,
    required VoidCallback onTap,
  }) {
    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.withOpacity(0.3);
    Color textColor = Colors.black87;

    if (_hasAnswered) {
      if (index == _selectedAnswerIndex) {
        if (_isCorrect) {
          backgroundColor = AppColors.correct.withOpacity(0.2);
          borderColor = AppColors.correct;
          textColor = AppColors.correct;
        } else {
          backgroundColor = AppColors.wrong.withOpacity(0.2);
          borderColor = AppColors.wrong;
          textColor = AppColors.wrong;
        }
      } else if (isCorrect) {
        backgroundColor = AppColors.correct.withOpacity(0.1);
        borderColor = AppColors.correct;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _hasAnswered ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: borderColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: _hasAnswered && (index == _selectedAnswerIndex || isCorrect)
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (_hasAnswered)
                Icon(
                  isCorrect ? Icons.check_circle : (index == _selectedAnswerIndex ? Icons.cancel : null),
                  color: isCorrect ? AppColors.correct : AppColors.wrong,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback(Question question) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect ? AppColors.correct.withOpacity(0.1) : AppColors.wrong.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCorrect ? AppColors.correct : AppColors.wrong,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isCorrect ? Icons.check_circle : Icons.cancel,
                color: _isCorrect ? AppColors.correct : AppColors.wrong,
              ),
              const SizedBox(width: 8),
              Text(
                _isCorrect ? 'Correct! 🎉' : 'Not quite right',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: _isCorrect ? AppColors.correct : AppColors.wrong,
                ),
              ),
            ],
          ),
          if (!_isCorrect) ...[
            const SizedBox(height: 8),
            Text(
              'Correct answer: ${question.correctAnswer}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.correct,
              ),
            ),
          ],
          if (question.explanation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 Grammar Tip:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    question.explanation,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _selectAnswer(int index) {
    if (_hasAnswered) return;
    
    HapticFeedback.lightImpact();
    final question = _questions[_currentIndex];
    
    setState(() {
      _selectedAnswerIndex = index;
      _hasAnswered = true;
      _isCorrect = index == question.correctIndex;
      
      if (_isCorrect) {
        _score++;
      }
      
      _answers.add({
        'questionId': question.id,
        'question': question.questionText,
        'selectedIndex': index,
        'selectedAnswer': question.options[index],
        'correctIndex': question.correctIndex,
        'correctAnswer': question.correctAnswer,
        'isCorrect': _isCorrect,
        'explanation': question.explanation,
        'englishTranslation': question.englishTranslation,
      });
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      _selectedAnswerIndex = null;
      _hasAnswered = false;
      _isCorrect = false;
    });
  }

  Widget _buildResultsScreen() {
    final percentage = (_score / _questions.length) * 100;
    final isPassed = percentage >= 60;
    
    // Mark daily challenge complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().markDailyChallengeComplete();
      context.read<ProgressProvider>().saveQuizProgress(
        'daily_challenge',
        _score,
        _questions.length,
        _answers,
        isDailyChallenge: true,
      );
    });
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                Text(
                  'Daily Challenge\nComplete!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$_score/${_questions.length}',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B6B),
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: isPassed ? AppColors.correct : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isPassed 
                            ? '🔥 Streak continued! Great job!' 
                            : 'Keep practicing! You\'ll do better tomorrow.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF6B6B),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
