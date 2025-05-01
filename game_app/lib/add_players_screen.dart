import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'main.dart'; // Import main.dart to access GameMode and AgeGroup enums

class AddPlayersScreen extends StatefulWidget {
  final GameMode gameMode;
  final AgeGroup ageGroup;

  const AddPlayersScreen({
    super.key,
    required this.gameMode,
    required this.ageGroup,
  });

  @override
  State<AddPlayersScreen> createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends State<AddPlayersScreen> {
  final TextEditingController _playerNameController = TextEditingController();
  List<String> _players = []; // Initialize as empty, will be loaded
  final FocusNode _textFieldFocusNode = FocusNode(); // To manage focus

  // Key for saving/loading players
  static const String _playersPrefsKey = 'playerList';

  @override
  void initState() {
    super.initState();
    _loadPlayers(); // Load players when the screen initializes
  }

  // Load players from SharedPreferences
  Future<void> _loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Load the list, default to empty list if not found
      _players = prefs.getStringList(_playersPrefsKey) ?? [];
    });
    print("Loaded players: $_players");
  }

  // Save players to SharedPreferences
  Future<void> _savePlayers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_playersPrefsKey, _players);
    print("Saved players: $_players");
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final String name = _playerNameController.text.trim();
    if (name.isNotEmpty && !_players.contains(name)) {
      setState(() {
        _players.add(name);
        _savePlayers(); // Save after adding
      });
      _playerNameController.clear();
      _textFieldFocusNode.requestFocus(); // Keep focus on text field
    } else if (name.isNotEmpty && _players.contains(name)) {
      // Optional: Show a message if player already exists
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name is already added!',
              style: GoogleFonts.baloo2(color: Colors.white)),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
      _savePlayers(); // Save after removing
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

    // Use the same AppBar style from MyApp theme, but allow customization if needed
    final AppBarTheme appBarTheme = Theme.of(context).appBarTheme;
    // Define neumorphic colors based on the gradient
    final Color baseColor = const Color.fromARGB(255, 255, 255, 255);
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
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: const Color.fromARGB(255, 0, 0, 0), // Icon color
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
      body: Container(
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
                            // Use ListTile directly without background container
                            return ListTile(
                              // Keep the leading number style (optional, can simplify)
                              leading: Text(
                                '${index + 1}.',
                                style: GoogleFonts.baloo2(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              title: Text(
                                _players[index],
                                style: GoogleFonts.baloo2(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold), // Make text bolder
                              ),
                              trailing: IconButton(
                                // Use close icon and match text color
                                icon: Icon(Icons.close, color: Colors.white),
                                tooltip: 'Remove ${_players[index]}',
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
                    padding: const EdgeInsets.only(bottom: 30.0),
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
                          // TODO: Implement navigation to the actual game screen
                          print("Let's Begin pressed! Players: $_players");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Starting game with: ${_players.join(', ')}',
                                  style: GoogleFonts.baloo2()),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        // Use Stack for custom layout
                        child: Stack(
                          alignment: Alignment
                              .center, // Center the Stack content by default
                          children: [
                            // Align Icon to the left
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
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
                        bottom: 30.0), // Match bottom padding
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
    );
  }
}
