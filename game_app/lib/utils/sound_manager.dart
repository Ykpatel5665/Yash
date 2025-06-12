import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play(String asset) async {
    await _player.stop();
    await _player.play(AssetSource(asset));
  }

  static Future<void> playBottleSound() => play('bottlesound.mp3');
  static Future<void> playButtonSound() => play('buttonsound.mp3');
  static Future<void> playCompletedSound() => play('completed.ogg');
  static Future<void> playForfeitSound() => play('forfeit.mp3');
}
