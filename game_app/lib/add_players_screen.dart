import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'main.dart'; // Import main.dart to access GameMode and AgeGroup enums
import 'spin_the_bottle_screen.dart'; // Import Spin the Bottle screen
import 'auto_next_turn_screen.dart'; // Import Auto Next Turn screen
import 'random_turn_screen.dart'; // Import Random Turn screen
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Add this import for color picker
import 'dart:convert';

// Define a Player model
class Player {
  String name;
  Color color;
  Player({required this.name, required this.color});

  // For saving/loading from SharedPreferences
  Map<String, dynamic> toJson() => {'name': name, 'color': color.value};
  static Player fromJson(Map<String, dynamic> json) => Player(
        name: json['name'],
        color: Color(json['color']),
      );
}

class AddPlayersScreen extends StatefulWidget {
  final GameMode gameMode;
  final AgeGroup ageGroup;
  final List<String>? selectedCategoryIds;

  const AddPlayersScreen({
    super.key,
    required this.gameMode,
    required this.ageGroup,
    this.selectedCategoryIds,
  });

  @override
  State<AddPlayersScreen> createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends State<AddPlayersScreen> {
  final TextEditingController _playerNameController = TextEditingController();
  List<Player> _players = [];
  final FocusNode _textFieldFocusNode = FocusNode();
  static const String _playersPrefsKey = 'playerList';
  final List<Color> _defaultColors = [
    Color(0xFFEF476F), // Vibrant Pink
    Color(0xFF3A86FF), // Electric Blue
    Color(0xFF06D6A0), // Aqua Green
    Color(0xFFFFD166), // Gold Yellow
    Color(0xFF8338EC), // Royal Purple
    Color(0xFFFF6F00), // Deep Orange
    Color(0xFF00B8D9), // Rich Cyan
    Color(0xFFFF61A6), // Punchy Pink
    Color(0xFF43AA8B), // Emerald Green
    Color(0xFFFB5607), // Vivid Orange
    Color(0xFF7209B7), // Deep Violet
    Color(0xFF00C853), // Premium Green
    Color(0xFFB388FF), // Soft Lavender
    Color(0xFFFF1744), // Red Accent
    Color(0xFF00E5FF), // Neon Cyan
    Color(0xFFFFC400), // Amber Gold
    Color(0xFF8D6E63), // Elegant Brown
    Color(0xFF1DE9B6), // Mint Green
    Color(0xFF536DFE), // Indigo Blue
    Color(0xFFFF4081), // Pink Accent
  ];

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> playerJsons = prefs.getStringList(_playersPrefsKey) ?? [];
    setState(() {
      _players = playerJsons.map((e) {
        final map = Map<String, dynamic>.from(jsonDecode(e));
        return Player.fromJson(map);
      }).toList();
    });
  }

