/// ============================================================
/// VOICE INPUT — speech-to-text for search (Bangla and English)
/// ============================================================
///
/// Thin wrapper over speech_to_text: picks a recognizer locale that matches
/// the app language (bn-BD / bn-IN, else en), streams partial words, and
/// reports why it can't listen (no permission / no recognizer) so the UI can
/// say so plainly. Mic permission is requested on first use only.
/// ============================================================
library;

import 'dart:async';

import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:homio_essentials/core/utils/app_logger.dart';

enum VoiceStatus { idle, starting, listening, done, unavailable, denied, error }

class VoiceInput {
  final SpeechToText _stt = SpeechToText();
  bool? _ready;
  String? _deniedOrError;

  Future<bool> _init() async {
    if (_ready == true) return true;
    try {
      _ready = await _stt.initialize(
        onError: (e) { _deniedOrError = e.errorMsg; AppLogger.d('voice error: ${e.errorMsg}'); },
        onStatus: (s) => AppLogger.d('voice status: $s'),
      );
    } catch (e) {
      AppLogger.d('voice init failed: $e');
      _ready = false;
    }
    return _ready!;
  }

  Future<String?> _localeFor(String appLanguage) async {
    try {
      final locales = await _stt.locales();
      String? pick(String lang) => locales.where((l) => l.localeId.toLowerCase().replaceAll('_', '-').startsWith(lang)).map((l) => l.localeId).firstOrNull;
      return appLanguage == 'bn' ? (pick('bn-bd') ?? pick('bn') ?? pick('en')) : (pick('en-us') ?? pick('en'));
    } catch (_) {
      return null;
    }
  }

  /// Starts listening; [onWords] gets partial and final text, [onStopped] fires
  /// when the recognizer stops on its own (silence / time limit). Returns the status to show.
  Future<VoiceStatus> listen({required String appLanguage, required void Function(String words, bool isFinal) onWords, VoidCallback? onStopped}) async {
    _deniedOrError = null;
    if (!await _init()) {
      return (_deniedOrError ?? '').contains('permission') ? VoiceStatus.denied : VoiceStatus.unavailable;
    }
    if (!await _stt.hasPermission) return VoiceStatus.denied;
    _stt.statusListener = (s) {
      if (s == SpeechToText.doneStatus || s == SpeechToText.notListeningStatus) onStopped?.call();
    };
    await _stt.listen(
      listenOptions: SpeechListenOptions(
        localeId: await _localeFor(appLanguage),
        listenFor: const Duration(seconds: 20),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.search,
      ),
      onResult: (SpeechRecognitionResult r) => onWords(r.recognizedWords, r.finalResult),
    );
    return VoiceStatus.listening;
  }

  bool get isListening => _stt.isListening;

  Future<void> stop() => _stt.stop();
  Future<void> cancel() => _stt.cancel();
}

final voiceInputProvider = Provider<VoiceInput>((ref) {
  final v = VoiceInput();
  ref.onDispose(v.cancel);
  return v;
});
