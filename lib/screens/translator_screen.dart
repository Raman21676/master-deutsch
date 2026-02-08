import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../utils/constants.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TranslationProvider>();
      provider.initialize();

      // Check if model needs to be downloaded
      if (!provider.isModelDownloaded) {
        _showDownloadDialog();
      }
    });
  }

  Future<void> _showDownloadDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Download Translation Model'),
        content: const Text(
          'To use offline translation, you need to download the German language model (~30MB). This is a one-time download.\\n\\nWould you like to download it now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Download'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      _downloadModel();
    }
  }

  Future<void> _downloadModel() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Downloading Model'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Please wait while we download the translation model...'),
          ],
        ),
      ),
    );

    final provider = context.read<TranslationProvider>();
    final success = await provider.downloadModel(onProgress: (progress) {});

    if (mounted) {
      Navigator.pop(context); // Close loading dialog

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Model downloaded successfully! You can now translate offline.',
            ),
            backgroundColor: AppColors.correct,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download model. Please try again.'),
            backgroundColor: AppColors.wrong,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Translator'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<TranslationProvider>(
        builder: (context, provider, child) {
          if (!provider.isModelDownloaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.download_outlined,
                    size: 80,
                    color: AppColors.accentLight,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Translation Model Not Downloaded',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _downloadModel,
                    icon: const Icon(Icons.download),
                    label: const Text('Download Model (30MB)'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Language Direction Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          provider.isEnglishToGerman ? 'English' : 'Deutsch',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: provider.swapLanguages,
                          icon: const Icon(Icons.swap_horiz),
                          color: AppColors.accentLight,
                          iconSize: 32,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          provider.isEnglishToGerman ? 'Deutsch' : 'English',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Input Field
                TextField(
                  controller: _inputController,
                  decoration: InputDecoration(
                    labelText: provider.isEnglishToGerman
                        ? 'Enter English text'
                        : 'Enter German text',
                    hintText: 'Type here...',
                    suffixIcon: _inputController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _inputController.clear();
                              provider.clearTexts();
                            },
                          )
                        : null,
                  ),
                  maxLines: 5,
                  onChanged: provider.setInputText,
                ),

                const SizedBox(height: 24),

                // Translate Button
                ElevatedButton.icon(
                  onPressed: provider.isTranslating
                      ? null
                      : () => provider.translate(),
                  icon: provider.isTranslating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.translate),
                  label: Text(
                    provider.isTranslating ? 'Translating...' : 'Translate',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 24),

                // Output Card
                if (provider.outputText.isNotEmpty)
                  Card(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Translation',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: provider.outputText),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Copied to clipboard'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                iconSize: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.outputText,
                            style: const TextStyle(fontSize: 18, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Offline Indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.correct.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.offline_bolt,
                        color: AppColors.correct,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '100% Offline Translation',
                        style: TextStyle(
                          color: AppColors.correct,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
