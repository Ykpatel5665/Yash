import 'package:flutter/material.dart';
import 'main.dart'; // For AgeGroup enum
import 'player_circle_painter.dart'; // Import the new painter widget

class RandomTurnScreen extends StatelessWidget {
  final List<String> players;
  final AgeGroup ageGroup;

  const RandomTurnScreen({
    super.key,
    required this.players,
    required this.ageGroup,
  });

  @override
  Widget build(BuildContext context) {
    // Use the same AppBar style from MyApp theme
    final AppBarTheme appBarTheme = Theme.of(context).appBarTheme;
    // Define neumorphic colors
    const Color baseColor = Color.fromARGB(255, 255, 255, 255);
    final Color shadowDark = Colors.black.withOpacity(0.3);
    final Color shadowLight = Colors.white.withOpacity(0.4);

    // Define the background gradient (matching main.dart)
    const LinearGradient backgroundGradient = LinearGradient(
      colors: [
        Color.fromARGB(255, 252, 118, 84), // Main screen color 1
        Color.fromARGB(255, 245, 64, 100), // Main screen color 2
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove default back button
        leading: Padding(
          padding: const EdgeInsets.only(
              left: 5.0, top: 15, bottom: 15), // Match padding
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40, // Match size
              height: 40, // Match size
              decoration: BoxDecoration(
                color: baseColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: shadowDark,
                    offset: const Offset(3, 3),
                    blurRadius: 6,
                  ),
                  BoxShadow(
                    color: shadowLight,
                    offset: const Offset(-3, -3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color.fromARGB(255, 0, 0, 0),
                size: 20,
              ),
            ),
          ),
        ),
        title: Text(
          'Random Turn', // Updated title
          style: appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: appBarTheme.toolbarHeight,
        titleSpacing: appBarTheme.titleSpacing,
      ),
      extendBodyBehindAppBar: true, // Extend body behind AppBar
      body: Column(
        children: [
          Expanded(
            child: Container(
              // Wrap body content in Container for gradient
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: backgroundGradient,
              ),
              child: SafeArea(
                // Use SafeArea
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Display the Player Circle
                      PlayerCircle(
                        players: players,
                        size: MediaQuery.of(context).size.width *
                            0.8, // Adjust size as needed
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
