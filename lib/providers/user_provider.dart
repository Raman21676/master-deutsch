import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _userProfile;
  StorageService? _storageService;
  bool _isInitialized = false;

  UserProfile? get userProfile => _userProfile;
  bool get isRegistered => _userProfile != null;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _storageService = await StorageService.create();
    _userProfile = _storageService!.getUserProfile();
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> registerUser(UserProfile profile) async {
    if (_storageService == null) {
      await initialize();
    }

    final success = await _storageService!.saveUserProfile(profile);
    if (success) {
      _userProfile = profile;
      notifyListeners();
    }
    return success;
  }

  Future<bool> updateProfile(UserProfile profile) async {
    if (_storageService == null) return false;

    final success = await _storageService!.saveUserProfile(profile);
    if (success) {
      _userProfile = profile;
      notifyListeners();
    }
    return success;
  }

  Future<void> incrementQuizCompletion() async {
    if (_storageService == null || _userProfile == null) return;

    await _storageService!.incrementQuizCompletion();
    _userProfile = _storageService!.getUserProfile();
    notifyListeners();
  }

  Future<void> logout() async {
    if (_storageService == null) return;

    await _storageService!.clearAll();
    _userProfile = null;
    notifyListeners();
  }
}
