import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/question.dart';

class StorageService {
  static const String _userProfileKey = 'user_profile';
  static const String _quizProgressKey = 'quiz_progress';
  static const String _isRegisteredKey = 'is_registered';
  static const String _lastNotificationKey = 'last_notification_date';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // User Profile Methods
  Future<bool> saveUserProfile(UserProfile profile) async {
    final jsonString = jsonEncode(profile.toJson());
    await _prefs.setBool(_isRegisteredKey, true);
    return await _prefs.setString(_userProfileKey, jsonString);
  }

  UserProfile? getUserProfile() {
    final jsonString = _prefs.getString(_userProfileKey);
    if (jsonString == null) return null;
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return UserProfile.fromJson(jsonMap);
  }

  bool isRegistered() {
    return _prefs.getBool(_isRegisteredKey) ?? false;
  }

  // Quiz Progress Methods
  Future<bool> saveQuizProgress(String levelId, QuizProgress progress) async {
    final allProgress = getAllQuizProgress();
    allProgress[levelId] = progress;
    final jsonString = jsonEncode(
      allProgress.map((key, value) => MapEntry(key, value.toJson())),
    );
    return await _prefs.setString(_quizProgressKey, jsonString);
  }

  Map<String, QuizProgress> getAllQuizProgress() {
    final jsonString = _prefs.getString(_quizProgressKey);
    if (jsonString == null) return {};

    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return jsonMap.map(
      (key, value) =>
          MapEntry(key, QuizProgress.fromJson(value as Map<String, dynamic>)),
    );
  }

  QuizProgress? getQuizProgress(String levelId) {
    final allProgress = getAllQuizProgress();
    return allProgress[levelId];
  }

  // Notification Methods
  Future<bool> setNotificationsEnabled(bool enabled) async {
    return await _prefs.setBool(_notificationsEnabledKey, enabled);
  }

  bool getNotificationsEnabled() {
    return _prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<bool> setLastNotificationDate(DateTime date) async {
    return await _prefs.setString(_lastNotificationKey, date.toIso8601String());
  }

  DateTime? getLastNotificationDate() {
    final dateString = _prefs.getString(_lastNotificationKey);
    if (dateString == null) return null;
    return DateTime.parse(dateString);
  }

  // Clear all data
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }

  // Update quiz completion count
  Future<bool> incrementQuizCompletion() async {
    final profile = getUserProfile();
    if (profile == null) return false;

    final updatedProfile = profile.copyWith(
      totalQuizCompleted: profile.totalQuizCompleted + 1,
    );
    return await saveUserProfile(updatedProfile);
  }
}
