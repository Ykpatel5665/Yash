import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_players_screen.dart'; // Import the new screen
import 'dart:ui';
import 'category_selection_screen.dart';
import 'widgets/buttons/primary_button.dart'; // Import PrimaryButton
import 'widgets/buttons/toggle_button.dart';

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

  // Permanent solution: provide a name getter for enum value
  String get name {
    switch (this) {
      case AgeGroup.kids:
        return 'kids';
      case AgeGroup.teen:
        return 'teen';
      case AgeGroup.adult:
        return 'adult';
    }
  }
}

void main() async {
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
  bool _lastUseTimer = true; // Track last useTimer value

  // Define keys for saving preferences
  final String _gameModePrefsKey = 'gameMode'; // Key for saving game mode
  final String _ageGroupPrefsKey = 'ageGroup'; // Key for saving age group
  final String _useTimerPrefsKey = 'useTimer'; // Key for saving useTimer

  // Track adult confirmation for this session
  bool _adultConfirmedThisSession = false;

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
      _savedAgeGroupString = prefs.getString(_ageGroupPrefsKey);
      _lastUseTimer = prefs.getBool(_useTimerPrefsKey) ?? true; // Load useTimer, default true

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
    });
    print(
        "Loaded saved mode string: $_savedGameModeString, Enum: $_selectedGameModeEnum");
    print(
        "Loaded saved age group string: $_savedAgeGroupString, Enum: $_selectedAgeGroupEnum");
  }

  // Save game mode and age group enum names to SharedPreferences
  Future<void> _savePreferences(GameMode? mode, AgeGroup? ageGroup, {bool? useTimer}) async {
    final prefs = await SharedPreferences.getInstance();
    if (_saveSelection) {
      if (mode != null) {
        await prefs.setString(_gameModePrefsKey, mode.name);
        _savedGameModeString = mode.name;
      } else {
        await prefs.remove(_gameModePrefsKey);
        _savedGameModeString = null;
      }
      if (ageGroup != null) {
        await prefs.setString(_ageGroupPrefsKey, ageGroup.name);
        _savedAgeGroupString = ageGroup.name;
      } else {
        await prefs.remove(_ageGroupPrefsKey);
        _savedAgeGroupString = null;
      }
      if (useTimer != null) {
        await prefs.setBool(_useTimerPrefsKey, useTimer);
        _lastUseTimer = useTimer;
      }
    } else {
      await prefs.remove(_gameModePrefsKey);
      await prefs.remove(_ageGroupPrefsKey);
      await prefs.remove(_useTimerPrefsKey);
      _savedGameModeString = null;
      _savedAgeGroupString = null;
      _lastUseTimer = true;
    }
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
                      .withAlpha(80), // Lowered alpha
                  blurRadius: 6.0, // Reduced blur
                  spreadRadius: 1.0, // Reduced spread
                  offset: const Offset(0, 4), // Reduced offset
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
                  color: Colors.black.withAlpha(60), // Lowered alpha
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

  // --- Modern Game Setup Dialog (Glassmorphism, Animated, Responsive) ---
Future<void> _showModernGameSetupDialog(BuildContext context) async {
  GameMode currentModeSelection = _selectedGameModeEnum ?? GameMode.spin;
  AgeGroup currentAgeSelection = _selectedAgeGroupEnum ?? AgeGroup.kids;
  bool useTimer = _lastUseTimer; // Use last value as default

  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (dialogPageContext, animation, secondaryAnimation) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final Size screenSize = MediaQuery.of(context).size;
          final double cardWidth = screenSize.width * 0.92;
          final double maxCardWidth = 420;
          final double cardPadding = 24.0;

          Widget buildToggleButton({
            required String label,
            required bool selected,
            required VoidCallback onTap,
            required IconData? icon,
            Color? selectedColor,
            Color? unselectedColor,
            double? iconSize,
            double? fontSize,
          }) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? (selectedColor ?? Colors.white.withOpacity(0.15))
                    : (unselectedColor ?? Colors.white.withOpacity(0.05)),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? Colors.white : Colors.white24,
                  width: selected ? 2.5 : 1.0,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.15),
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null)
                        Icon(icon, color: Colors.white, size: iconSize ?? 28),
                      if (icon != null) const SizedBox(height: 6),
                      Text(
                        label,
                        style: GoogleFonts.baloo2(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize ?? 15,
                          height: 1.1,
                          shadows: selected
                              ? [
                                  Shadow(
                                    blurRadius: 2,
                                    color: Colors.white.withOpacity(0.3),
                                  )
                                ]
                              : [],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final double iconSize = (screenSize.width * 0.08).clamp(22, 36);
          final double fontSize = (screenSize.width * 0.035).clamp(13, 18);

          return Center(
            child: Material(
              type: MaterialType.transparency,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                  child: Container(
                    width: cardWidth > maxCardWidth ? maxCardWidth : cardWidth,
                    padding: EdgeInsets.all(cardPadding),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.32),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.88,
                          ),
                          child: ListView(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            children: [
                              Text(
                                "Game Setup",
                                style: GoogleFonts.baloo2(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 4,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Game Mode",
                                  style: GoogleFonts.baloo2(
                                    color: Colors.white.withOpacity(0.92),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(child: buildToggleButton(
                                    label: "Spin",
                                    selected: currentModeSelection == GameMode.spin,
                                    onTap: () => setDialogState(() => currentModeSelection = GameMode.spin),
                                    icon: Icons.casino,
                                    selectedColor: const Color(0xFF5B86E5).withOpacity(0.25),
                                    iconSize: iconSize + 2,
                                    fontSize: fontSize + 4,
                                  )),
                                  Expanded(child: buildToggleButton(
                                    label: "Auto",
                                    selected: currentModeSelection == GameMode.auto,
                                    onTap: () => setDialogState(() => currentModeSelection = GameMode.auto),
                                    icon: Icons.autorenew,
                                    selectedColor: const Color(0xFF8F6ED5).withOpacity(0.25),
                                    iconSize: iconSize + 2,
                                    fontSize: fontSize + 4,
                                  )),
                                  Expanded(child: buildToggleButton(
                                    label: "Random",
                                    selected: currentModeSelection == GameMode.random,
                                    onTap: () => setDialogState(() => currentModeSelection = GameMode.random),
                                    icon: Icons.shuffle,
                                    selectedColor: const Color(0xFFB388FF).withOpacity(0.25),
                                    iconSize: iconSize + 2,
                                    fontSize: fontSize + 4,
                                  )),
                                ],
                              ),
                              const SizedBox(height: 28),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Age Group",
                                  style: GoogleFonts.baloo2(
                                    color: Colors.white.withOpacity(0.92),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(child: buildToggleButton(
                                    label: "Kids",
                                    selected: currentAgeSelection == AgeGroup.kids,
                                    onTap: () => setDialogState(() => currentAgeSelection = AgeGroup.kids),
                                    icon: Icons.child_care,
                                    selectedColor: const Color(0xFF4DD0E1).withOpacity(0.25),
                                    iconSize: iconSize + 2,
                                    fontSize: fontSize + 4,
                                  )),
                                  Expanded(child: buildToggleButton(
                                    label: "Teen",
                                    selected: currentAgeSelection == AgeGroup.teen,
                                    onTap: () => setDialogState(() => currentAgeSelection = AgeGroup.teen),
                                    icon: Icons.school,
                                    selectedColor: const Color(0xFF9575CD).withOpacity(0.25),
                                    iconSize: iconSize + 2,
                                    fontSize: fontSize + 4,
                                  )),
                                  Expanded(child: buildToggleButton(
                                    label: "Adult",
                                    selected: currentAgeSelection == AgeGroup.adult,
                                    onTap: () => setDialogState(() => currentAgeSelection = AgeGroup.adult),
                                    icon: Icons.person,
                                    selectedColor: const Color(0xFFBA68C8).withOpacity(0.25),
                                    iconSize: iconSize + 2,
                                    fontSize: fontSize + 4,
                                  )),
                                ],
                              ),
                              const SizedBox(height: 28),
                              // Add Use Timer checkbox
                              InkWell(
                                onTap: () {
                                  setDialogState(() {
                                    useTimer = !useTimer;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: useTimer,
                                      onChanged: (val) {
                                        setDialogState(() {
                                          useTimer = val ?? true;
                                        });
                                      },
                                      activeColor: Colors.white,
                                      checkColor: Colors.black,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Use Timer (60s)',
                                        style: GoogleFonts.baloo2(
                                          color: Colors.white.withOpacity(0.92),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(dialogPageContext).pop();
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white70,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        textStyle: GoogleFonts.baloo2(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17,
                                        ),
                                      ),
                                      child: const Text("Cancel"),
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF5B86E5),
                                            Color(0xFF8F6ED5),
                                          ],
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
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          final GameMode finalGameMode = currentModeSelection;
                                          final AgeGroup finalAgeGroup = currentAgeSelection;
                                          bool proceed = true;
                                          if (finalAgeGroup == AgeGroup.adult && !_adultConfirmedThisSession) {
                                            proceed = await _showAdultConfirmationDialog(dialogPageContext);
                                            if (proceed) {
                                              setState(() {
                                                _adultConfirmedThisSession = true;
                                              });
                                            }
                                          }
                                          if (proceed) {
                                            setState(() {
                                              _selectedGameModeEnum = finalGameMode;
                                              _selectedAgeGroupEnum = finalAgeGroup;
                                              _lastUseTimer = useTimer; // Save last useTimer
                                            });
                                            await _savePreferences(finalGameMode, finalAgeGroup, useTimer: useTimer);
                                            Navigator.of(dialogPageContext).pop();
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 18),
                                          textStyle: GoogleFonts.baloo2(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Save",
                                            style: GoogleFonts.baloo2(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 8,
                                                  color: Colors.black.withOpacity(0.25),
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ),
            );
        },
      );
    },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.3);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
  );
}
// ...existing code...
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    // ...existing code...
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

                      _buildStyledButton(
                        'Start Game',
                        Icons.play_arrow,
                        () async {
                          bool proceed = true;
                          if (_selectedAgeGroupEnum == AgeGroup.adult && !_adultConfirmedThisSession) {
                            proceed = await _showAdultConfirmationDialog(context);
                            if (proceed) {
                              setState(() {
                                _adultConfirmedThisSession = true;
                              });
                            }
                          }
                          if (_selectedGameModeEnum == null || _selectedAgeGroupEnum == null) {
                            await _showModernGameSetupDialog(context);
                          }
                          if (proceed && _selectedGameModeEnum != null && _selectedAgeGroupEnum != null) {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => CategorySelectionScreen(
                                  gameMode: _selectedGameModeEnum!,
                                  ageGroup: _selectedAgeGroupEnum!,
                                  useTimer: _lastUseTimer, // Pass last useTimer value
                                ),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.ease;
                                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  final offsetAnimation = animation.drive(tween);
                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                                transitionDuration: const Duration(milliseconds: 300),
                              ),
                            );
                          }
                        },
                      ),
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
                              // Open Game Setup dialog from settings
                              _showModernGameSetupDialog(context);
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
    // ...existing code...
    final Color shadowColor = Colors.black.withAlpha((0.3 * 255).round());
    final Size screenSize = MediaQuery.of(context).size; // Access context here
    final double screenWidth = screenSize.width;
    final double buttonWidth = screenWidth * 0.75;
    const double buttonVerticalPadding = 30.0;
    const double fontSize = 25.0;
    const double iconSize = 50.0; // Reverted icon size
    final double minButtonHeight = screenSize.height * 0.001;

    // Restore conditional styling based on button text
    final bool isStartGame = (text == 'Start Game');
    final Color bgColor = isStartGame ? Colors.white : Colors.black;
    final Color fgColor = isStartGame ? Colors.black : Colors.white;

    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: bgColor, // Use conditional background color
      foregroundColor: fgColor, // Use conditional foreground color
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: buttonVerticalPadding),
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
        child: Row(
          children: [
            Icon(iconData, size: iconSize),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Opacity(
              opacity: 0,
              child: Icon(iconData, size: iconSize),
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
