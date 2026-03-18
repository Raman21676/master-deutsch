import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../utils/constants.dart';
import 'daily_challenge_quiz_screen.dart';

class DailyChallengeScreen extends StatelessWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<ProgressProvider>();
    final currentStreak = progressProvider.currentDailyStreak;
    final bestStreak = progressProvider.bestDailyStreak;
    final todayCompleted = progressProvider.todayCompleted;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Header
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF6B6B),
                      Color(0xFFFF8E53),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Flame icon with animation
                      Icon(
                        Icons.local_fire_department,
                        size: 80,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$currentStreak',
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Day Streak! 🔥',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Best: $bestStreak days',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's Challenge Card
                  _buildChallengeCard(context, todayCompleted),
                  
                  const SizedBox(height: 24),
                  
                  // Streak Benefits
                  const Text(
                    'Why Keep Your Streak?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildBenefitCard(
                    icon: Icons.psychology,
                    title: 'Build Consistency',
                    description: 'Learning a little every day is better than cramming once a week.',
                    color: Colors.blue,
                  ),
                  
                  _buildBenefitCard(
                    icon: Icons.trending_up,
                    title: 'Better Retention',
                    description: 'Daily practice helps move German from short-term to long-term memory.',
                    color: Colors.green,
                  ),
                  
                  _buildBenefitCard(
                    icon: Icons.emoji_events,
                    title: 'Unlock Achievements',
                    description: 'Reach 7, 30, and 100 day streaks for special badges!',
                    color: Colors.orange,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Streak Milestones
                  const Text(
                    'Milestones',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildMilestones(currentStreak),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, bool todayCompleted) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: todayCompleted
              ? LinearGradient(
                  colors: [
                    AppColors.correct.withOpacity(0.2),
                    AppColors.correct.withOpacity(0.1),
                  ],
                )
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: todayCompleted
                        ? AppColors.correct.withOpacity(0.2)
                        : const Color(0xFFFF6B6B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    todayCompleted ? Icons.check_circle : Icons.alarm,
                    color: todayCompleted ? AppColors.correct : const Color(0xFFFF6B6B),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todayCompleted ? 'Completed!' : 'Daily Challenge',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        todayCompleted
                            ? 'Great job! Come back tomorrow for a new challenge.'
                            : 'Complete 5 questions to keep your streak alive!',
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
            
            if (!todayCompleted) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _startDailyChallenge(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'Start Challenge',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.correct.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.celebration, color: AppColors.correct),
                    const SizedBox(width: 8),
                    Text(
                      'You\'ve completed today\'s challenge!',
                      style: TextStyle(
                        color: AppColors.correct,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestones(int currentStreak) {
    final milestones = [
      {'days': 3, 'title': 'Getting Started', 'icon': Icons.spa},
      {'days': 7, 'title': 'First Week!', 'icon': Icons.local_fire_department},
      {'days': 14, 'title': 'Two Weeks Strong', 'icon': Icons.fitness_center},
      {'days': 30, 'title': 'Monthly Master', 'icon': Icons.emoji_events},
      {'days': 60, 'title': 'Dedicated Learner', 'icon': Icons.military_tech},
      {'days': 100, 'title': 'Centurion', 'icon': Icons.stars},
    ];
    
    return Column(
      children: milestones.map((milestone) {
        final days = milestone['days'] as int;
        final isReached = currentStreak >= days;
        final isNext = currentStreak < days && (currentStreak >= (days ~/ 2) || days == 3);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: isReached ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isReached
                  ? AppColors.correct
                  : isNext
                      ? Colors.orange.withOpacity(0.5)
                      : Colors.grey.withOpacity(0.2),
              width: isReached ? 2 : 1,
            ),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isReached
                    ? AppColors.correct.withOpacity(0.2)
                    : isNext
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                milestone['icon'] as IconData,
                color: isReached
                    ? AppColors.correct
                    : isNext
                        ? Colors.orange
                        : Colors.grey,
                size: 24,
              ),
            ),
            title: Text(
              milestone['title'] as String,
              style: TextStyle(
                fontWeight: isReached ? FontWeight.bold : FontWeight.normal,
                color: isReached ? AppColors.correct : null,
              ),
            ),
            subtitle: Text('$days days'),
            trailing: isReached
                ? const Icon(Icons.check_circle, color: AppColors.correct)
                : isNext
                    ? Text(
                        '${days - currentStreak} more',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : Icon(Icons.lock_outline, color: Colors.grey[400]),
          ),
        );
      }).toList(),
    );
  }

  void _startDailyChallenge(BuildContext context) {
    HapticFeedback.mediumImpact();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DailyChallengeQuizScreen(),
      ),
    );
  }
}
