import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgeGroupScreen extends StatelessWidget {
  final String selectedGameMode;

  const AgeGroupScreen({super.key, required this.selectedGameMode});

  // Helper function to build styled buttons (similar to main.dart)
  Widget _buildStyledButton(BuildContext context, String text,
      IconData iconData, VoidCallback onPressed) {
    final Color shadowColor = Colors.black.withAlpha((0.3 * 255).round());
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double buttonWidth =
        screenWidth * 0.75; // Match main screen button width
    final double buttonVerticalPadding =
        30.0; // Match main screen button padding
    final double fontSize = 25.0; // Match main screen font size
    final double iconSize = 40.0; // Match main screen icon size
    final double minButtonHeight =
        screenSize.height * 0.07; // Match main screen min height

    // Style similar to 'Add Truths'/'Add Dares' (black background, white text/icon)
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.black, // Black background
      foregroundColor: Colors.white, // White text/icon
      padding:
          EdgeInsets.symmetric(horizontal: 20, vertical: buttonVerticalPadding),
      textStyle: GoogleFonts.baloo2(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      shadowColor: Colors.transparent, // Shadow handled by Container
      minimumSize: Size(buttonWidth, minButtonHeight),
      alignment: Alignment.center,
    );

    return Container(
      width: buttonWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10.0,
            spreadRadius: 1.0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: onPressed,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Icon(iconData, size: iconSize),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(text),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double verticalSpacing = screenHeight * 0.05; // Consistent spacing
    final double topSpacing = screenHeight * 0.18; // Consistent top spacing

    return Scaffold(
      appBar: AppBar(
        // Use the same title text as the home screen
        title: const Text('Truth or Dare'),
        // Styling (font, size, color, shadow, height, background) is inherited from the global AppBarTheme in main.dart
        centerTitle: true,
        // elevation: 0, // Inherited from theme
        // backgroundColor: Colors.transparent, // Inherited from theme
        // iconTheme: const IconThemeData(color: Colors.white), // Inherited from theme
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity, // Ensure container fills width
        height: double.infinity, // Ensure container fills height
        decoration: const BoxDecoration(
          // Change gradient to rich green colors
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 48, 193, 115), // Darker Green
              Color.fromARGB(255, 32, 167, 93), // Lighter Vibrant Green
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          // Center the column
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.12), // Consistent padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // Adjust top spacing to account for the taller AppBar from the theme
                SizedBox(height: topSpacing + 100), // Added AppBar height (100)

                _buildStyledButton(context, 'KIDS', Icons.child_care, () {
                  print(
                      "Selected Age Group: KIDS, Game Mode: $selectedGameMode");
                  // TODO: Navigate to the actual game screen with mode and age group
                }),
                SizedBox(height: verticalSpacing),
                _buildStyledButton(context, 'TEEN', Icons.school, () {
                  print(
                      "Selected Age Group: TEEN, Game Mode: $selectedGameMode");
                  // TODO: Navigate to the actual game screen with mode and age group
                }),
                SizedBox(height: verticalSpacing),
                _buildStyledButton(context, 'ADULT', Icons.person, () {
                  print(
                      "Selected Age Group: ADULT, Game Mode: $selectedGameMode");
                  // TODO: Navigate to the actual game screen with mode and age group
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
