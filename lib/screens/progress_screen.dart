import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_level.dart';
import '../providers/progress_provider.dart';
import '../utils/constants.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressProvider = context.watch<ProgressProvider>();
    final stats = progressProvider.getDetailedStats();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showResetDialog(context),
            tooltip: 'Reset Progress',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Overall Stats Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Your Learning Journey',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Main Progress Circle
                  _buildProgressCircle(context, stats['completionRate'] as double),
                  
                  const SizedBox(height: 24),
                  
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildHeaderStat(
                        context,
                        value: '${stats['completedSets']}',
                        label: 'Sets\nCompleted',
                      ),
                      _buildHeaderStat(
                        context,
                        value: '${stats['totalQuizzesCompleted']}',
                        label: 'Quizzes\nTaken',
                      ),
                      _buildHeaderStat(
                        context,
                        value: '${(stats['overallAccuracy'] as double).toStringAsFixed(0)}%',
                        label: 'Accuracy\nRate',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Stats Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Questions Answered',
                          value: '${stats['totalQuestionsAnswered']}',
                          icon: Icons.help_outline,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Correct Answers',
                          value: '${stats['totalCorrectAnswers']}',
                          icon: Icons.check_circle_outline,
                          color: AppColors.correct,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Current Streak',
                          value: '${stats['currentStreak']}',
                          icon: Icons.local_fire_department,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Best Streak',
                          value: '${stats['bestStreak']}',
                          icon: Icons.emoji_events,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Level Progress
                  Text(
                    'Level Progress',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Level Progress List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: quizLevels.length,
                    itemBuilder: (context, index) {
                      final level = quizLevels[index];
                      final completedSets = progressProvider
                          .getCompletedSetsCountForLevel(level.id);
                      final totalSets = level.sets.length;
                      final progress = completedSets / totalSets;
                      
                      return _buildLevelProgressCard(
                        context,
                        level: level,
                        completedSets: completedSets,
                        totalSets: totalSets,
                        progress: progress,
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Recent Activity
                  if (progressProvider.progress.isNotEmpty) ...[
                    Text(
                      'Recent Activity',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: progressProvider.progress.length.clamp(0, 5),
                      itemBuilder: (context, index) {
                        final entry = progressProvider.progress.entries
                            .toList()
                            .reversed
                            .toList()[index];
                        return _buildActivityCard(context, entry);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(BuildContext context, double percentage) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: 12,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        Column(
          children: [
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Complete',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderStat(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
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
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelProgressCard(
    BuildContext context, {
    required QuizLevel level,
    required int completedSets,
    required int totalSets,
    required double progress,
  }) {
    final color = Color(int.parse(level.color.replaceFirst('#', '0xFF')));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      level.id,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$completedSets of $totalSets sets completed',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (completedSets == totalSets)
                  Icon(Icons.check_circle, color: color, size: 24)
                else if (completedSets > 0)
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    MapEntry<String, Map<String, dynamic>> entry,
  ) {
    final setId = entry.key;
    final data = entry.value;
    final percentage = (data['percentage'] as num).toDouble();
    final completedAt = DateTime.parse(data['completedAt'] as String);
    
    // Determine level color
    String levelId = setId.substring(0, 2);
    String colorHex = '#1976D2';
    switch (levelId) {
      case 'A1': colorHex = '#4CAF50'; break;
      case 'A2': colorHex = '#8BC34A'; break;
      case 'B1': colorHex = '#FFC107'; break;
      case 'B2': colorHex = '#FF9800'; break;
      case 'C1': colorHex = '#FF5722'; break;
      case 'C2': colorHex = '#E91E63'; break;
    }
    final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              setId,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        title: Text(
          'Completed Quiz Set $setId',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '${completedAt.day}/${completedAt.month}/${completedAt.year}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _getScoreColor(percentage).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              color: _getScoreColor(percentage),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.correct;
    if (score >= 60) return AppColors.b1Color;
    return AppColors.wrong;
  }

  Future<void> _showResetDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text(
          'Are you sure you want to reset all your progress? This action cannot be undone.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.wrong,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<ProgressProvider>().resetProgress();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progress has been reset'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
