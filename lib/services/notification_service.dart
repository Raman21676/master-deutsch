import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'word_service.dart';

// Background task callback
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Get today's word
      final wordService = WordService();
      await wordService.initialize();
      final word = wordService.getTodaysWord();

      if (word != null) {
        // Show notification
        final FlutterLocalNotificationsPlugin notifications =
            FlutterLocalNotificationsPlugin();

        const AndroidInitializationSettings androidSettings =
            AndroidInitializationSettings('@mipmap/ic_launcher');

        const DarwinInitializationSettings iosSettings =
            DarwinInitializationSettings();

        const InitializationSettings settings = InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        );

        await notifications.initialize(settings);

        const AndroidNotificationDetails androidDetails =
            AndroidNotificationDetails(
              'word_of_day',
              'Word of the Day',
              channelDescription: 'Daily German vocabulary word',
              importance: Importance.high,
              priority: Priority.high,
            );

        const DarwinNotificationDetails iosDetails =
            DarwinNotificationDetails();

        const NotificationDetails notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

        await notifications.show(
          0,
          'Word of the Day: ${word.germanWord}',
          '${word.englishMeaning}\\nExample: ${word.exampleSentenceGerman}',
          notificationDetails,
        );
      }

      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // Initialize WorkManager
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

    _isInitialized = true;
  }

  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> checkPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  Future<void> scheduleDailyWordNotification() async {
    // Cancel any existing tasks
    await Workmanager().cancelByUniqueName('daily_word_notification');

    // Schedule daily notification at 9:00 AM
    await Workmanager().registerPeriodicTask(
      'daily_word_notification',
      'showDailyWord',
      frequency: const Duration(hours: 24),
      initialDelay: _getDelayUntil9AM(),
      constraints: Constraints(networkType: NetworkType.not_required),
    );
  }

  Duration _getDelayUntil9AM() {
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(now.year, now.month, now.day, 9, 0);

    // If it's already past 9 AM today, schedule for 9 AM tomorrow
    if (now.isAfter(scheduledTime)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    return scheduledTime.difference(now);
  }

  Future<void> cancelDailyWordNotification() async {
    await Workmanager().cancelByUniqueName('daily_word_notification');
  }

  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Test notification channel',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999,
      'Master Deutsch Test',
      'Notifications are working correctly!',
      notificationDetails,
    );
  }

  Future<void> showWordOfDayNow() async {
    final wordService = WordService();
    await wordService.initialize();
    final word = wordService.getTodaysWord();

    if (word == null) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'word_of_day',
          'Word of the Day',
          channelDescription: 'Daily German vocabulary word',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      'Word of the Day: ${word.germanWord}',
      '${word.englishMeaning}\nExample: ${word.exampleSentenceGerman}',
      notificationDetails,
    );
  }
}
