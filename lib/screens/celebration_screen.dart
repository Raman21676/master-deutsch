import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import '../utils/constants.dart';

class CelebrationScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final String levelName;

  const CelebrationScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.levelName,
  });

  @override
  State<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<CelebrationScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Start confetti after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  double get scorePercentage => (widget.score / widget.totalQuestions) * 100;

  String get performanceMessage {
    if (scorePercentage >= 90) return 'Ausgezeichnet! (Excellent!)';
    if (scorePercentage >= 75) return 'Sehr gut! (Very good!)';
    if (scorePercentage >= 60) return 'Gut! (Good!)';
    if (scorePercentage >= 50) return 'Befriedigend (Satisfactory)';
    return 'Weiter üben! (Keep practicing!)';
  }

  Color get performanceColor {
    if (scorePercentage >= 75) return AppColors.correct;
    if (scorePercentage >= 50) return AppColors.secondaryLight;
    return AppColors.wrong;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryLight, AppColors.accentLight],
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Success Icon/Animation
                  if (scorePercentage >= 50)
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: Lottie.asset(
                        'assets/animations/correct_answer.json',
                        repeat: false,
                      ),
                    )
                  else
                    Icon(
                      Icons.emoji_emotions_outlined,
                      size: 120,
                      color: Colors.white,
                    ),

                  const SizedBox(height: 32),

                  // Performance Message
                  Text(
                    performanceMessage,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Level Completed
                  Text(
                    widget.levelName.toUpperCase(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Score Card
                  Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          // Score Circle
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 150,
                                height: 150,
                                child: CircularProgressIndicator(
                                  value: scorePercentage / 100,
                                  strokeWidth: 12,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    performanceColor,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    '${scorePercentage.toStringAsFixed(1)}%',
                                    style: theme.textTheme.headlineLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: performanceColor,
                                        ),
                                  ),
                                  Text(
                                    '${widget.score}/${widget.totalQuestions}',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                icon: Icons.check_circle,
                                label: 'Correct',
                                value: widget.score.toString(),
                                color: AppColors.correct,
                              ),
                              _buildStatItem(
                                icon: Icons.cancel,
                                label: 'Wrong',
                                value: (widget.totalQuestions - widget.score)
                                    .toString(),
                                color: AppColors.wrong,
                              ),
                              _buildStatItem(
                                icon: Icons.quiz,
                                label: 'Total',
                                value: widget.totalQuestions.toString(),
                                color: AppColors.accentLight,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Motivational Message
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      scorePercentage >= 75
                          ? '🎯 You\'re mastering German! Keep up the great work!'
                          : scorePercentage >= 50
                          ? '💪 Good progress! Review and try again for a better score.'
                          : '📚 Don\'t give up! Learning takes practice. You\'ve got this!',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.home),
                          label: const Text('Home'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Return to quiz with retry flag
                            Navigator.of(context).pop(true);
                          },
                          icon: const Icon(Icons.replay),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.accentLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
