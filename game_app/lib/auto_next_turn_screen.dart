import 'package:flutter/material.dart';

class AutoNextTurnScreen extends StatelessWidget {
  final List<String> players;
  final List<Color> playerColors;
  final dynamic ageGroup;
  const AutoNextTurnScreen({super.key, required this.players, required this.playerColors, required this.ageGroup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto Next Turn')),
      body: Center(child: Text('Auto Next Turn Screen')),
    );
  }
}
