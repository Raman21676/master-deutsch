import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/user_provider.dart';
import 'providers/translation_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/translator_screen.dart';
import 'screens/word_of_day_screen.dart';
import 'services/notification_service.dart';
import 'services/word_service.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize services
  final notificationService = NotificationService();
  await notificationService.initialize();

  final wordService = WordService();
  await wordService.initialize();

  runApp(const MasterDeutschApp());
}

class MasterDeutschApp extends StatelessWidget {
  const MasterDeutschApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TranslationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AppInitializer(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/translator': (context) => const TranslatorScreen(),
              '/word-of-day': (context) => const WordOfDayScreen(),
            },
          );
        },
      ),
    );
  }
}

// Widget to check if user is registered and route accordingly
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkRegistration();
  }

  Future<void> _checkRegistration() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Splash delay

    final userProvider = context.read<UserProvider>();
    await userProvider.initialize();

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accentLight, AppColors.primaryLight],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, size: 100, color: Colors.white),
                SizedBox(height: 24),
                Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 48),
                CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
      );
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isRegistered) {
          return const HomeScreen();
        } else {
          return const OnboardingScreen();
        }
      },
    );
  }
}
