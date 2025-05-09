import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'truth_dare_data.dart';

class TruthDareQuestionScreen extends StatelessWidget {
  final String playerName;
  final String questionText;
  final bool isTruth;
  final VoidCallback onDone;
  final VoidCallback onForfeit;

  const TruthDareQuestionScreen({
    super.key,
    required this.playerName,
    required this.questionText,
    required this.isTruth,
    required this.onDone,
    required this.onForfeit,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double height = screenSize.height;
    final double fontSize = (width * 0.045).clamp(14, 28);
    final double questionFontSize = (width * 0.055).clamp(16, 32);
    final double headerFontSize = (width * 0.09).clamp(24, 44);
    final double buttonFontSize = (width * 0.058).clamp(18, 36); // Increased font size
    final double iconSize = (width * 0.18).clamp(48, 120);
    final double buttonIconSize = (buttonFontSize * 1.28).clamp(24, 48); // Increased icon size
    final double horizontalPadding = (width * 0.045).clamp(10, 28);
    final double buttonVerticalPadding = (height * 0.032).clamp(18, 44); // Increased vertical padding
    final double buttonSpacing = (width * 0.045).clamp(10, 28);
    final double headerTopPadding = (height * 0.02).clamp(10, 32);
    final double headerSidePadding = (width * 0.02).clamp(6, 18);
    final double rowBottomPadding = (height * 0.08).clamp(32, 90);
    final double betweenHeaderAndIcon = (height * 0.02).clamp(8, 28);
    final double betweenIconAndQuestion = (height * 0.01).clamp(4, 18);
    final double betweenQuestionAndButtons = (height * 0.01).clamp(8, 24);
    final double afterButtons = (height * 0.01).clamp(8, 24);

    // Vibrant color pairs for gradients
    final List<List<Color>> colorCombos = [
      [Color.fromARGB(255, 100, 230, 200), Color.fromARGB(255, 80, 130, 255)], // Mint to blue
      [Color(0xFF4DD0E1), Color(0xFF1976D2)], // Cyan to blue
      [Color(0xFFFF5F6D), Color(0xFFFFC371)], // Pink to yellow
      [Color(0xFF8F6ED5), Color(0xFF5B86E5)], // Purple to blue
      [Color(0xFF43E97B), Color(0xFF38F9D7)], // Green to teal
      [Color(0xFFFA8BFF), Color(0xFF2BD2FF)], // Pink to blue
      [Color(0xFFFFD700), Color(0xFFFF5F6D)], // Gold to pink
    ];
    // Pick a random combo for each screen
    final combo = (colorCombos..shuffle()).first;
    final Color mainColor = combo[0];
    final Color secondaryColor = combo[1];
    final IconData mainIcon = isTruth ? Icons.lightbulb_rounded : Icons.whatshot_rounded;
    final Color iconColor = isTruth ? mainColor : secondaryColor;
    final Color bgColor = mainColor.withOpacity(0.18);

    // Gradient for Done button
    final BoxDecoration doneButtonDecoration = BoxDecoration(
      gradient: LinearGradient(
        colors: [mainColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.18),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ],
    );

    final ButtonStyle doneButtonStyle = ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 26), // Increased height
      textStyle: GoogleFonts.baloo2(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
    );

    final TextStyle doneButtonTextStyle = GoogleFonts.baloo2(
      fontWeight: FontWeight.bold,
      fontSize: buttonFontSize,
      color: Colors.white,
      shadows: [
        Shadow(
          blurRadius: 8,
          color: Colors.black.withOpacity(0.25),
          offset: const Offset(0, 2),
        ),
      ],
    );

    final ButtonStyle forfeitButtonStyle = ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: Colors.black.withOpacity(0.85),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 26), // Increased height
      textStyle: GoogleFonts.baloo2(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
    );

    final TextStyle forfeitButtonTextStyle = GoogleFonts.baloo2(
      fontWeight: FontWeight.bold,
      fontSize: buttonFontSize,
      color: Colors.white,
      shadows: [
        Shadow(
          blurRadius: 8,
          color: Colors.black.withOpacity(0.25),
          offset: const Offset(0, 2),
        ),
      ],
    );

    return Stack(
      children: [
        // Solid background to block splash/logo
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black, // or Colors.white for a light base
        ),
        // Fully opaque vibrant gradient background
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mainColor, secondaryColor], // No opacity for vibrancy
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Blurred overlay (keep subtle, not hiding gradient)
        Container(
          width: double.infinity,
          height: double.infinity,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              color: Colors.black.withOpacity(0.08), // Lower opacity for vibrancy
            ),
          ),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: headerTopPadding,
                  left: headerSidePadding,
                  right: headerSidePadding,
                  bottom: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.3), offset: Offset(3, 3), blurRadius: 6),
                          BoxShadow(color: Colors.white.withOpacity(0.4), offset: Offset(-3, -3), blurRadius: 6),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close_rounded, color: Colors.black, size: buttonIconSize),
                        tooltip: 'Forfeit',
                        onPressed: onForfeit,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        isTruth ? "It's a Truth!" : "It's a Dare!",
                        style: GoogleFonts.baloo2(
                          fontSize: headerFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: buttonIconSize + 20),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: betweenHeaderAndIcon, bottom: betweenIconAndQuestion),
                child: Icon(
                  mainIcon,
                  color: iconColor,
                  size: iconSize,
                  shadows: [
                    Shadow(
                      blurRadius: 8.0,
                      color: Colors.black.withAlpha((0.4 * 255).round()),
                      offset: const Offset(1.0, 1.0),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$playerName, your task:",
                          style: GoogleFonts.baloo2(
                            fontSize: fontSize,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 2 * betweenHeaderAndIcon),
                        Text(
                          questionText,
                          style: GoogleFonts.baloo2(
                            fontSize: questionFontSize * 1.25, // Increased size for the question only
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, rowBottomPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onForfeit,
                        style: forfeitButtonStyle.copyWith(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(vertical: buttonVerticalPadding / 2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min, // Use min to center content tightly
                          children: [
                            Icon(
                              Icons.flag_rounded,
                              color: Colors.white,
                              size: buttonIconSize,
                            ),
                            SizedBox(width: buttonSpacing / 2),
                            Text(
                              'Forfeit',
                              style: forfeitButtonTextStyle.copyWith(fontSize: buttonFontSize),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: buttonSpacing),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onDone,
                        style: forfeitButtonStyle.copyWith(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(vertical: buttonVerticalPadding / 2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min, // Use min to center content tightly
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: buttonIconSize,
                            ),
                            SizedBox(width: buttonSpacing / 2),
                            Text(
                              'Done',
                              style: forfeitButtonTextStyle.copyWith(fontSize: buttonFontSize),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: afterButtons),
              // Placeholder for smart ad banner
              // SmartBannerMobile(),
            ],
          ),
        ),
      ],
    );
  }
}
