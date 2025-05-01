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
            fontSize: 24,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(1.0, 1.0),
              ),
            ],
          ),
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
    final Color shadowColor = Colors.black.withOpacity(0.3);

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

          final double horizontalPadding =
              screenWidth * (isWideLayout ? 0.25 : 0.15);
          final double buttonWidth = screenWidth * (isWideLayout ? 0.5 : 0.7);
          final double verticalSpacing = isWideLayout ? 35.0 : 25.0;
          final double buttonVerticalPadding = isWideLayout ? 22.0 : 20.0;
          final double iconSize = isWideLayout ? 24.0 : 22.0;
          final double fontSize = isWideLayout ? 20.0 : 18.0;

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
                  horizontal: 20, vertical: buttonVerticalPadding),
              textStyle: GoogleFonts.lato(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 3,
              shadowColor: Colors.transparent,
              minimumSize: Size(buttonWidth, 60),
              alignment: Alignment.center,
            );

            return Container(
              width: buttonWidth,
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
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      buildStyledButton('Start Game', Icons.play_arrow, () {
                        print("Start Game pressed");
                      }),
                      SizedBox(height: verticalSpacing),
                      buildStyledButton('Add Truths', Icons.add, () {
                        print("Add Truths pressed");
                      }),
                      SizedBox(height: verticalSpacing),
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
