import 'package:flutter/material.dart';
import '../services/translation_service.dart';

class TranslationProvider with ChangeNotifier {
  final TranslationService _translationService = TranslationService();

  String _inputText = '';
  String _outputText = '';
  bool _isTranslating = false;
  bool _isEnglishToGerman = true;

  String get inputText => _inputText;
  String get outputText => _outputText;
  bool get isTranslating => _isTranslating;
  bool get isEnglishToGerman => _isEnglishToGerman;
  bool get isModelDownloaded => _translationService.isModelDownloaded;
  bool get isDownloading => _translationService.isDownloading;

  Future<void> initialize() async {
    await _translationService.initialize();
    notifyListeners();
  }

  Future<bool> downloadModel({required Function(double) onProgress}) async {
    final success = await _translationService.downloadModel(
      onProgress: onProgress,
    );
    notifyListeners();
    return success;
  }

  void setInputText(String text) {
    _inputText = text;
    notifyListeners();
  }

  void swapLanguages() {
    _isEnglishToGerman = !_isEnglishToGerman;
    final temp = _inputText;
    _inputText = _outputText;
    _outputText = temp;
    notifyListeners();
  }

  Future<void> translate() async {
    if (_inputText.trim().isEmpty) {
      _outputText = '';
      notifyListeners();
      return;
    }

    _isTranslating = true;
    notifyListeners();

    try {
      final result = _isEnglishToGerman
          ? await _translationService.translateToGerman(_inputText)
          : await _translationService.translateToEnglish(_inputText);

      _outputText = result ?? 'Translation failed';
    } catch (e) {
      _outputText = 'Error: ${e.toString()}';
    }

    _isTranslating = false;
    notifyListeners();
  }

  void clearTexts() {
    _inputText = '';
    _outputText = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _translationService.dispose();
    super.dispose();
  }
}
