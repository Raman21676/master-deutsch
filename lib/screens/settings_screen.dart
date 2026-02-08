import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.palette,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: const Text('Theme'),
                  subtitle: Text(themeProvider.currentThemeName),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showThemeDialog(context, themeProvider),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // About Section
          _buildSectionHeader(context, 'About'),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.info,
                      color: Colors.blue,
                    ),
                  ),
                  title: const Text('App Version'),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.green,
                    ),
                  ),
                  title: const Text('Total Questions'),
                  subtitle: const Text('1,200+ questions across 12 quiz sets'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.translate,
                      color: Colors.orange,
                    ),
                  ),
                  title: const Text('German Levels'),
                  subtitle: const Text('A1, A2, B1, B2, C1, C2 (CEFR)'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Features Section
          _buildSectionHeader(context, 'Features'),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildFeatureTile(
                  context,
                  icon: Icons.offline_bolt,
                  title: 'Offline Learning',
                  description: 'All content is available offline',
                  color: Colors.purple,
                ),
                const Divider(height: 1),
                _buildFeatureTile(
                  context,
                  icon: Icons.shuffle,
                  title: 'Shuffled Questions',
                  description: 'Questions are randomized for variety',
                  color: Colors.teal,
                ),
                const Divider(height: 1),
                _buildFeatureTile(
                  context,
                  icon: Icons.track_changes,
                  title: 'Progress Tracking',
                  description: 'Track your learning journey',
                  color: Colors.indigo,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Footer
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.school,
                  size: 48,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Learn German at your own pace',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(description),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context,
              title: AppStrings.light,
              icon: Icons.light_mode,
              isSelected: themeProvider.themeMode == ThemeMode.light,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            _buildThemeOption(
              context,
              title: AppStrings.dark,
              icon: Icons.dark_mode,
              isSelected: themeProvider.themeMode == ThemeMode.dark,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            _buildThemeOption(
              context,
              title: AppStrings.system,
              icon: Icons.settings_suggest,
              isSelected: themeProvider.themeMode == ThemeMode.system,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
