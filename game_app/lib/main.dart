import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Truth or Dare',
      theme: ThemeData(
        fontFamily: GoogleFonts.baloo2().fontFamily, // Set Baloo 2 as default
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.baloo2( // Use Baloo 2 for AppBar
            fontSize: 30, // Slightly larger AppBar title
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color:
                    Colors.black.withAlpha((0.5 * 255).round()), // 0.5 opacity
                offset: const Offset(1.0, 1.0),
              ),
            ],
          ),
          toolbarHeight: 80, // Increase AppBar height to bring title lower
          titleSpacing: 0, // Optional: adjust horizontal position if needed
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  // static const double wideLayoutThreshold = 600.0; // Removed threshold

  @override
  Widget build(BuildContext context) {
    // final ColorScheme colorScheme = Theme.of(context).colorScheme; // Removed unused variable
    final Color shadowColor =
        Colors.black.withAlpha((0.3 * 255).round()); // 0.3 opacity
    // Get screen dimensions for relative sizing
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Truth or Dare'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      // Use MediaQuery directly instead of LayoutBuilder for screen size
      body: Container(
        // Moved Container outside LayoutBuilder
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 252, 118, 84),
              const Color.fromARGB(255, 245, 64, 100),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
                maxWidth: 800), // Keep max width constraint
            child: LayoutBuilder(
              // Keep LayoutBuilder if needed for constraints later, but sizing is now based on MediaQuery
              builder: (context, constraints) {
                // Use screen dimensions for relative sizing
                final double horizontalPadding = screenWidth * 0.12;
                final double buttonWidth = screenWidth * 0.75;
                // Use screen height for vertical spacing
                final double verticalSpacing = screenHeight * 0.05;
                // Keep button padding fixed or make slightly relative if needed
                final double buttonVerticalPadding = 30.0;
                final double iconSize = 50.0; // Keep fixed for now
                final double fontSize = 25.0; // Keep fixed for now
                final double iconWidgetSize =
                    screenHeight * 0.08; // Relative to height
                final double spacingAfterIcon =
                    screenHeight * 0.06; // Relative to height
                final double minButtonHeight =
                    screenHeight * 0.07; // Relative to height
                // Adjust top spacing relative to screen height, considering AppBar
                final double topSpacing = screenHeight * 0.18;

                Widget buildStyledButton(
                    String text, IconData iconData, VoidCallback onPressed) {
                  final bool isStartGame = (text == 'Start Game');
                  final Color bgColor =
                      isStartGame ? Colors.white : Colors.black;
                  final Color fgColor =
                      isStartGame ? Colors.black : Colors.white;

                  final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
                    backgroundColor: bgColor,
                    foregroundColor: fgColor,
                    padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: buttonVerticalPadding), // Use updated padding
                    textStyle: GoogleFonts.baloo2( // Use Baloo 2 for buttons
                      fontSize: fontSize, // Use updated font size
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 3,
                    shadowColor: Colors.transparent,
                    minimumSize: Size(buttonWidth,
                        minButtonHeight), // Use updated width and min height
                    alignment: Alignment.center,
                  );

                  return Container(
                    width: buttonWidth, // Use updated width
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
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
                              child: Icon(iconData,
                                  size: iconSize), // Use updated icon size
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

                return Padding(
                  // Moved Padding inside LayoutBuilder
                  padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding), // Use updated padding
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: topSpacing), // Use relative top spacing
                      Icon(
                        Icons.sentiment_satisfied_alt,
                        size: iconWidgetSize, // Use updated size
                        color: Colors.white.withAlpha((0.9 * 255).round()),
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withAlpha((0.4 * 255).round()),
                            offset: const Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      SizedBox(height: spacingAfterIcon), // Use updated spacing

                      buildStyledButton('Start Game', Icons.play_arrow, () {
                        print("Start Game pressed");
                      }),
                      SizedBox(height: verticalSpacing), // Use updated spacing
                      buildStyledButton('Add Truths', Icons.add, () {
                        print("Add Truths pressed");
                      }),
                      SizedBox(height: verticalSpacing), // Use updated spacing
                      buildStyledButton('Add Dares', Icons.add, () {
                        print("Add Dares pressed");
                      }),
                      const Spacer(), // Pushes the following Row to the bottom
                      Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.03), // Add padding below the buttons
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            _buildBottomBarButton(Icons.star, () { // Changed from star_border to star
                              print("Ratings pressed");
                            }),
                            _buildBottomBarButton(Icons.share, () {
                              print("Share pressed");
                            }),
                            _buildBottomBarButton(Icons.settings, () {
                              print("Settings pressed");
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for bottom bar buttons to keep build method cleaner
  Widget _buildBottomBarButton(IconData icon, VoidCallback onPressed) {
    // Apply styling exactly like the 'Start Game' button
    final Color shadowColor =
        Colors.black.withAlpha((0.3 * 255).round()); // Consistent shadow

    return Container(
      decoration: BoxDecoration(
        // Keep the shadow separate as ElevatedButton shadow might clip
        borderRadius: BorderRadius.circular(8),
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
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // White background like Start Game
          foregroundColor: Colors.black, // Black icon color like Start Game text
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Rounded corners like Start Game
          ),
          padding: const EdgeInsets.all(15), // Adjust padding for icon size
          elevation: 0, // Elevation handled by Container shadow
          shadowColor: Colors.transparent, // Shadow handled by Container
          minimumSize: const Size(60, 60), // Ensure a decent tap target size
        ),
        onPressed: onPressed,
        child: Icon(
          icon,
          color: Colors.black, // Explicitly black icon
          size: 30.0, // Adjust size as needed
        ),
      ),
    );

    /* Previous implementation:
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle, // Make it circular
        color: Colors.white.withOpacity(0.15), // Subtle background like other buttons
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8.0,
            spreadRadius: 1.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Use container color
          foregroundColor: iconColor, // Color for splash/feedback
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(12), // Adjust padding for icon size
          elevation: 0, // Elevation handled by Container shadow
          shadowColor: Colors.transparent,
        ),
        onPressed: onPressed,
        child: Icon(
          icon,
          color: iconColor,
          size: 30.0, // Adjust size as needed
          // Shadows applied via Container
        ),
      ),
    );
    */
  }
}
