import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

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
          titleTextStyle: GoogleFonts.baloo2(
            // Use Baloo 2 for AppBar
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

// Convert MyHomePage to StatefulWidget
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Add state variables for dialog
  String? _selectedGameMode; // To hold the selected mode in the dialog
  bool _saveSelection = false; // To hold the checkbox state
  String? _savedGameMode; // To hold the mode loaded from preferences

  // Define game modes
  final String _spinMode = 'Spin the bottle';
  final String _autoNextMode = 'Auto next turn';
  final String _randomMode = 'Random turn';
  final String _prefsKey = 'gameMode'; // Key for SharedPreferences

  @override
  void initState() {
    super.initState();
    _loadSavedMode(); // Load saved preference on init
  }

  // Load saved game mode from SharedPreferences
  Future<void> _loadSavedMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedGameMode = prefs.getString(_prefsKey);
      // Pre-select the mode in the dialog if it was saved
      _selectedGameMode = _savedGameMode;
      // If a mode was saved, assume user wanted to save it last time
      _saveSelection = _savedGameMode != null;
    });
    // If a mode was saved, maybe directly proceed to game?
    // Or show dialog with pre-selection. For now, just pre-select.
    print("Loaded saved mode: $_savedGameMode");
  }

  // Save game mode to SharedPreferences
  Future<void> _saveModePreference(String? mode) async {
    final prefs = await SharedPreferences.getInstance();
    if (_saveSelection && mode != null) {
      await prefs.setString(_prefsKey, mode);
      print("Saved mode: $mode");
    } else {
      // If save selection is unchecked, remove the preference
      await prefs.remove(_prefsKey);
      print("Removed saved mode preference.");
    }
    setState(() {
      _savedGameMode = _saveSelection ? mode : null;
    });
  }

  // Function to show the game mode selection dialog with slide animation
  Future<void> _showGameModeDialog(BuildContext context) async {
    // Use a temporary state for the dialog interaction
    String? currentSelection = _selectedGameMode ?? _spinMode;
    bool currentSaveSelection = _saveSelection;

    // Use showGeneralDialog for custom transitions
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      barrierLabel: MaterialLocalizations.of(context)
          .modalBarrierDismissLabel, // Accessibility label
      barrierColor: Colors.black54, // Dimmed background
      transitionDuration:
          const Duration(milliseconds: 350), // Adjusted duration for smoothness
      pageBuilder: (context, animation, secondaryAnimation) {
        // This builds the actual content of the dialog
        // Use StatefulBuilder to manage dialog's internal state locally
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final ThemeData theme = Theme.of(context);
            final ColorScheme colorScheme = theme.colorScheme;
            // Get screen size for relative sizing
            final Size screenSize = MediaQuery.of(context).size;
            final double dialogWidth = screenSize.width * 0.8;
            final double dialogPadding =
                screenSize.width * 0.05; // Relative padding
            final double verticalSpacingSmall =
                screenSize.height * 0.015; // Relative small spacing
            final double verticalSpacingMedium =
                screenSize.height * 0.025; // Relative medium spacing
            final double verticalSpacingLarge =
                screenSize.height * 0.03; // Relative large spacing

            // Dialog content styling
            final TextStyle dialogTextStyle = GoogleFonts.baloo2(
              fontSize: 18, // Keep font size fixed for now, or make relative?
              color: Colors.white,
            );
            final TextStyle titleTextStyle = GoogleFonts.baloo2(
              fontSize: 24, // Keep font size fixed for now
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black.withAlpha(100),
                  offset: const Offset(1.0, 1.0),
                ),
              ],
            );

            // Return the AlertDialog structure
            return AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              // Wrap the content in a Material widget to ensure theme application if needed
              content: Material(
                type: MaterialType.transparency,
                child: Container(
                  width: dialogWidth, // Use calculated width
                  padding:
                      EdgeInsets.all(dialogPadding), // Use relative padding
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 84, 51, 255),
                        Color.fromARGB(255, 153, 50, 204),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.white,
                      width: 3.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(80),
                        blurRadius: 10.0,
                        spreadRadius: 1.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Center(
                          child: Text(
                            'Select Game Mode',
                            style: titleTextStyle,
                          ),
                        ),
                        SizedBox(
                            height:
                                verticalSpacingMedium), // Use relative spacing
                        // Radio buttons
                        _buildRadioListTile(
                          title: _spinMode,
                          value: _spinMode,
                          groupValue: currentSelection,
                          onChanged: (String? value) {
                            setDialogState(() {
                              currentSelection = value;
                            });
                          },
                          textStyle: dialogTextStyle,
                          activeColor: Colors.white,
                        ),
                        _buildRadioListTile(
                          title: _autoNextMode,
                          value: _autoNextMode,
                          groupValue: currentSelection,
                          onChanged: (String? value) {
                            setDialogState(() {
                              currentSelection = value;
                            });
                          },
                          textStyle: dialogTextStyle,
                          activeColor: Colors.white,
                        ),
                        _buildRadioListTile(
                          title: _randomMode,
                          value: _randomMode,
                          groupValue: currentSelection,
                          onChanged: (String? value) {
                            setDialogState(() {
                              currentSelection = value;
                            });
                          },
                          textStyle: dialogTextStyle,
                          activeColor: Colors.white,
                        ),
                        SizedBox(
                            height:
                                verticalSpacingSmall), // Use relative spacing
                        // Checkbox
                        _buildCheckboxListTile(
                          title: 'Save Selection',
                          value: currentSaveSelection,
                          onChanged: (bool? value) {
                            setDialogState(() {
                              currentSaveSelection = value ?? false;
                            });
                          },
                          textStyle: dialogTextStyle,
                          activeColor: Colors.white,
                          checkColor: colorScheme.primary,
                        ),
                        SizedBox(
                            height:
                                verticalSpacingLarge), // Use relative spacing

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            // Cancel Button
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white70,
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        dialogPadding * 0.8, // Relative padding
                                    vertical:
                                        dialogPadding * 0.4 // Relative padding
                                    ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.baloo2(
                                    fontSize: 16), // Keep fixed
                              ),
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Use the outer context for pop
                              },
                            ),
                            // Start Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor:
                                    const Color.fromARGB(255, 84, 51, 255),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        dialogPadding * 1.2, // Relative padding
                                    vertical:
                                        dialogPadding * 0.5 // Relative padding
                                    ),
                              ),
                              child: Text(
                                'Start',
                                style: GoogleFonts.baloo2(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16), // Keep fixed
                              ),
                              onPressed: () {
                                if (currentSelection != null) {
                                  setState(() {
                                    _selectedGameMode = currentSelection;
                                    _saveSelection = currentSaveSelection;
                                  });
                                  _saveModePreference(currentSelection);
                                  print(
                                      "Selected mode: $currentSelection, Save: $currentSaveSelection");
                                  Navigator.of(context)
                                      .pop(); // Use the outer context for pop
                                  // TODO: Navigate
                                } else {
                                  // Use ScaffoldMessenger of the main context
                                  ScaffoldMessenger.of(
                                          this.context) // Use this.context
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Please select a game mode!',
                                          style: GoogleFonts.baloo2()),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Smooth slide animation (from bottom up)
        const begin = Offset(0.0, 0.3); // Start slightly lower
        const end = Offset.zero;
        // Use a smooth curve like easeOutCubic
        final curve = Curves.easeOutCubic;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        // Apply only the slide transition for smoothness
        return SlideTransition(
          position: offsetAnimation,
          child: child, // The child is the dialog built by pageBuilder
        );
      },
    );
  }

  // Helper for RadioListTile styling
  Widget _buildRadioListTile({
    required String title,
    required String value,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
    required TextStyle textStyle,
    required Color activeColor,
  }) {
    return RadioListTile<String>(
      title: Text(title, style: textStyle),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: activeColor,
      contentPadding: EdgeInsets.zero,
      // Make the tile dense
      dense: true,
      // Change radio button color when inactive
      fillColor:
          MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return activeColor; // Color when selected
        }
        return Colors.white70; // Color when not selected
      }),
    );
  }

  // Helper for CheckboxListTile styling
  Widget _buildCheckboxListTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required TextStyle textStyle,
    required Color activeColor,
    required Color checkColor,
  }) {
    return CheckboxListTile(
      title: Text(title, style: textStyle),
      value: value,
      onChanged: onChanged,
      activeColor: activeColor, // Background color of checkbox when checked
      checkColor: checkColor, // Color of the check mark
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading, // Checkbox on the left
      dense: true,
      // Style checkbox border when inactive
      side: MaterialStateBorderSide.resolveWith(
        (states) => BorderSide(width: 2.0, color: Colors.white70),
      ),
    );
  }

  // static const double wideLayoutThreshold = 600.0; // Removed threshold

  @override
  Widget build(BuildContext context) {
    // ... (keep existing variables like shadowColor, screenSize, etc.) ...
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

                // Define buildStyledButton INSIDE the builder scope
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
                    textStyle: GoogleFonts.baloo2(
                      // Use Baloo 2 for buttons
                      fontSize: fontSize, // Use updated font size
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
                      onPressed: onPressed, // Use the passed onPressed directly
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
                // End of buildStyledButton definition

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

                      // Update the onPressed for Start Game button
                      buildStyledButton('Start Game', Icons.play_arrow, () {
                        print("Start Game pressed - showing dialog");
                        _showGameModeDialog(
                            context); // Call the dialog function
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
                        padding: EdgeInsets.only(
                            bottom: screenHeight *
                                0.03), // Add padding below the buttons
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            _buildBottomBarButton(Icons.star, () {
                              // Changed from star_border to star
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
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // White background like Start Game
          foregroundColor:
              Colors.black, // Black icon color like Start Game text
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10), // Rounded corners like Start Game
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
