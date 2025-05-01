import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Removed import 'age_group_screen.dart'
import 'add_players_screen.dart'; // Import the new screen

// Define Enums for selections
enum GameMode {
  spin, // Spin the bottle
  auto, // Auto next turn
  random // Random turn
}

enum AgeGroup {
  kids, // Kids
  teen, // Teen
  adult // Adult
}

// Helper to get display text for enums
extension GameModeExtension on GameMode {
  String get displayText {
    switch (this) {
      case GameMode.spin:
        return 'Spin the bottle';
      case GameMode.auto:
        return 'Auto next turn';
      case GameMode.random:
        return 'Random turn';
    }
  }
}

extension AgeGroupExtension on AgeGroup {
  String get displayText {
    switch (this) {
      case AgeGroup.kids:
        return 'KIDS';
      case AgeGroup.teen:
        return 'TEEN';
      case AgeGroup.adult:
        return 'ADULT';
    }
  }

  IconData get displayIcon {
    switch (this) {
      case AgeGroup.kids:
        return Icons.child_care;
      case AgeGroup.teen:
        return Icons.school;
      case AgeGroup.adult:
        return Icons.person;
    }
  }
}

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
            fontWeight: FontWeight.bold,
            // Use Baloo 2 for AppBar
            fontSize: 40, // Slightly larger AppBar title
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
          toolbarHeight: 100, // Increase AppBar height to bring title lower
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
  // Update state variables to use enums
  GameMode? _selectedGameModeEnum; // Holds the selected enum
  AgeGroup? _selectedAgeGroupEnum; // Holds the selected age group enum
  bool _saveSelection = true; // Default to true here as well for consistency
  String? _savedGameModeString; // Still load/save as string for simplicity
  String? _savedAgeGroupString; // Add state variable for saved age group string

  // Define keys for saving preferences
  final String _gameModePrefsKey = 'gameMode'; // Key for saving game mode
  final String _ageGroupPrefsKey = 'ageGroup'; // Key for saving age group

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences(); // Rename load function
  }

  // Load saved game mode and age group, then convert to enums
  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedGameModeString = prefs.getString(_gameModePrefsKey);
      _savedAgeGroupString =
          prefs.getString(_ageGroupPrefsKey); // Load age group string

      if (_savedGameModeString != null) {
        try {
          _selectedGameModeEnum =
              GameMode.values.firstWhere((e) => e.name == _savedGameModeString);
        } catch (e) {
          print("Error converting saved game mode: $e");
          _selectedGameModeEnum = GameMode.spin; // Default if conversion fails
        }
      } else {
        _selectedGameModeEnum = GameMode.spin; // Default if nothing saved
      }

      if (_savedAgeGroupString != null) {
        // Convert saved age group string
        try {
          _selectedAgeGroupEnum =
              AgeGroup.values.firstWhere((e) => e.name == _savedAgeGroupString);
        } catch (e) {
          print("Error converting saved age group: $e");
          // Keep _selectedAgeGroupEnum null if conversion fails, let dialog handle default
        }
      }
      // else: _selectedAgeGroupEnum remains null if nothing saved

      // If either preference was saved, assume user wanted to save last time
      _saveSelection =
          (_savedGameModeString != null || _savedAgeGroupString != null);
    });
    print(
        "Loaded saved mode string: $_savedGameModeString, Enum: $_selectedGameModeEnum");
    print(
        "Loaded saved age group string: $_savedAgeGroupString, Enum: $_selectedAgeGroupEnum");
  }

  // Save game mode and age group enum names to SharedPreferences
  Future<void> _savePreferences(GameMode? mode, AgeGroup? ageGroup) async {
    final prefs = await SharedPreferences.getInstance();
    if (_saveSelection) {
      if (mode != null) {
        await prefs.setString(
            _gameModePrefsKey, mode.name); // Save game mode enum name
        print("Saved game mode: ${mode.name}");
        _savedGameModeString = mode.name;
      } else {
        await prefs.remove(
            _gameModePrefsKey); // Remove if null (shouldn't happen if _saveSelection is true)
        _savedGameModeString = null;
      }
      if (ageGroup != null) {
        await prefs.setString(
            _ageGroupPrefsKey, ageGroup.name); // Save age group enum name
        print("Saved age group: ${ageGroup.name}");
        _savedAgeGroupString = ageGroup.name;
      } else {
        await prefs.remove(_ageGroupPrefsKey); // Remove if null
        _savedAgeGroupString = null;
      }
    } else {
      await prefs.remove(_gameModePrefsKey);
      await prefs.remove(_ageGroupPrefsKey); // Remove both keys
      print("Removed saved preferences.");
      _savedGameModeString = null;
      _savedAgeGroupString = null;
    }
    // No need to setState here as it's called from the dialog confirmation
  }

  // --- Function to show the ADULT confirmation dialog ---
  Future<bool> _showAdultConfirmationDialog(BuildContext context) async {
    // Use a different context name to avoid conflict with the outer dialog context
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false, // User must tap button!
          barrierColor: Colors.black54, // Dim the background
          builder: (BuildContext confirmDialogContext) {
            final Size screenSize = MediaQuery.of(confirmDialogContext).size;
            final double dialogPadding = screenSize.width * 0.05;

            // Define styles consistent with the app's theme but with different colors
            final BoxDecoration dialogDecoration = BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              gradient: const LinearGradient(
                colors: [
                  // Use a different gradient - e.g., Deep Purple to Pink
                  Color.fromARGB(255, 103, 58, 183), // Deep Purple
                  Color.fromARGB(255, 233, 30, 99), // Pink
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white
                    .withOpacity(0.8), // Slightly transparent white border
                width: 3.0, // Thick border
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withAlpha(120), // Deeper shadow (increased alpha)
                  blurRadius: 12.0, // Increased blur
                  spreadRadius: 2.0, // Increased spread
                  offset: const Offset(0, 6), // Increased offset for depth
                ),
              ],
            );

            final TextStyle titleStyle = GoogleFonts.baloo2(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white, // White title
              shadows: [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black.withAlpha(100),
                  offset: const Offset(1.0, 1.0),
                ),
              ],
            );

            final TextStyle contentStyle = GoogleFonts.baloo2(
              fontSize: 16,
              color: Colors.white
                  .withOpacity(0.9), // Slightly transparent white content
            );

            return AlertDialog(
              backgroundColor:
                  Colors.transparent, // Make AlertDialog background transparent
              contentPadding: EdgeInsets.zero, // Remove default padding
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15.0)), // Match container shape
              content: Container(
                padding: EdgeInsets.all(
                    dialogPadding), // Apply padding inside the container
                decoration: dialogDecoration, // Apply the custom decoration
                child: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Center(
                        child: Text(
                          'Confirm Age',
                          style: titleStyle,
                        ),
                      ),
                      const SizedBox(height: 15), // Spacing
                      Text(
                        'Adult mode is not suitable for anyone under 18.',
                        style: contentStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5), // Spacing
                      Text(
                        'Are you sure you want to continue?',
                        style: contentStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25), // Spacing before buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Colors.white70, // Lighter color for cancel
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.baloo2(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            onPressed: () {
                              Navigator.of(confirmDialogContext)
                                  .pop(false); // Return false
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.white, // White background for confirm
                              foregroundColor: const Color.fromARGB(255, 103,
                                  58, 183), // Use a gradient color for text
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            child: Text(
                              'Continue',
                              style: GoogleFonts.baloo2(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.of(confirmDialogContext)
                                  .pop(true); // Return true
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Remove original actions, they are now inside the Container
              // actions: <Widget>[ ... ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed otherwise
  }
  // --- End ADULT confirmation dialog ---

  // Function to show the combined game mode and age group selection dialog
  Future<void> _showGameSelectionDialog(BuildContext context) async {
    // Initialize temporary state for the dialog
    GameMode currentModeSelection = _selectedGameModeEnum ?? GameMode.spin;
    // Use loaded age group if available, otherwise default to kids
    AgeGroup currentAgeSelection = _selectedAgeGroupEnum ?? AgeGroup.kids;
    // Use the loaded save preference state
    bool currentSaveSelection = _saveSelection; // Use the actual loaded state

    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (dialogPageContext, animation, secondaryAnimation) {
        // Changed context name
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // ... (keep theme, colorScheme, screenSize, spacing variables) ...
            final ThemeData theme = Theme.of(context);
            final ColorScheme colorScheme = theme.colorScheme;
            final Size screenSize = MediaQuery.of(context).size;
            final double dialogWidth =
                screenSize.width * 0.85; // Slightly wider
            final double dialogPadding = screenSize.width * 0.05;
            final double verticalSpacingSmall = screenSize.height * 0.01;
            final double verticalSpacingMedium = screenSize.height * 0.02;
            final double verticalSpacingLarge = screenSize.height * 0.03;

            final TextStyle dialogTextStyle = GoogleFonts.baloo2(
              fontSize: 16, // Slightly smaller for more content
              color: Colors.white,
            );
            final TextStyle titleTextStyle = GoogleFonts.baloo2(
              fontSize: 22, // Adjust size
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
            final TextStyle labelTextStyle = dialogTextStyle.copyWith(
                fontWeight: FontWeight.bold, fontSize: 18);

            // --- Custom Button Builder ---
            Widget buildSelectionButton<T>({
              required String text,
              IconData? icon,
              required T value,
              required T groupValue,
              required ValueChanged<T> onChanged,
            }) {
              bool isSelected = (value == groupValue);
              final Color bgColor =
                  isSelected ? Colors.white : Colors.white.withOpacity(0.15);
              final Color fgColor = isSelected
                  ? const Color.fromARGB(255, 84, 51, 255)
                  : Colors.white; // Dialog accent or white
              final double elevation = isSelected ? 4.0 : 1.0;
              final BorderSide borderSide = isSelected
                  ? BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5)
                  : BorderSide.none;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0), // Spacing between buttons
                  child: ElevatedButton.icon(
                    icon: icon != null
                        ? Icon(icon, size: 18, color: fgColor)
                        : const SizedBox.shrink(),
                    label: Text(text,
                        style: GoogleFonts.baloo2(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bgColor,
                      foregroundColor: fgColor,
                      elevation: elevation,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12), // Adjust padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: borderSide,
                      ),
                      // Animation for selection change (optional but nice)
                      animationDuration: const Duration(milliseconds: 200),
                    ),
                    onPressed: () => onChanged(value),
                  ),
                ),
              );
            }
            // --- End Custom Button Builder ---

            return AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              content: Material(
                type: MaterialType.transparency,
                child: Container(
                  width: dialogWidth,
                  padding: EdgeInsets.all(dialogPadding),
                  decoration: BoxDecoration(
                    // ... (keep existing gradient, border, shadow) ...
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
                          child: Text('Game Setup', style: titleTextStyle),
                        ),
                        SizedBox(height: verticalSpacingMedium),

                        // Game Mode Selection
                        Text('Game Mode',
                            style: labelTextStyle, textAlign: TextAlign.center),
                        SizedBox(height: verticalSpacingSmall),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: GameMode.values
                              .map((mode) => buildSelectionButton<GameMode>(
                                    text: mode.displayText
                                        .split(' ')
                                        .first, // Short text
                                    value: mode,
                                    groupValue: currentModeSelection,
                                    onChanged: (value) {
                                      setDialogState(
                                          () => currentModeSelection = value);
                                    },
                                  ))
                              .toList(),
                        ),
                        SizedBox(height: verticalSpacingLarge),

                        // Age Group Selection
                        Text('Age Group',
                            style: labelTextStyle, textAlign: TextAlign.center),
                        SizedBox(height: verticalSpacingSmall),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: AgeGroup.values
                              .map((age) => buildSelectionButton<AgeGroup>(
                                    text: age.displayText,
                                    icon: age.displayIcon,
                                    value: age,
                                    groupValue: currentAgeSelection,
                                    onChanged: (value) {
                                      setDialogState(
                                          () => currentAgeSelection = value);
                                    },
                                  ))
                              .toList(),
                        ),
                        SizedBox(height: verticalSpacingMedium),

                        // Checkbox (using the existing helper)
                        _buildCheckboxListTile(
                          title: 'Save Game Mode', // Updated text
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
                        SizedBox(height: verticalSpacingLarge),

                        // Buttons (using existing styling)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            TextButton(
                              // ... (keep existing cancel button style) ...
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white70,
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        dialogPadding * 0.8, // Relative padding
                                    vertical:
                                        dialogPadding * 0.4 // Relative padding
                                    ),
                              ),
                              child: Text('Cancel',
                                  style: GoogleFonts.baloo2(fontSize: 16)),
                              onPressed: () {
                                Navigator.of(dialogPageContext)
                                    .pop(); // Use dialogPageContext
                              },
                            ),
                            ElevatedButton(
                              // ... (keep existing start button style) ...
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
                              child: Text('Start',
                                  style: GoogleFonts.baloo2(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              onPressed: () async {
                                // Make onPressed async
                                final GameMode finalGameMode =
                                    currentModeSelection;
                                final AgeGroup finalAgeGroup =
                                    currentAgeSelection;
                                final bool finalSave = currentSaveSelection;

                                bool proceed = true; // Assume we can proceed

                                // Check if Adult is selected and show confirmation
                                if (finalAgeGroup == AgeGroup.adult) {
                                  // Use the dialogPageContext to show the confirmation dialog
                                  proceed = await _showAdultConfirmationDialog(
                                      dialogPageContext);
                                }

                                // Only proceed if not adult OR if adult and confirmed
                                if (proceed) {
                                  // Update main screen state
                                  setState(() {
                                    _selectedGameModeEnum = finalGameMode;
                                    _selectedAgeGroupEnum = finalAgeGroup;
                                    _saveSelection =
                                        finalSave; // Update save state
                                  });
                                  // Save preferences if needed
                                  await _savePreferences(
                                      // Call updated save function
                                      finalGameMode,
                                      finalAgeGroup); // await the save

                                  print(
                                      "Selected Mode: ${finalGameMode.name}, Age Group: ${finalAgeGroup.name}, Save: $finalSave. Starting game...");

                                  Navigator.of(dialogPageContext)
                                      .pop(); // Close the main selection dialog

                                  // Navigate to the Add Players screen using a custom transition
                                  Navigator.push(
                                    this.context, // Use the original context from MyHomePage
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          AddPlayersScreen(
                                        gameMode: finalGameMode,
                                        ageGroup: finalAgeGroup,
                                      ),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        // Define the slide animation from right to left
                                        const begin = Offset(
                                            1.0, 0.0); // Start from the right
                                        const end =
                                            Offset.zero; // End at the center
                                        const curve =
                                            Curves.ease; // Animation curve

                                        final tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));
                                        final offsetAnimation =
                                            animation.drive(tween);

                                        return SlideTransition(
                                          position: offsetAnimation,
                                          child: child,
                                        );
                                      },
                                      transitionDuration: const Duration(
                                          milliseconds:
                                              300), // Optional: Adjust duration
                                    ),
                                  );
                                }
                                // else: If proceed is false (user cancelled adult confirmation), do nothing,
                                // the confirmation dialog is already closed, and the main dialog remains open.
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
        // ... (keep existing transition) ...
        const begin = Offset(0.0, 0.3); // Start slightly lower
        const end = Offset.zero;
        final curve = Curves.easeOutCubic;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  // Helper for CheckboxListTile styling (keep as is)
  Widget _buildCheckboxListTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required TextStyle textStyle,
    required Color activeColor,
    required Color checkColor,
  }) {
    // ...existing code...
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

  @override
  Widget build(BuildContext context) {
    // ... (keep existing build method structure) ...

    return Scaffold(
      appBar: AppBar(
        title: const Text('Truth or Dare'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        // ... (keep existing background gradient) ...
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 252, 118, 84),
              Color.fromARGB(255, 245, 64, 100),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            // ... (keep existing constraints) ...
            constraints: const BoxConstraints(
                maxWidth: 800), // Keep max width constraint
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Get screen dimensions for relative sizing
                final Size screenSize = MediaQuery.of(context).size;
                final double screenWidth = screenSize.width;
                final double screenHeight = screenSize.height;

                return Padding(
                  // ... (keep existing padding) ...
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.12), // Use updated padding
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      // ... (keep existing icon and spacing) ...
                      SizedBox(height: screenHeight * 0.15),
                      Icon(
                        Icons.sentiment_satisfied_alt,
                        size: screenHeight * 0.08,
                        color: Colors.white.withAlpha((0.9 * 255).round()),
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withAlpha((0.4 * 255).round()),
                            offset: const Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.06),

                      // Update the onPressed for Start Game button to call the new dialog
                      _buildStyledButton('Start Game', Icons.play_arrow, () {
                        print("Start Game pressed - showing combined dialog");
                        _showGameSelectionDialog(
                            context); // Call the new dialog function
                      }),
                      SizedBox(height: screenHeight * 0.05),
                      _buildStyledButton('Add Truths', Icons.add, () {
                        print("Add Truths pressed");
                        // TODO: Navigate to Add Truths screen
                      }),
                      SizedBox(height: screenHeight * 0.05),
                      _buildStyledButton('Add Dares', Icons.add, () {
                        print("Add Dares pressed");
                        // TODO: Navigate to Add Dares screen
                      }),
                      const Spacer(),
                      // ... (keep existing bottom bar) ...
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: screenHeight *
                                0.03), // Add padding below the buttons
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            _buildBottomBarButton(Icons.star, () {
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

  // Keep _buildStyledButton (for main screen buttons)
  Widget _buildStyledButton(
      String text, IconData iconData, VoidCallback onPressed) {
    // ... (existing implementation remains unchanged) ...
    final Color shadowColor = Colors.black.withAlpha((0.3 * 255).round());
    final Size screenSize = MediaQuery.of(context).size; // Access context here
    final double screenWidth = screenSize.width;
    final double buttonWidth = screenWidth * 0.75;
    final double buttonVerticalPadding = 30.0;
    final double fontSize = 25.0;
    final double iconSize = 50.0; // Reverted icon size
    final double minButtonHeight = screenSize.height * 0.07;

    // Restore conditional styling based on button text
    final bool isStartGame = (text == 'Start Game');
    final Color bgColor = isStartGame ? Colors.white : Colors.black;
    final Color fgColor = isStartGame ? Colors.black : Colors.white;

    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: bgColor, // Use conditional background color
      foregroundColor: fgColor, // Use conditional foreground color
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
      shadowColor: Colors.transparent,
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
                child: Icon(iconData, size: iconSize), // Use reverted icon size
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

  // Keep _buildBottomBarButton
  Widget _buildBottomBarButton(IconData icon, VoidCallback onPressed) {
    // ... (existing implementation remains unchanged) ...
    final Color shadowColor =
        Colors.black.withAlpha((0.3 * 255).round()); // Consistent shadow

    return Container(
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
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(15),
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(60, 60),
        ),
        onPressed: onPressed,
        child: Icon(
          icon,
          color: Colors.black,
          size: 30.0,
        ),
      ),
    );
  }
}
