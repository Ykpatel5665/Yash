import 'package:flutter/material.dart';

class TruthDareSelectScreen extends StatelessWidget {
  final String playerName;
  const TruthDareSelectScreen({super.key, required this.playerName});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF3A3D5C),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.9,
                minHeight: size.height * 0.7,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Whoopsie!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: size.height * 0.04),
                  Icon(
                    Icons.sentiment_dissatisfied_rounded,
                    color: Colors.white70,
                    size: size.width * 0.18,
                  ),
                  SizedBox(height: size.height * 0.05),
                  Text(
                    "It's $playerName's turn",
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Add more widgets here as needed
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
