import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';

class CorrectFeedbackScreen extends StatelessWidget {
  const CorrectFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final question = quizProvider.currentQuestion;

    if (question == null) {
      return const Scaffold(body: Center(child: Text('No question data')));
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade400, Colors.green.shade700],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header with celebration - Fixed height, non-scrollable
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.celebration,
                        size: 80,
                        color: Colors.white,
                      ).animate().scale(
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Richtig!',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: -0.3, duration: 400.ms),
                      const SizedBox(height: 4),
                      Text(
                        'Correct!',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(color: Colors.white70),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),
              ),

              // Content card - Scrollable
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question
                        _buildSection(
                          context,
                          title: 'Frage / Question',
                          content: question.questionText,
                          icon: Icons.help_outline,
                          color: Colors.blue,
                        ),

                        const SizedBox(height: 16),

                        // Correct Answer
                        _buildSection(
                          context,
                          title: 'Richtige Antwort / Correct Answer',
                          content: question.correctAnswer,
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),

                        const SizedBox(height: 16),

                        // English Translation
                        _buildSection(
                          context,
                          title: 'Übersetzung / Translation',
                          content: question.englishTranslation,
                          icon: Icons.translate,
                          color: Colors.orange,
                        ),

                        const SizedBox(height: 16),

                        // Explanation
                        _buildSection(
                          context,
                          title: 'Erklärung / Explanation',
                          content: question.explanation,
                          icon: Icons.lightbulb_outline,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms)
                .slideY(begin: 0.3, duration: 500.ms),
              ),

              // Spacer
              const SliverPadding(padding: EdgeInsets.only(top: 16)),

              // Next button - Fixed at bottom
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (quizProvider.isLastQuestion) {
                          quizProvider.endQuiz();
                          Navigator.pushReplacementNamed(context, '/results');
                        } else {
                          quizProvider.nextQuestion();
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            quizProvider.isLastQuestion
                                ? 'Ergebnisse anzeigen / Show Results'
                                : 'Nächste Frage / Next',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!quizProvider.isLastQuestion) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 600.ms)
                .slideY(begin: 0.5, duration: 400.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }
}
