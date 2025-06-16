import 'package:flutter/material.dart';

class SoundProvider extends ChangeNotifier {
  bool _isSoundOn = true; // Sound is ON by default

  bool get isSoundOn => _isSoundOn;

  void toggleSound() {
    _isSoundOn = !_isSoundOn;
    notifyListeners();
  }

  void setSound(bool value) {
    if (_isSoundOn != value) {
      _isSoundOn = value;
      notifyListeners();
    }
  }
}
