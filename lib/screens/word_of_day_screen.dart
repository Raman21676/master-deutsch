import 'package:flutter/material.dart';
import '../services/word_service.dart';
import '../models/word_of_day.dart';
import '../utils/constants.dart';

class WordOfDayScreen extends StatefulWidget {
  const WordOfDayScreen({super.key});

  @override
  State<WordOfDayScreen> createState() => _WordOfDayScreenState();
}

class _WordOfDayScreenState extends State<WordOfDayScreen> {
  final WordService _wordService = WordService();
  bool _isLoading = true;
  WordOfDay? _todaysWord;

  @override
  void initState() {
    super.initState();
    _loadWord();
  }

  Future<void> _loadWord() async {
    setState(() => _isLoading = true);
    await _wordService.initialize();
    setState(() {
      _todaysWord = _wordService.getTodaysWord();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Word of the Day'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _todaysWord == null
          ? _buildEmptyState(theme)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Day Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.accentLight,
                            AppColors.secondaryLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Day ${_wordService.getCurrentDayOfYear()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // German Word Card
                  Card(
                    elevation: 8,
                    color: AppColors.primaryLight,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.translate,
                            size: 48,
                            color: AppColors.accentLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _todaysWord!.germanWord,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: AppColors.accentLight,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // English Meaning
                  _buildInfoCard(
                    icon: Icons.info_outline,
                    title: 'English Meaning',
                    content: _todaysWord!.englishMeaning,
                    color: AppColors.secondaryLight,
                  ),

                  const SizedBox(height: 16),

                  // Example Sentence (German)
                  _buildInfoCard(
                    icon: Icons.chat_outlined,
                    title: 'Example (Deutsch)',
                    content: _todaysWord!.exampleSentenceGerman,
                    color: AppColors.accentLight,
                  ),

                  const SizedBox(height: 16),

                  // Example Translation (English)
                  _buildInfoCard(
                    icon: Icons.chat_bubble_outline,
                    title: 'Translation',
                    content: _todaysWord!.exampleSentenceEnglish,
                    color: AppColors.secondaryLight.withOpacity(0.7),
                  ),

                  const SizedBox(height: 32),

                  // Practice Card
                  Card(
                    color: AppColors.correct.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.correct,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Practice Tip',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.correct,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Try using this word in a sentence today to help remember it!',
                            textAlign: TextAlign.center,
                            style: TextStyle(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'No word available',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadWord, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