  Future<void> _savePlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> playerJsons = _players.map((p) => jsonEncode(p.toJson()) as String).toList();
    await prefs.setStringList(_playersPrefsKey, playerJsons);
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final String name = _playerNameController.text.trim();
    if (name.isNotEmpty && !_players.any((p) => p.name == name)) {
      setState(() {
        final color = _defaultColors[_players.length % _defaultColors.length];
        _players.add(Player(name: name, color: color));
        _savePlayers();
      });
      _playerNameController.clear();
      _textFieldFocusNode.requestFocus();
    } else if (name.isNotEmpty && _players.any((p) => p.name == name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name is already added!', style: GoogleFonts.baloo2(color: Colors.white)),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
      _savePlayers();
    });
  }

  void _pickColor(int index) async {
    Color selectedColor = _players[index].color;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                selectedColor = color;
              },
              enableAlpha: false,
              showLabel: false,
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Select'),
              onPressed: () {
                setState(() {
                  _players[index].color = selectedColor;
                  _savePlayers();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define a slightly different gradient for this screen
    const LinearGradient backgroundGradient = LinearGradient(
      colors: [
        // Example: Blue to Purple gradient
        Color.fromARGB(255, 50, 196, 255), // A nice blue
        Color.fromARGB(255, 27, 123, 212), // A complementary purple
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    // Use the same AppBar style from MyApp theme, but allow customization if needed
    final AppBarTheme appBarTheme = Theme.of(context).appBarTheme;
    // Define neumorphic colors based on the gradient
    const Color baseColor = Color.fromARGB(255, 255, 255, 255);
    final Color shadowDark = Colors.black.withOpacity(0.3);
    final Color shadowLight = Colors.white.withOpacity(0.4);

    return Scaffold(
      appBar: AppBar(
        // Remove default back button
        automaticallyImplyLeading: false,
        // Add custom leading button
        leading: Padding(
          padding: const EdgeInsets.only(
              left: 5.0,
              top: 15,
              bottom: 15), // Reduced left padding, adjusted vertical padding
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40, // Decreased size
              height: 40, // Decreased size
              decoration: BoxDecoration(
                color: baseColor.withOpacity(0.8), // Slightly transparent base
                borderRadius:
                    BorderRadius.circular(10), // Slightly smaller radius
                boxShadow: [
                  // Adjust shadows for smaller size
                  BoxShadow(
                    color: shadowDark,
                    offset: const Offset(3, 3), // Smaller offset
                    blurRadius: 6, // Smaller blur
                  ),
                  BoxShadow(
                    color: shadowLight,
                    offset: const Offset(-3, -3), // Smaller offset
                    blurRadius: 6, // Smaller blur
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color.fromARGB(255, 0, 0, 0), // Icon color
                size: 20, // Smaller icon size
              ),
            ),
          ),
        ),
        title: Text(
          'Add Players',
          style: appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Keep AppBar transparent
        elevation: 0,
        // iconTheme: appBarTheme.iconTheme, // No longer needed for default icon
        toolbarHeight: appBarTheme.toolbarHeight,
        titleSpacing: appBarTheme.titleSpacing,
      ),
      extendBodyBehindAppBar: true, // Extend body behind AppBar
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity, // Ensure container takes full width
              height: double.infinity, // Ensure container takes full height
              decoration: const BoxDecoration(
                gradient: backgroundGradient, // Apply the new gradient
              ),
              child: SafeArea(
                // Use SafeArea to avoid overlap with status/notch
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 15), // Add some top padding

                      // Player Input Row
                      Row(
                        children: [
                          Expanded(
                            // Wrap TextField in Container for shadow
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors
                                    .white, // Ensure container background is white
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withAlpha(80), // Similar shadow
                                    blurRadius: 8.0,
                                    spreadRadius: 1.0,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _playerNameController,
                                focusNode: _textFieldFocusNode,
                                style: GoogleFonts.baloo2(
                                    color: Colors.black, fontSize: 18),
                                decoration: InputDecoration(
                                  hintText: 'Add Player...',
                                  hintStyle:
                                      GoogleFonts.baloo2(color: Colors.grey[600]),
                                  filled: true,
                                  fillColor: Colors
                                      .transparent, // Make TextField transparent, container has color
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 15),
                                  border: InputBorder
                                      .none, // Remove TextField border, container handles shape
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                onSubmitted: (_) => _addPlayer(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Wrap Button in Container for shadow
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(80),
                                  blurRadius: 8.0,
                                  spreadRadius: 1.0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _addPlayer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation:
                                    0, // Remove button's own elevation, container has shadow
                                shadowColor: Colors.transparent,
                              ),
                              // Use the standard add icon, potentially increase size for perceived thickness
                              child: const Icon(Icons.add,
                                  size: 32), // Standard add, slightly larger size
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // REMOVED: Player List Header
                      // if (_players.isNotEmpty)
                      //   Text(
                      //     'Players',
                      //     style: GoogleFonts.baloo2(
                      //         fontSize: 20,
                      //         color: Colors.white,
                      //         fontWeight: FontWeight.bold),
                      //   ),
                      // const SizedBox(height: 10),

                      // Player List
                      Expanded(
                        child: _players.isEmpty
                            ? const SizedBox.shrink() // Show nothing when empty
                            : ListView.separated(
                                itemCount: _players.length,
                                padding: const EdgeInsets.only(
                                    top: 5), // Add padding above the list
                                itemBuilder: (context, index) {
                                  // Use a gradient background for the avatar
                                  final Color baseColor = _players[index].color;
                                  // Create a lighter shade for the gradient
                                  Color lighterColor = Color.lerp(baseColor, Colors.white, 0.5)!;
                                  return ListTile(
                                    leading: GestureDetector(
                                      onTap: () => _pickColor(index),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(10),
                                            color: baseColor,
                                          border: Border.all(
                                          color: Colors.white,
                                          width: 4, // Thick white border
                                          ),
                                        ),
                                        // child: const Icon(Icons.color_lens, color: Colors.white, size: 16),
                                      ),
                                    ),
                                    title: Text(
                                      _players[index].name,
                                      style: GoogleFonts.baloo2(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight:
                                              FontWeight.bold), // Make text bolder
                                    ),
                                    trailing: IconButton(
                                      // Use close icon and match text color
                                      icon: const Icon(Icons.close,
                                          color: Colors.white),
                                      tooltip: 'Remove ${_players[index].name}',
                                      onPressed: () => _removePlayer(index),
                                      splashRadius: 24,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 0), // Adjust padding
                                  );
                                },
                                separatorBuilder: (context, index) => Divider(
                                  color: Colors.white
                                      .withOpacity(0.3), // Simple line color
                                  height: 1, // Thin line
                                  thickness: 1,
                                  indent: 16, // Optional indent
                                  endIndent: 16, // Optional end indent
                                ),
                              ),
                      ),
                      const SizedBox(height: 20), // Spacing before button

                      // "Let's Begin" Button
                      if (_players.length >= 2) // Only show if 2 or more players
                        Padding(
                          // Increased bottom padding
                          padding: const EdgeInsets.only(bottom: 69.0),
                          // Wrap ElevatedButton in Container for shadow, similar to _buildStyledButton
                          child: Container(
                            width: MediaQuery.of(context).size.width *
                                0.75, // Match width from _buildStyledButton
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha((0.3 * 255)
                                      .round()), // Shadow from _buildStyledButton
                                  blurRadius: 10.0,
                                  spreadRadius: 1.0,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            // Replace ElevatedButton.icon with ElevatedButton and a Stack child
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .black, // Black background like Add Truths/Dares
                                foregroundColor: Colors.white, // White text/icon
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width * 0.75,
                                    MediaQuery.of(context).size.height *
                                        0.07), // Match size constraints
                                padding: const EdgeInsets.symmetric(
                                    vertical: 30), // Match vertical padding
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10), // Match radius
                                ),
                                elevation:
                                    0, // Remove default elevation, container has shadow
                                shadowColor: Colors.transparent,
                                // Remove alignment: Alignment.center, Stack handles alignment
                              ),
                              onPressed: () {
                                // Navigate based on the selected game mode
                                print(
                                    "Let's Begin pressed! Mode: ${widget.gameMode}, Age: ${widget.ageGroup}, Players: $_players");

                                Widget nextScreen;
                                switch (widget.gameMode) {
                                  case GameMode.spin:
                                    nextScreen = SpinTheBottleScreen(
                                      players: _players.map((p) => p.name).toList(),
                                      playerColors: _players.map((p) => p.color).toList(),
                                      ageGroup: widget.ageGroup,
                                    );
                                    break;
                                  case GameMode.auto:
                                    nextScreen = AutoNextTurnScreen(
                                      players: _players.map((p) => p.name).toList(),
                                      playerColors: _players.map((p) => p.color).toList(),
                                      ageGroup: widget.ageGroup,
                                    );
                                    break;
                                  case GameMode.random:
                                    nextScreen = RandomTurnScreen(
                                      players: _players.map((p) => p.name).toList(),
                                      playerColors: _players.map((p) => p.color).toList(),
                                      ageGroup: widget.ageGroup,
                                    );
                                    break;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => nextScreen),
                                );
                              },
                              // Use Stack for custom layout
                              child: Stack(
                                alignment: Alignment
                                    .center, // Center the Stack content by default
                                children: [
                                  // Align Icon to the left
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 10.0), // Padding for the icon
                                      child: Icon(Icons.play_arrow_rounded,
                                          size: 30), // Keep the icon
                                    ),
                                  ),
                                  // Align Text to the center (default for Stack)
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text("Let's begin!",
                                        style: GoogleFonts.baloo2(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else // Optional: Show a disabled hint or just space if less than 2 players
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 69.0), // Match bottom padding
                          child: Text(
                            'Add at least 2 players',
                            style: GoogleFonts.baloo2(
                                fontSize: 16, color: Colors.white70),
                          ),
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
