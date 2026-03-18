import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';
import 'quiz_screen.dart';

class MistakeReviewScreen extends StatelessWidget {
  const MistakeReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<ProgressProvider>();
    final wrongAnswers = progressProvider.wrongAnswers;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Mistakes'),
        elevation: 0,
        actions: [
          if (wrongAnswers.isNotEmpty)
            TextButton(
              onPressed: () => _showClearConfirmation(context, progressProvider),
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      body: wrongAnswers.isEmpty
          ? _buildEmptyState(context)
          : _buildMistakesList(context, wrongAnswers),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 100,
            color: AppColors.correct.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Mistakes to Review!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Keep up the great work!\nCome back after completing some quizzes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildMistakesList(BuildContext context, List<Map<String, dynamic>> wrongAnswers) {
    return Column(
      children: [
        // Header with stats
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.accentLight.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.refresh,
                  color: AppColors.accentLight,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${wrongAnswers.length} Questions to Review',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Practice these to strengthen your weak areas',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Mistakes list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wrongAnswers.length,
            itemBuilder: (context, index) {
              final mistake = wrongAnswers[index];
              return _buildMistakeCard(context, mistake, index);
            },
          ),
        ),
        
        // Practice All Button
        if (wrongAnswers.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton.icon(
                onPressed: () => _startReviewQuiz(context, wrongAnswers),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'Practice All Mistakes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMistakeCard(BuildContext context, Map<String, dynamic> mistake, int index) {
    final question = mistake['question'] ?? 'Unknown question';
    final correctAnswer = mistake['correctAnswer'] ?? '';
    final selectedAnswer = mistake['selectedAnswer'] ?? '';
    final explanation = mistake['explanation'] ?? '';
    final attempts = mistake['attempts'] ?? 1;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.wrong.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: AppColors.wrong,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          question,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: attempts > 1
            ? Text(
                'Wrong $attempts times',
                style: TextStyle(
                  color: AppColors.wrong,
                  fontSize: 12,
                ),
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                
                // Your answer
                Row(
                  children: [
                    Icon(Icons.close, color: AppColors.wrong, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your answer: $selectedAnswer',
                        style: TextStyle(
                          color: AppColors.wrong,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Correct answer
                Row(
                  children: [
                    Icon(Icons.check, color: AppColors.correct, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Correct answer: $correctAnswer',
                        style: TextStyle(
                          color: AppColors.correct,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Explanation
                if (explanation.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.3),
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
                          explanation,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: '$question\nCorrect: $correctAnswer'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copy'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _removeMistake(context, mistake),
                      icon: const Icon(Icons.check_circle, size: 18, color: AppColors.correct),
                      label: const Text(
                        'Mark as Learned',
                        style: TextStyle(color: AppColors.correct),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _removeMistake(BuildContext context, Map<String, dynamic> mistake) {
    HapticFeedback.lightImpact();
    final questionId = mistake['questionId'];
    context.read<ProgressProvider>().removeWrongAnswer(questionId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Marked as learned! Great job! 🎉'),
        backgroundColor: AppColors.correct,
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, ProgressProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Mistakes?'),
        content: const Text(
          'This will remove all questions from your review list. You cannot undo this action.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearAllWrongAnswers();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All mistakes cleared')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _startReviewQuiz(BuildContext context, List<Map<String, dynamic>> wrongAnswers) {
    // TODO: Implement review quiz mode
    // For now, show a coming soon message
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Practice Mode'),
        content: Text(
          'Ready to practice ${wrongAnswers.length} questions you got wrong?\n\nThis feature will be available in the next update!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
