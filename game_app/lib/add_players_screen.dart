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

    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    // Responsive values
    final double horizontalPadding = (screenWidth * 0.05).clamp(10, 32); // replaces 20.0
    final double verticalPadding = (screenHeight * 0.012).clamp(6, 20); // replaces 10.0
    final double inputRowSpacing = (screenHeight * 0.018).clamp(10, 28); // replaces 15
    final double inputButtonSpacing = (screenWidth * 0.025).clamp(6, 18); // replaces 10
    final double addIconSize = (screenWidth * 0.08).clamp(26, 40); // replaces 32
    final double listTopSpacing = (screenHeight * 0.04).clamp(18, 40); // replaces 30
    final double bottomButtonWidth = (screenWidth * 0.75).clamp(220, 420);
    final double bottomButtonMinHeight = (screenHeight * 0.08).clamp(48, 70); // replaces 62
    final double bottomButtonIconSize = (screenWidth * 0.13).clamp(36, 56); // replaces 50
    final double bottomPadding = (screenHeight * 0.09).clamp(48, 90); // replaces 69
    final double infoTextFontSize = (screenWidth * 0.04).clamp(13, 18); // replaces 16
    final double beginTextFontSize = (screenWidth * 0.06).clamp(18, 28);

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
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding), // Responsive
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: inputRowSpacing), // Responsive
                  // Player Input Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(80),
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
                      SizedBox(width: inputButtonSpacing), // Responsive
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
                            padding: EdgeInsets.all((screenWidth * 0.04).clamp(10, 20)), // Responsive
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: Icon(Icons.add, size: addIconSize), // Responsive
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: listTopSpacing), // Responsive
                  Expanded(
                    child: _players.isEmpty
                        ? const SizedBox.shrink()
                        : ListView.separated(
                            itemCount: _players.length,
                            padding: EdgeInsets.only(top: 5, bottom: bottomPadding), // Responsive
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
                              color: Colors.white.withOpacity(0.3),
                              height: 1,
                              thickness: 1,
                              indent: 16,
                              endIndent: 16,
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
                padding: EdgeInsets.only(bottom: bottomPadding), // Responsive
                child: Center(
                  child: Container(
                    width: bottomButtonWidth, // Responsive
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.3 * 255).round()),
                          blurRadius: 10.0,
                          spreadRadius: 1.0,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: Size(bottomButtonWidth, bottomButtonMinHeight), // Responsive
                        padding: EdgeInsets.symmetric(vertical: (screenHeight * 0.014).clamp(8, 18)), // Responsive
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        textStyle: GoogleFonts.baloo2(
                          fontSize: beginTextFontSize, // Responsive
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        // Navigate based on the selected game mode
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: (screenWidth * 0.06).clamp(12, 32)), // Responsive
                            child: Icon(Icons.play_arrow_rounded, size: bottomButtonIconSize), // Responsive
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Let's Begin!",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Opacity(
                            opacity: 0,
                            child: Icon(Icons.play_arrow_rounded, size: bottomButtonIconSize), // Responsive
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
                padding: EdgeInsets.only(bottom: bottomPadding), // Responsive
                child: Center(
                  child: Text(
                    'Add at least 2 players',
                    style: GoogleFonts.baloo2(fontSize: infoTextFontSize, color: Colors.white70), // Responsive
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
