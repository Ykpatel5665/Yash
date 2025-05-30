import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_players_screen.dart'; // Import the new screen
import 'dart:ui';
import 'category_selection_screen.dart';
import 'widgets/buttons/primary_button.dart'; // Import PrimaryButton
import 'widgets/buttons/toggle_button.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
  String displayText(BuildContext context) {
    switch (this) {
      case GameMode.spin:
        return AppLocalizations.of(context)!.spinTheBottle;
      case GameMode.auto:
        return AppLocalizations.of(context)!.autoNextTurn;
      case GameMode.random:
        return AppLocalizations.of(context)!.randomTurn;
    }
  }
}

extension AgeGroupExtension on AgeGroup {
  String displayText(BuildContext context) {
    switch (this) {
      case AgeGroup.kids:
        return AppLocalizations.of(context)!.kids;
      case AgeGroup.teen:
        return AppLocalizations.of(context)!.teen;
      case AgeGroup.adult:
        return AppLocalizations.of(context)!.adult;
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
  await Future.delayed(const Duration(seconds: 2)); // Ensures splash stays for 2s
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('es'),
        Locale('fr'),
        Locale('de'),
        Locale('zh'),
        Locale('ar'),
        Locale('bn'),
        Locale('pt'),
        Locale('ru'),
        Locale('ja'),
        Locale('ko'),
      ],
      locale: _locale,
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      home: MyHomePage(setLocale: setLocale),
    );
  }
}

// Convert MyHomePage to StatefulWidget
class MyHomePage extends StatefulWidget {
  final void Function(Locale) setLocale;
  const MyHomePage({super.key, required this.setLocale});

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
  // Add a new key for the 'Don't show again' preference
  final String _dontShowGameSetupDialogKey = 'dontShowGameSetupDialog';
  bool _dontShowGameSetupDialog = false;

  // Track adult confirmation for this session
  bool _adultConfirmedThisSession = false;

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences(); // Rename load function
    _loadDontShowGameSetupDialogPref();
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

