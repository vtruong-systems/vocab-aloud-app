import 'package:flutter_tts/flutter_tts.dart';

import '../models/app_settings.dart';

class TextToSpeechService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.45);
    _initialized = true;
  }

  Future<void> speak(String text) async {
    await initialize();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
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
