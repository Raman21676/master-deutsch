import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';
import 'results_screen.dart';

class QuizScreen extends StatefulWidget {
  final String setId;

  const QuizScreen({super.key, required this.setId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    // Start the quiz when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().startQuiz(widget.setId);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                child: Text(
                  'Score: ${quizProvider.score}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
                                color: theme.colorScheme.primary.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'QUESTION ${quizProvider.currentQuestionNumber}',
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
                    ),

                    const SizedBox(height: 32),

                    // Options
                    ...List.generate(
                      quizProvider.currentShuffledOptions.length,
                      (index) {
                        final labels = ['A', 'B', 'C', 'D'];
                        final label = labels[index];
                        final optionText =
                            quizProvider.currentShuffledOptions[index].key;
                        final isCorrectOption =
                            quizProvider.currentShuffledOptions[index].value;

                        return _buildOptionButton(
                          context,
                          label: label,
                          text: optionText,
                          isSelected: quizProvider.selectedAnswer == label,
                          isCorrect: isCorrectOption,
                          showResult: quizProvider.hasAnswered,
                          onTap: () => quizProvider.selectAnswer(label),
                        );
                      },
                    ),

                    // Feedback
                    if (quizProvider.hasAnswered) ...[
                      const SizedBox(height: 24),
                      _buildFeedbackCard(context, quizProvider),
                    ],

                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),

            // Bottom Navigation Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: quizProvider.hasAnswered
                        ? () => _handleNextOrFinish(context, quizProvider)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      quizProvider.isLastQuestion
                          ? AppStrings.finishQuiz
                          : AppStrings.nextQuestion,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required String label,
    required String text,
    required bool isSelected,
    required bool isCorrect,
    required bool showResult,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    Color backgroundColor = theme.cardColor;
    Color borderColor = Colors.grey.withOpacity(0.3);
    Color textColor = theme.colorScheme.onSurface;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = AppColors.correct.withOpacity(0.1);
        borderColor = AppColors.correct;
        textColor = AppColors.correct;
      } else if (isSelected && !isCorrect) {
        backgroundColor = AppColors.wrong.withOpacity(0.1);
        borderColor = AppColors.wrong;
        textColor = AppColors.wrong;
      }
    } else if (isSelected) {
      backgroundColor = theme.colorScheme.primary.withOpacity(0.1);
      borderColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: showResult ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: isSelected || (showResult && isCorrect) ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected || (showResult && isCorrect)
                        ? borderColor.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: showResult && isCorrect
                        ? const Icon(
                            Icons.check,
                            color: AppColors.correct,
                            size: 20,
                          )
                        : showResult && isSelected && !isCorrect
                        ? const Icon(
                            Icons.close,
                            color: AppColors.wrong,
                            size: 20,
                          )
                        : Text(
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

  Widget _buildFeedbackCard(BuildContext context, QuizProvider quizProvider) {
    final isCorrect = quizProvider.isCorrect;
    final currentQuestion = quizProvider.currentQuestion!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.correct.withOpacity(0.1)
            : AppColors.wrong.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect ? AppColors.correct : AppColors.wrong,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.error,
                color: isCorrect ? AppColors.correct : AppColors.wrong,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isCorrect ? AppStrings.correct : AppStrings.wrong,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? AppColors.correct : AppColors.wrong,
                ),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 12),
            Text(
              'Correct answer:',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              currentQuestion.correctAnswer,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.correct,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleNextOrFinish(BuildContext context, QuizProvider quizProvider) {
    HapticFeedback.mediumImpact();

    if (quizProvider.isLastQuestion) {
      // Save progress
      final results = quizProvider.getResults();
      context.read<ProgressProvider>().saveQuizProgress(
        widget.setId,
        results['score'],
        results['totalQuestions'],
        quizProvider.answers,
      );

      quizProvider.endQuiz();

      // Navigate to results
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(setId: widget.setId, results: results),
        ),
      );
    } else {
      quizProvider.nextQuestion();
    }
  }

  Future<bool> _showQuitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text(AppStrings.quitQuiz),
            content: const Text(AppStrings.quitConfirm),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(AppStrings.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<QuizProvider>().quitQuiz();
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.wrong,
                  foregroundColor: Colors.white,
                ),
                child: const Text(AppStrings.quitQuiz),
              ),
            ],
          ),
        ) ??
        false;
  }
}
