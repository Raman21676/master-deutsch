import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import 'correct_feedback_screen.dart';
import 'incorrect_feedback_screen.dart';

class QuizScreen extends StatefulWidget {
  final String setId;

  const QuizScreen({super.key, required this.setId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    await context.read<QuizProvider>().startQuiz(widget.setId);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final quizProvider = context.watch<QuizProvider>();
    final theme = Theme.of(context);

    // If quiz is not active or no questions loaded
    if (!quizProvider.isQuizActive || quizProvider.questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentQuestion = quizProvider.currentQuestion;
    if (currentQuestion == null) {
      return const Scaffold(
        body: Center(child: Text('Error loading question')),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        return await _showQuitDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Question ${quizProvider.currentQuestionNumber}/${quizProvider.totalQuestions}',
          ),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (await _showQuitDialog(context)) {
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${quizProvider.correctAttemptsCount}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: quizProvider.progressPercentage,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
              minHeight: 6,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Card
                    Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // Question Number Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'FRAGE ${quizProvider.currentQuestionNumber} / QUESTION',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Question Text
                                Text(
                                  currentQuestion.questionText,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: -0.2, duration: 500.ms),

                    const SizedBox(height: 32),

                    // Options
                    ...List.generate(currentQuestion.options.length, (index) {
                      final labels = ['A', 'B', 'C', 'D'];
                      final label = labels[index];
                      final optionText = currentQuestion.options[index];

                      return _buildOptionButton(
                            context,
                            label: label,
                            text: optionText,
                            index: index,
                            isSelected:
                                quizProvider.selectedAnswerIndex == index,
                            onTap: () => _selectAnswer(context, index),
                          )
                          .animate(delay: (100 * index).ms)
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: -0.3, duration: 500.ms);
                    }),

                    const SizedBox(height: 100), // Space for bottom area
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectAnswer(BuildContext context, int answerIndex) {
    final quizProvider = context.read<QuizProvider>();

    if (quizProvider.hasAnswered) return;

    HapticFeedback.lightImpact();
    quizProvider.selectAnswer(answerIndex);

    // Navigate to feedback screen
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      if (quizProvider.isCorrect) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CorrectFeedbackScreen()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const IncorrectFeedbackScreen()),
        );
      }
    });
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required String label,
    required String text,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final quizProvider = context.watch<QuizProvider>();

    Color backgroundColor = theme.cardColor;
    Color borderColor = Colors.grey.withOpacity(0.3);
    Color textColor = theme.colorScheme.onSurface;

    if (isSelected) {
      backgroundColor = theme.colorScheme.primary.withOpacity(0.1);
      borderColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: quizProvider.hasAnswered ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? borderColor.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? textColor : Colors.grey[600],
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
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
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

  Future<bool> _showQuitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Quiz beenden? / Quit Quiz?'),
            content: const Text(
              'Möchten Sie wirklich aufhören? Ihr Fortschritt geht verloren.\n\nAre you sure you want to quit? Your progress will be lost.',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Abbrechen / Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<QuizProvider>().quitQuiz();
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Beenden / Quit'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
