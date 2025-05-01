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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
            titleTextStyle: GoogleFonts.pacifico(
            fontSize: 30, // Slightly larger AppBar title
            color: Colors.white,
            shadows: [
              Shadow(
              blurRadius: 4.0,
              color: Colors.black.withAlpha((0.5 * 255).round()), // 0.5 opacity
              offset: const Offset(1.0, 1.0),
              ),
            ],
            ),
            toolbarHeight: 80, // Increase AppBar height to bring title lower
            titleSpacing: 0,   // Optional: adjust horizontal position if needed
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

  static const double wideLayoutThreshold = 600.0;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color shadowColor = Colors.black.withAlpha((0.3 * 255).round()); // 0.3 opacity

    return Scaffold(
      appBar: AppBar(
        title: const Text('Truth or Dare'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          final bool isWideLayout = screenWidth > wideLayoutThreshold;

          // Adjust sizes for more vertical spread and height
            final double horizontalPadding =
              screenWidth * (isWideLayout ? 0.25 : 0.12);
            final double buttonWidth = screenWidth * (isWideLayout ? 0.5 : 0.75);
            // Significantly increase vertical spacing
            final double verticalSpacing = isWideLayout ? 80.0 : 60.0;
            // Increase button vertical padding for more height
            final double buttonVerticalPadding = isWideLayout ? 36.0 : 36.0;
            final double iconSize = isWideLayout ? 28.0 : 28.0;
            final double fontSize = isWideLayout ? 22.0 : 22.0;
            final double iconWidgetSize = isWideLayout ? 70.0 : 65.0;
            // Increase spacing after the top icon
            final double spacingAfterIcon = isWideLayout ? 60.0 : 50.0;
            // Define minimum button height
            final double minButtonHeight = isWideLayout ? 80.0 : 80.0;

          Widget buildStyledButton(
              String text, IconData iconData, VoidCallback onPressed) {
            final bool isStartGame = (text == 'Start Game');
            // Explicitly set black and white colors, ignoring theme for buttons
            final Color bgColor = isStartGame ? Colors.white : Colors.black;
            final Color fgColor = isStartGame ? Colors.black : Colors.white;

            final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
              backgroundColor: bgColor, // Use explicit black/white
              foregroundColor: fgColor, // Use explicit black/white
              padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: buttonVerticalPadding), // Use updated padding
              textStyle: GoogleFonts.lato(
                fontSize: fontSize, // Use updated font size
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 3,
              shadowColor: Colors.transparent,
              minimumSize: Size(buttonWidth, minButtonHeight), // Use updated width and min height
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
                        padding: const EdgeInsets.only(left: 15.0),
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

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade100,
                  Colors.redAccent.shade100,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding), // Use updated padding
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start, // Changed from center
                    children: <Widget>[
                      SizedBox(height: 145.0), // Add space from top edge (behind AppBar)
                      // Replace Text emoji with an Icon widget
                      Icon(
                        Icons.sentiment_satisfied_alt, // Happy face icon
                        size: iconWidgetSize, // Use updated size
                        color: Colors.white.withAlpha((0.9 * 255).round()), // 0.9 opacity
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withAlpha((0.4 * 255).round()), // 0.4 opacity
                            offset: const Offset(1.0, 1.0),
                          ),
                        ], // Optional shadow for better visibility
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
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
