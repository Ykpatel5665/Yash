import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'main.dart'; // Import main.dart to access GameMode and AgeGroup enums
import 'spin_the_bottle_screen.dart'; // Import Spin the Bottle screen
import 'auto_next_turn_screen.dart'; // Import Auto Next Turn screen
import 'random_turn_screen.dart'; // Import Random Turn screen
import 'dart:convert';
import 'widgets/inputs/custom_text_field.dart'; // Import CustomTextField
import 'widgets/headers/app_header.dart'; // Import AppHeader
import 'widgets/player_list_tile.dart'; // Import PlayerListTile
import 'models/player.dart';
import 'custom_appbar_button.dart';
import 'package:auto_size_text/auto_size_text.dart'; // Import AutoSizeText
import 'l10n/app_localizations.dart';

class AddPlayersScreen extends StatefulWidget {
  final GameMode gameMode;
  final AgeGroup ageGroup;
  final List<String>? selectedCategoryIds;
  final bool useTimer;
  final void Function(Locale) setLocale;

  const AddPlayersScreen({
    super.key,
    required this.gameMode,
    required this.ageGroup,
    this.selectedCategoryIds,
    required this.useTimer,
    required this.setLocale,
  });

  @override
  State<AddPlayersScreen> createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends State<AddPlayersScreen> {
  final TextEditingController _playerNameController = TextEditingController();
  List<Player> _players = [];
  final FocusNode _textFieldFocusNode = FocusNode();
  static const String _playersPrefsKey = 'playerList';

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
    final List<String> playerJsons = _players.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_playersPrefsKey, playerJsons);
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  void _addPlayer() {
    if (_players.length >= 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.maxPlayersWarning, style: GoogleFonts.baloo2(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    final String name = _playerNameController.text.trim();
    if (name.isNotEmpty && !_players.any((p) => p.name == name)) {
      setState(() {
        _players.add(Player(name: name));
        _savePlayers();
      });
      _playerNameController.clear();
      _textFieldFocusNode.requestFocus();
    } else if (name.isNotEmpty && _players.any((p) => p.name == name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name ${AppLocalizations.of(context)!.alreadyAdded}', style: GoogleFonts.baloo2(color: Colors.white)),
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
        title: AppLocalizations.of(context)!.addPlayers,
        centerTitle: true,
        leading: CustomAppBarButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: (screenSize.height * 0.12).clamp(64, 120), // Responsive height
        // Pass a custom title builder to force single line with ellipsis
        actions: null,
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
                            hintText: AppLocalizations.of(context)!.enterPlayerName,
                            onSubmitted: (_) => _addPlayer(),
                            enabled: true, // Always enabled
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
                          onPressed: () {
                            if (_players.length >= 20) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!.maxPlayersWarning, style: GoogleFonts.baloo2(color: Colors.white)),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            } else {
                              _addPlayer();
                            }
                          },
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
                              return PlayerListTile(
                                player: _players[index],
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
                              ageGroup: widget.ageGroup,
                              selectedCategoryIds: widget.selectedCategoryIds ?? [],
                              useTimer: widget.useTimer,
                              setLocale: widget.setLocale,
                            );
                            break;
                          case GameMode.auto:
                            nextScreen = AutoNextTurnScreen(
                              players: _players.map((p) => p.name).toList(),
                              ageGroup: widget.ageGroup,
                              selectedCategoryIds: widget.selectedCategoryIds ?? [],
                              useTimer: widget.useTimer,
                            );
                            break;
                          case GameMode.random:
                            nextScreen = RandomTurnScreen(
                              players: _players.map((p) => p.name).toList(),
                              ageGroup: widget.ageGroup,
                              selectedCategoryIds: widget.selectedCategoryIds ?? [],
                              useTimer: widget.useTimer,
                              setLocale: widget.setLocale,
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
                              child: AutoSizeText(
                                AppLocalizations.of(context)!.start,
                                textAlign: TextAlign.center,
                                minFontSize: 10,
                                maxLines: 2,
                                wrapWords: true,
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
                    AppLocalizations.of(context)!.minPlayersWarning,
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
