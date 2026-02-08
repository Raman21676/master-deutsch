import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  OnDeviceTranslator? _translator;
  bool _isModelDownloaded = false;
  bool _isDownloading = false;

  bool get isModelDownloaded => _isModelDownloaded;
  bool get isDownloading => _isDownloading;

  Future<void> initialize() async {
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      _isModelDownloaded = await modelManager.isModelDownloaded(
        TranslateLanguage.german.bcpCode,
      );
    } catch (e) {
      _isModelDownloaded = false;
    }
  }

  Future<bool> downloadModel({required Function(double) onProgress}) async {
    try {
      _isDownloading = true;
      final modelManager = OnDeviceTranslatorModelManager();

      // Download German language model
      final success = await modelManager.downloadModel(
        TranslateLanguage.german.bcpCode,
      );

      if (success) {
        _isModelDownloaded = true;
        _isDownloading = false;
        return true;
      }

      _isDownloading = false;
      return false;
    } catch (e) {
      _isDownloading = false;
      return false;
    }
  }

  Future<String?> translateToGerman(String text) async {
    if (!_isModelDownloaded) {
      return null;
    }

    try {
      _translator ??= OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: TranslateLanguage.german,
      );

      return await _translator!.translateText(text);
    } catch (e) {
      return null;
    }
  }

  Future<String?> translateToEnglish(String text) async {
    if (!_isModelDownloaded) {
      return null;
    }

    try {
      final translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.german,
        targetLanguage: TranslateLanguage.english,
      );

      final result = await translator.translateText(text);
      await translator.close();
      return result;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteModel() async {
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      await modelManager.deleteModel(TranslateLanguage.german.bcpCode);
      _isModelDownloaded = false;
      await _translator?.close();
      _translator = null;
    } catch (e) {
      // Handle error
    }
  }

  Future<void> dispose() async {
    await _translator?.close();
    _translator = null;
  }
}
