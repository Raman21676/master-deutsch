import 'package:flutter/material.dart';

class AppColors {
  // Sky Blue Material 3 theme colors - Light theme
  static const Color primaryLight = Color(0xFFE3F2FD); // Light Blue
  static const Color accentLight = Color(0xFF1976D2); // Deep Blue
  static const Color secondaryLight = Color(0xFF64B5F6); // Sky Blue
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);

  // Dark theme colors
  static const Color primaryDark = Color(0xFF1976D2); // Deep Blue for dark
  static const Color accentDark = Color(0xFF64B5F6);
  static const Color secondaryDark = Color(0xFF90CAF9);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Level colors
  static const Color a1Color = Color(0xFF4CAF50);
  static const Color a2Color = Color(0xFF8BC34A);
  static const Color b1Color = Color(0xFFFFC107);
  static const Color b2Color = Color(0xFFFF9800);
  static const Color c1Color = Color(0xFFFF5722);
  static const Color c2Color = Color(0xFFE91E63);

  // Result colors
  static const Color correct = Color(0xFF4CAF50);
  static const Color wrong = Color(0xFFE53935);
}

class AppThemes {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentLight, // Deep Blue as primary
        secondary: AppColors.secondaryLight,
        surface: AppColors.surfaceLight,
        background: AppColors.backgroundLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
        onBackground: AppColors.textPrimaryLight,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(24),
          ), // 24dp as specified
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
        filled: true,
        fillColor: AppColors.primaryLight.withOpacity(0.1),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryLight,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryLight,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimaryLight),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.secondaryDark,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
        onBackground: AppColors.textPrimaryDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardTheme: const CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
        filled: true,
        fillColor: AppColors.primaryDark.withOpacity(0.1),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryDark,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimaryDark),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondaryDark),
      ),
    );
  }
}

class AppStrings {
  static const String appName = 'Master Deutsch';
  static const String welcomeMessage = 'Learn German at Your Own Pace';
  static const String selectLevel = 'Select Your Level';
  static const String startQuiz = 'Start Quiz';
  static const String nextQuestion = 'Next Question';
  static const String finishQuiz = 'Finish Quiz';
  static const String quitQuiz = 'Quit Quiz';
  static const String areYouSure = 'Are you sure?';
  static const String quitConfirm =
      'Your progress will be lost. Do you want to quit?';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String correct = 'Correct!';
  static const String wrong = 'Wrong!';
  static const String yourScore = 'Your Score';
  static const String questionsCorrect = 'Questions Correct';
  static const String percentage = 'Percentage';
  static const String tryAgain = 'Try Again';
  static const String backToHome = 'Back to Home';
  static const String progress = 'Progress';
  static const String noProgress = 'No progress yet. Start a quiz!';
  static const String theme = 'Theme';
  static const String light = 'Light';
  static const String dark = 'Dark';
  static const String system = 'System';
}
