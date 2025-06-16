import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/sound_provider.dart';

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play(String asset, {BuildContext? context}) async {
    bool isSoundOn = true;
    if (context != null) {
      try {
        isSoundOn = Provider.of<SoundProvider>(context, listen: false).isSoundOn;
      } catch (_) {}
    }
    if (!isSoundOn) return;
    await _player.stop();
    await _player.play(AssetSource(asset));
  }

  static Future<void> playBottleSound({BuildContext? context}) => play('bottlesound.mp3', context: context);
  static Future<void> playButtonSound({BuildContext? context}) => play('buttonsound.mp3', context: context);
  static Future<void> playCompletedSound({BuildContext? context}) => play('completed.ogg', context: context);
  static Future<void> playForfeitSound({BuildContext? context}) => play('forfeit.mp3', context: context);
}
