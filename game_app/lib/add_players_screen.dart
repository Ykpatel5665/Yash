import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'main.dart'; // Import main.dart to access GameMode and AgeGroup enums
import 'spin_the_bottle_screen.dart'; // Import Spin the Bottle screen
import 'auto_next_turn_screen.dart'; // Import Auto Next Turn screen
import 'random_turn_screen.dart'; // Import Random Turn screen
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Add this import for color picker
import 'dart:convert';
import 'widgets/inputs/custom_text_field.dart'; // Import CustomTextField
import 'widgets/headers/app_header.dart'; // Import AppHeader
import 'widgets/buttons/neumorphic_icon_button.dart'; // Import NeumorphicIconButton
import 'widgets/player_list_tile.dart'; // Import PlayerListTile
import 'models/player.dart';
import 'custom_appbar_button.dart';
import 'widgets/buttons/primary_button.dart'; // Import PrimaryButton

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
      appBar: AppHeader(
        title: 'Add Players',
        centerTitle: true,
        leading: CustomAppBarButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: appBarTheme.toolbarHeight,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: backgroundGradient,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 15),
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
                          child: CustomTextField(
                            controller: _playerNameController,
                            focusNode: _textFieldFocusNode,
                            hintText: 'Add Player...',
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
                  Expanded(
                    child: _players.isEmpty
                        ? const SizedBox.shrink()
                        : ListView.separated(
                            itemCount: _players.length,
                            padding: const EdgeInsets.only(top: 5, bottom: 120), // Add bottom padding for button
                            itemBuilder: (context, index) {
                              // Use a gradient background for the avatar
                              final Color baseColor = _players[index].color;
                              // Create a lighter shade for the gradient
                              Color lighterColor = Color.lerp(baseColor, Colors.white, 0.5)!;
                              return PlayerListTile(
                                player: _players[index],
                                onColorTap: () => _pickColor(index),
                                onRemoveTap: () => _removePlayer(index),
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
                ],
              ),
            ),
          ),
          // Fixed bottom button
          if (_players.length >= 2)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 69.0),
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                        textStyle: GoogleFonts.baloo2(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                        shadowColor: Colors.transparent,
                        minimumSize: Size(MediaQuery.of(context).size.width * 0.75, MediaQuery.of(context).size.height * 0.001),
                        alignment: Alignment.center,
                      ),
                      onPressed: () {
                        // Navigate based on the selected game mode
                        print(
                            "Let's Begin pressed! Mode: [widget.gameMode}, Age: [widget.ageGroup}, Players: $_players");

                        Widget nextScreen;
                        switch (widget.gameMode) {
                          case GameMode.spin:
                            nextScreen = SpinTheBottleScreen(
                              players: _players.map((p) => p.name).toList(),
                              playerColors: _players.map((p) => p.color).toList(),
                              ageGroup: widget.ageGroup,
                              selectedCategoryIds: widget.selectedCategoryIds ?? [],
                            );
                            break;
                          case GameMode.auto:
                            nextScreen = AutoNextTurnScreen(
                              players: _players.map((p) => p.name).toList(),
                              playerColors: _players.map((p) => p.color).toList(),
                              ageGroup: widget.ageGroup,
                              selectedCategoryIds: widget.selectedCategoryIds ?? [],
                            );
                            break;
                          case GameMode.random:
                            nextScreen = RandomTurnScreen(
                              players: _players.map((p) => p.name).toList(),
                              playerColors: _players.map((p) => p.color).toList(),
                              ageGroup: widget.ageGroup,
                              selectedCategoryIds: widget.selectedCategoryIds ?? [],
                            );
                            break;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => nextScreen),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 50.0),
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Let's begin!",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Opacity(
                            opacity: 0,
                            child: Icon(Icons.play_arrow_rounded, size: 50.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 69.0),
                child: Center(
                  child: Text(
                    'Add at least 2 players',
                    style: GoogleFonts.baloo2(fontSize: 16, color: Colors.white70),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
