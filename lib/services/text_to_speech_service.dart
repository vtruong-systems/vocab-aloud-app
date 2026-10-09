import 'package:flutter_tts/flutter_tts.dart';

import '../models/app_settings.dart';

class TextToSpeechService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  int _speechGeneration = 0;

  Future<void> initialize() async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.45);
    _initialized = true;
  }

  Future<void> speak(String text) async {
    await initialize();
    final generation = ++_speechGeneration;
    await _tts.stop();
    if (generation != _speechGeneration) return;
    await _tts.speak(text);
  }

  /// Speaks each part in order. A later [speak], [speakSequence], or [stop]
  /// cancels the rest of the sequence.
  Future<void> speakSequence(List<String> parts) async {
    await initialize();
    final generation = ++_speechGeneration;
    await _tts.awaitSpeakCompletion(true);
    await _tts.stop();
    for (final part in parts) {
      if (generation != _speechGeneration) return;
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      await _tts.speak(trimmed);
    }
  }

  Future<void> stop() async {
    _speechGeneration++;
    if (_initialized) await _tts.stop();
  }

  Future<void> applySpeechSpeed(SpeechSpeed speed) async {
    await initialize();
    final rate = switch (speed) {
      SpeechSpeed.slow => 0.35,
      SpeechSpeed.normal => 0.45,
      SpeechSpeed.fast => 0.55,
    };
    await _tts.setSpeechRate(rate);
  }
}
