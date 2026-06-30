import 'package:audioplayers/audioplayers.dart';

class SoundEffectsService {
  final AudioPlayer _player = AudioPlayer();
  static const _volume = 0.55;

  Future<void> playCorrect() async {
    await _play('sounds/correct.mp3');
  }

  Future<void> playIncorrect() async {
    await _play('sounds/incorrect.mp3');
  }

  Future<void> _play(String asset) async {
    await _player.stop();
    await _player.setVolume(_volume);
    await _player.play(AssetSource(asset));
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
