import 'package:flutter/material.dart';

class RandomTurnScreen extends StatelessWidget {
  final List<String> players;
  final List<Color> playerColors;
  final dynamic ageGroup;
  const RandomTurnScreen({super.key, required this.players, required this.playerColors, required this.ageGroup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Random Turn')),
      body: Center(child: Text('Random Turn Screen')),
    );
  }
}
