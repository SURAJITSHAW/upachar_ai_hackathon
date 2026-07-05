import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../l10n/app_strings.dart';

/// Wraps flutter_tts; [available] is false if the engine fails to
/// initialize, so the UI can hide the play button gracefully.
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool available = true;

  final ValueNotifier<bool> speaking = ValueNotifier(false);

  Future<void> _init(AppLanguage language) async {
    try {
      final locale = switch (language) {
        AppLanguage.bengali => 'bn-IN',
        AppLanguage.hindi => 'hi-IN',
        AppLanguage.english => 'en-IN',
      };
      final langAvailable = await _tts.isLanguageAvailable(locale);
      await _tts.setLanguage(langAvailable == true ? locale : 'en-US');
      await _tts.setSpeechRate(0.45);
      _tts.setCompletionHandler(() => speaking.value = false);
      _tts.setCancelHandler(() => speaking.value = false);
      _initialized = true;
    } catch (_) {
      available = false;
    }
  }

  Future<void> speak(String text, AppLanguage language) async {
    if (!available) return;
    if (!_initialized) await _init(language);
    if (!available) return;
    try {
      speaking.value = true;
      await _tts.speak(text);
    } catch (_) {
      speaking.value = false;
      available = false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    speaking.value = false;
  }
}