  // Load 'Don't show again' preference
  Future<void> _loadDontShowGameSetupDialogPref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dontShowGameSetupDialog = prefs.getBool(_dontShowGameSetupDialogKey) ?? false;
    });
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

  // Save 'Don't show again' preference
  Future<void> _saveDontShowGameSetupDialogPref(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dontShowGameSetupDialogKey, value);
    setState(() {
      _dontShowGameSetupDialog = value;
    });
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
                          AppLocalizations.of(context)!.confirmAge,
                          style: titleStyle,
                        ),
                      ),
                      const SizedBox(height: 15), // Spacing
                      Text(
                        AppLocalizations.of(context)!.adultModeWarning,
                        style: contentStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5), // Spacing
                      Text(
                        AppLocalizations.of(context)!.areYouSure,
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
                              AppLocalizations.of(context)!.cancel,
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
                              AppLocalizations.of(context)!.continueStr,
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
Future<bool> _showModernGameSetupDialog(BuildContext context) async {
  GameMode currentModeSelection = _selectedGameModeEnum ?? GameMode.spin;
  AgeGroup currentAgeSelection = _selectedAgeGroupEnum ?? AgeGroup.kids;
  bool useTimer = _lastUseTimer; // Use last value as default
  bool dontShowAgain = _dontShowGameSetupDialog;

  final result = await showGeneralDialog<bool>(
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
            return SizedBox(
              width: 110, // Fixed width for all screens
              height: 110, // Fixed height for all screens
              child: AnimatedContainer(
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double iconSz = constraints.maxWidth * 0.38;
                      final double txtSz = (constraints.maxWidth * 0.15).clamp(12, 16);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (icon != null)
                              Icon(icon, color: Colors.white, size: iconSz),
                            if (icon != null) const SizedBox(height: 6),
                            Expanded(
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    label,
                                    style: GoogleFonts.baloo2(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: txtSz,
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
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              );
            }
            final double iconSize = 32; // Fixed icon size
            final double fontSize = 14; // Fixed font size

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
                                  AppLocalizations.of(context)!.gameSetup,
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
                                    AppLocalizations.of(context)!.gameMode,
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
                                    Flexible(
                                      child: buildToggleButton(
                                        label: AppLocalizations.of(context)!.spinTheBottle,
                                        selected: currentModeSelection == GameMode.spin,
                                        onTap: () => setDialogState(() => currentModeSelection = GameMode.spin),
                                        icon: Icons.casino,
                                        selectedColor: const Color(0xFF5B86E5).withOpacity(0.25),
                                        iconSize: iconSize,
                                        fontSize: fontSize,
                                      ),
                                    ),
                                    Flexible(
                                      child: buildToggleButton(
                                        label: AppLocalizations.of(context)!.autoNextTurn,
                                        selected: currentModeSelection == GameMode.auto,
                                        onTap: () => setDialogState(() => currentModeSelection = GameMode.auto),
                                        icon: Icons.autorenew,
                                        selectedColor: const Color(0xFF8F6ED5).withOpacity(0.25),
                                        iconSize: iconSize,
                                        fontSize: fontSize,
                                      ),
                                    ),
                                    Flexible(
                                      child: buildToggleButton(
                                        label: AppLocalizations.of(context)!.randomTurn,
                                        selected: currentModeSelection == GameMode.random,
                                        onTap: () => setDialogState(() => currentModeSelection = GameMode.random),
                                        icon: Icons.shuffle,
                                        selectedColor: const Color(0xFFB388FF).withOpacity(0.25),
                                        iconSize: iconSize,
                                        fontSize: fontSize,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    AppLocalizations.of(context)!.ageGroup,
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
                                    Flexible(
                                      child: buildToggleButton(
                                        label: AppLocalizations.of(context)!.kids,
                                        selected: currentAgeSelection == AgeGroup.kids,
                                        onTap: () => setDialogState(() => currentAgeSelection = AgeGroup.kids),
                                        icon: Icons.child_care,
                                        selectedColor: const Color(0xFF4DD0E1).withOpacity(0.25),
                                        iconSize: iconSize,
                                        fontSize: fontSize,
                                      ),
                                    ),
                                    Flexible(
                                      child: buildToggleButton(
                                        label: AppLocalizations.of(context)!.teen,
                                        selected: currentAgeSelection == AgeGroup.teen,
                                        onTap: () => setDialogState(() => currentAgeSelection = AgeGroup.teen),
                                        icon: Icons.school,
                                        selectedColor: const Color(0xFF9575CD).withOpacity(0.25),
                                        iconSize: iconSize,
                                        fontSize: fontSize,
                                      ),
                                    ),
                                    Flexible(
                                      child: buildToggleButton(
                                        label: AppLocalizations.of(context)!.adult,
                                        selected: currentAgeSelection == AgeGroup.adult,
                                        onTap: () => setDialogState(() => currentAgeSelection = AgeGroup.adult),
                                        icon: Icons.person,
                                        selectedColor: const Color(0xFFBA68C8).withOpacity(0.25),
                                        iconSize: iconSize,
                                        fontSize: fontSize,
                                      ),
                                    ),
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
                                          AppLocalizations.of(context)!.useTimer,
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
                                // Add Don't show again checkbox
                                InkWell(
                                  onTap: () {
                                    setDialogState(() {
                                      dontShowAgain = !dontShowAgain;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: dontShowAgain,
                                        onChanged: (val) {
                                          setDialogState(() {
                                            dontShowAgain = val ?? false;
                                          });
                                        },
                                        activeColor: Colors.white,
                                        checkColor: Colors.black,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)!.dontShowAgain,
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
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(dialogPageContext).pop(false); // Return false on cancel
                                        },
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: const Color(0xFF7B4444), // Muted red/brown for Cancel
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          minimumSize: const Size(0, 48),
                                          textStyle: GoogleFonts.baloo2(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        child: Text(
                                          AppLocalizations.of(context)!.cancel,
                                          style: GoogleFonts.baloo2(
                                            color: Colors.white.withOpacity(0.7),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          setState(() {
                                            _selectedGameModeEnum = currentModeSelection;
                                            _selectedAgeGroupEnum = currentAgeSelection;
                                            _lastUseTimer = useTimer;
                                            _saveSelection = true;
                                          });
                                          await _savePreferences(currentModeSelection, currentAgeSelection, useTimer: useTimer);
                                          await _saveDontShowGameSetupDialogPref(dontShowAgain);
                                          Navigator.of(dialogPageContext).pop(true); // Return true on save
                                        },
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: const Color(0xFF6C7BFF), // Blue/Purple for Save
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          minimumSize: const Size(0, 48),
                                          textStyle: GoogleFonts.baloo2(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        child: Text(
                                          AppLocalizations.of(context)!.save,
                                          style: GoogleFonts.baloo2(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 8,
                                                color: Colors.black.withOpacity(0.18),
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
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
  return result == true;
}

  void _showLanguagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Language'),
          content: SizedBox(
            width: 300,
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildLanguageTile(context, 'en', 'English', '🇬🇧'),
                _buildLanguageTile(context, 'hi', 'हिन्दी', '🇮🇳'),
                _buildLanguageTile(context, 'es', 'Español', '🇪🇸'),
                _buildLanguageTile(context, 'fr', 'Français', '🇫🇷'),
                _buildLanguageTile(context, 'de', 'Deutsch', '🇩🇪'),
                _buildLanguageTile(context, 'zh', '中文', '🇨🇳'),
                _buildLanguageTile(context, 'ar', 'العربية', '🇸🇦'),
                _buildLanguageTile(context, 'bn', 'বাংলা', '🇧🇩'),
                _buildLanguageTile(context, 'pt', 'Português', '🇵🇹'),
                _buildLanguageTile(context, 'ru', 'Русский', '🇷🇺'),
                _buildLanguageTile(context, 'ja', '日本語', '🇯🇵'),
                _buildLanguageTile(context, 'ko', '한국어', '🇰🇷'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context, String code, String label, String flag) {
    final bool isSelected = Localizations.localeOf(context).languageCode == code;
    return Container(
      decoration: isSelected
          ? BoxDecoration(
              border: Border.all(color: Colors.deepOrange, width: 2.5),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: ListTile(
        leading: Text(flag, style: const TextStyle(fontSize: 24)),
        title: Text(label),
        onTap: () {
          widget.setLocale(Locale(code));
          Navigator.of(context).pop();
        },
        selected: isSelected,
        selectedTileColor: Colors.deepOrange.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    // ...existing code...
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          AppLocalizations.of(context)!.appTitle,
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.bold,
            fontSize: (MediaQuery.of(context).size.width * 0.08).clamp(22, 36),
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black.withAlpha((0.5 * 255).round()),
                offset: const Offset(1.0, 1.0),
              ),
            ],
          ),
          minFontSize: 8,
          maxLines: 2,
          overflow: TextOverflow.visible,
          stepGranularity: 0.5,
          wrapWords: true,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: AppLocalizations.of(context)!.changeLanguage,
            onPressed: () => _showLanguagePickerDialog(context),
          ),
        ],
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
                        AppLocalizations.of(context)!.startGame,
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
                          // Only show dialog if user hasn't checked 'Don't show again'
                          bool needSetup = !_dontShowGameSetupDialog || _selectedGameModeEnum == null || _selectedAgeGroupEnum == null;
                          if (needSetup) {
                            bool saved = await _showModernGameSetupDialog(context);
                            // After dialog, check if preferences are set (user may have pressed cancel)
                            if (!saved || _selectedGameModeEnum == null || _selectedAgeGroupEnum == null) {
                              return; // Do not proceed if user cancelled or did not save
                            }
                          }
                          if (proceed && _selectedGameModeEnum != null && _selectedAgeGroupEnum != null) {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => CategorySelectionScreen(
                                  gameMode: _selectedGameModeEnum!,
                                  ageGroup: _selectedAgeGroupEnum!,
                                  useTimer: _lastUseTimer,
                                  setLocale: widget.setLocale,
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
                      _buildStyledButton(AppLocalizations.of(context)!.addTruths, Icons.add, () {
                        print("Add Truths pressed");
                        // TODO: Navigate to Add Truths screen
                      }),
                      SizedBox(height: screenHeight * 0.05),
                      _buildStyledButton(AppLocalizations.of(context)!.addDares, Icons.add, () {
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
                              // TODO: Ratings pressed
                            }, tooltip: AppLocalizations.of(context)!.ratings),
                            _buildBottomBarButton(Icons.share, () {
                              // TODO: Share pressed
                            }, tooltip: AppLocalizations.of(context)!.share),
                            _buildBottomBarButton(Icons.settings, () {
                              _showModernGameSetupDialog(context);
                            }, tooltip: AppLocalizations.of(context)!.settings),
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

  // Adjust the _buildStyledButton function to ensure the icon stays aligned to the left
  Widget _buildStyledButton(String text, IconData iconData, VoidCallback onPressed) {
    final Color shadowColor = Colors.black.withAlpha((0.3 * 255).round());
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double buttonWidth = screenWidth * 0.75;
    final double buttonHeight = (screenSize.height * 0.08).clamp(50, 80); // Ensure a responsive height
    final double fontSize = (screenSize.width * 0.05).clamp(16, 24); // Responsive font size
    final double iconSize = (screenSize.width * 0.08).clamp(24, 36); // Responsive icon size

    // Use the localized 'Start Game' for comparison in all languages
    final String localizedStartGame = AppLocalizations.of(context)!.startGame.trim().toLowerCase();
    final bool isStartGame = (text.trim().toLowerCase() == localizedStartGame);
    final Color bgColor = isStartGame ? Colors.white : Colors.black;
    final Color fgColor = isStartGame ? Colors.black : Colors.white;

    return Container(
      width: buttonWidth,
      height: buttonHeight, // Ensure consistent height
      decoration: BoxDecoration(
        color: bgColor, // Set the background color
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Use transparent to keep the container's color
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero, // Remove padding to align with container
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed, // Restore button functionality
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0), // Add spacing between icon and edge
                child: Icon(iconData, size: iconSize, color: fgColor),
              ),
            ),
            Center(
              child: Text(
                text,
                textAlign: TextAlign.center, // Keep the text centered
                style: GoogleFonts.baloo2(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: fgColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Keep _buildBottomBarButton
  Widget _buildBottomBarButton(IconData icon, VoidCallback onPressed, {String? tooltip}) {
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
      child: Tooltip(
        message: tooltip ?? '',
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
      ),
    );
  }
}
